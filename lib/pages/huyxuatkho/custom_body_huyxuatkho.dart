import 'dart:async';
import 'dart:convert';

import 'package:Thilogi/blocs/huyxuatkho_bloc.dart';
import 'package:Thilogi/models/danhsachphuongtien.dart';
import 'package:Thilogi/models/diadiem.dart';
import 'package:Thilogi/models/loaiphuongtien.dart';
import 'package:Thilogi/models/phuongthucvanchuyen.dart';
import 'package:Thilogi/models/xuatkho.dart';
import 'package:Thilogi/pages/ds_vanchuyen/ds_vanchuyen.dart';
import 'package:Thilogi/utils/next_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutter_datawedge/models/scan_result.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator_platform_interface/src/enums/location_accuracy.dart' as GeoLocationAccuracy;

import '../../config/config.dart';
import '../../services/app_service.dart';
import '../../widgets/loading.dart';

// ignore: use_key_in_widget_constructors
class CustomBodyHuyXuatKho extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: BodyHuyXuatKhoScreen());
  }
}

class BodyHuyXuatKhoScreen extends StatefulWidget {
  const BodyHuyXuatKhoScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _BodyHuyXuatKhoScreenState createState() => _BodyHuyXuatKhoScreenState();
}

class _BodyHuyXuatKhoScreenState extends State<BodyHuyXuatKhoScreen> with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  String? lat;
  String? long;
  String _qrData = '';
  final _qrDataController = TextEditingController();
  XuatKhoModel? _data;
  bool _loading = false;
  String? barcodeScanResult;
  String? viTri;

  late HuyXuatKhoBloc _bl;

  List<DiaDiemModel>? _diadiemList;

  List<DiaDiemModel>? get diadiemList => _diadiemList;
  List<PhuongThucVanChuyenModel>? _phuongthucvanchuyenList;
  List<PhuongThucVanChuyenModel>? get phuongthucvanchuyenList => _phuongthucvanchuyenList;
  List<DanhSachPhuongTienModel>? _danhsachphuongtienList;
  List<DanhSachPhuongTienModel>? get danhsachphuongtienList => _danhsachphuongtienList;
  List<LoaiPhuongTienModel>? _loaiphuongtienList;
  List<LoaiPhuongTienModel>? get loaiphuongtienList => _loaiphuongtienList;

  bool _isLoading = true;
  bool get isLoading => _isLoading;
  bool _isMovingStarted = false;
  String? _message;
  String? get message => _message;
  late FlutterDataWedge dataWedge;
  late StreamSubscription<ScanResult> scanSubscription;
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();

  @override
  void initState() {
    super.initState();
    _bl = Provider.of<HuyXuatKhoBloc>(context, listen: false);
    requestLocationPermission();
    _checkInternetAndShowAlert();
    dataWedge = FlutterDataWedge(profileName: "Example Profile");
    scanSubscription = dataWedge.onScanResult.listen((ScanResult result) {
      setState(() {
        barcodeScanResult = result.data;
      });
      print(barcodeScanResult);
      _handleBarcodeScanResult(barcodeScanResult ?? "");
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _checkInternetAndShowAlert() {
    AppService().checkInternet().then((hasInternet) async {
      if (!hasInternet!) {
        // Reset the button state if necessary

        QuickAlert.show(
          context: context,
          type: QuickAlertType.info,
          title: '',
          text: 'Không có kết nối internet. Vui lòng kiểm tra lại',
          confirmBtnText: 'Đồng ý',
        );
      }
    });
  }

  void requestLocationPermission() async {
    // Kiểm tra quyền truy cập vị trí
    LocationPermission permission = await Geolocator.checkPermission();
    // Nếu chưa có quyền, yêu cầu quyền truy cập vị trí
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      // Yêu cầu quyền truy cập vị trí
      await Geolocator.requestPermission();
    }
  }

  Future<void> HuyXuatKho(XuatKhoModel? scanData, String soKhung, String toaDo) async {
    _isLoading = true;
    try {
      var newScanData = scanData;
      newScanData?.soKhung = newScanData.soKhung == 'null' ? null : newScanData.soKhung;
      print("print data: ${newScanData?.soKhung}");
      final http.Response response = await requestHelper.postData('KhoThanhPham/HuyXuatKho?SoKhung=$soKhung&ViTri=$toaDo', newScanData?.toJson());
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        print("data: ${decodedData}");

        notifyListeners();
        _btnController.success();
        setState(() {
          _loading = false;
        });
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: "Thành công",
          text: "Hủy vận chuyển thành công ",
          confirmBtnText: 'Đồng ý',
        );
        _isMovingStarted = true;
        _btnController.reset();
      } else {
        String errorMessage = response.body.replaceAll('"', '');
        notifyListeners();
        _btnController.error();
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Thất bại',
          text: errorMessage,
          confirmBtnText: 'Đồng ý',
        );
        _btnController.reset();
      }
    } catch (e) {
      _message = e.toString();

      _isLoading = false;
      notifyListeners();
    }
  }

  Widget CardVin() {
    return Container(
      width: MediaQuery.of(context).size.width < 330 ? 100.w : 90.w,
      // height: 11.h,
      height: MediaQuery.of(context).size.height < 880 ? 8.h : 8.h,
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF818180),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 20.w,
            height: 11.h,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5),
                bottomLeft: Radius.circular(5),
              ),
              color: AppConfig.primaryColor,
            ),
            child: const Center(
              child: Text(
                'Số khung\n(VIN)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                controller: _qrDataController,
                decoration: const InputDecoration(
                  hintText: 'Nhập hoặc quét mã VIN',
                ),
                onSubmitted: (value) {
                  _handleBarcodeScanResult(value);
                },
                style: const TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppConfig.primaryColor,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            color: Colors.black,
            onPressed: () async {
              String result = await FlutterBarcodeScanner.scanBarcode(
                '#A71C20',
                'Cancel',
                false,
                ScanMode.QR,
              );
              setState(() {
                barcodeScanResult = result;
                _qrDataController.text = result;
              });
              print(barcodeScanResult);
              _handleBarcodeScanResult(barcodeScanResult ?? "");
            },
          ),
        ],
      ),
    );
  }

  void _handleBarcodeScanResult(String barcodeScanResult) {
    print(barcodeScanResult);

    setState(() {
      _qrData = '';
      _qrDataController.text = barcodeScanResult;
      _data = null;
      Future.delayed(const Duration(seconds: 0), () {
        _qrData = barcodeScanResult;
        _qrDataController.text = barcodeScanResult;
        _onScan(barcodeScanResult);
      });
    });
  }

  _onScan(value) {
    setState(() {
      _loading = true;
    });
    _bl.getData(context, value).then((_) {
      setState(() {
        _qrData = value;
        if (_bl.xuatkho == null) {
          barcodeScanResult = null;
          _qrData = '';
          _qrDataController.text = '';
        }
        _loading = false;
        _data = _bl.xuatkho;
      });
    });
  }

  _onHuyXuatKho() {
    setState(() {
      _loading = true;
    });

    _data?.key = _bl.xuatkho?.key;
    _data?.id = _bl.xuatkho?.id;
    _data?.soKhung = _bl.xuatkho?.soKhung;
    _data?.tenSanPham = _bl.xuatkho?.tenSanPham;
    _data?.maSanPham = _bl.xuatkho?.maSanPham;
    _data?.soMay = _bl.xuatkho?.soMay;
    _data?.maMau = _bl.xuatkho?.maMau;
    _data?.tenMau = _bl.xuatkho?.tenMau;
    _data?.tenKho = _bl.xuatkho?.tenKho;
    _data?.maViTri = _bl.xuatkho?.maViTri;
    _data?.tenViTri = _bl.xuatkho?.tenViTri;
    _data?.mauSon = _bl.xuatkho?.mauSon;
    _data?.ngayNhapKhoView = _bl.xuatkho?.ngayNhapKhoView;
    _data?.maKho = _bl.xuatkho?.maKho;
    _data?.kho_Id = _bl.xuatkho?.kho_Id;
    _data?.noidi = _bl.xuatkho?.noidi;
    _data?.noiden = _bl.xuatkho?.noiden;

    _data?.bienSo_Id = _bl.xuatkho?.bienSo_Id;
    _data?.taiXe_Id = _bl.xuatkho?.taiXe_Id;
    _data?.tenDiaDiem = _bl.xuatkho?.tenDiaDiem;
    _data?.tenPhuongThucVanChuyen = _bl.xuatkho?.tenPhuongThucVanChuyen;
    Geolocator.getCurrentPosition(
      desiredAccuracy: GeoLocationAccuracy.LocationAccuracy.low,
    ).then((position) {
      setState(() {
        lat = "${position.latitude}";
        long = "${position.longitude}";
      });

      viTri = "${lat},${long}";
      print("viTri: ${_data?.toaDo}");

      AppService().checkInternet().then((hasInternet) {
        if (!hasInternet!) {
          // openSnackBar(context, 'no internet'.tr());
          QuickAlert.show(
            // ignore: use_build_context_synchronously
            context: context,
            type: QuickAlertType.error,
            title: 'Thất bại',
            text: 'Không có kết nối internet. Vui lòng kiểm tra lại',
            confirmBtnText: 'Đồng ý',
          );
        } else {
          HuyXuatKho(_data!, _data?.soKhung ?? "", _data?.toaDo ?? "").then((_) {
            setState(() {
              _data = null;
              barcodeScanResult = null;
              _qrData = '';
              _qrDataController.text = '';
              _loading = false;
              _isMovingStarted = false;
            });
          });
        }
      });
    }).catchError((error) {
      _btnController.error();
      QuickAlert.show(
        // ignore: use_build_context_synchronously
        context: context,
        type: QuickAlertType.error,
        title: 'Thất bại',
        text: 'Bạn chưa có tọa độ vị trí. Vui lòng BẬT VỊ TRÍ',
        confirmBtnText: 'Đồng ý',
      );
      _btnController.reset();
      setState(() {
        _loading = false;
      });
      print("Error getting location: $error");
    });
  }

  void _showConfirmationDialogHuyXuatKho(BuildContext context) {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        text: 'Bạn có muốn hủy xe này không?',
        title: '',
        confirmBtnText: 'Đồng ý',
        cancelBtnText: 'Không',
        confirmBtnTextStyle: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
        cancelBtnTextStyle: const TextStyle(
          color: Colors.red,
          fontSize: 19.0,
          fontWeight: FontWeight.bold,
        ),
        onCancelBtnTap: () {
          Navigator.of(context).pop();
          _btnController.reset();
        },
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
          _onHuyXuatKho();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        CardVin(),
        const SizedBox(height: 5),
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _loading
                      ? LoadingWidget(context)
                      : Container(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Thông Tin Xác Nhận',
                                    style: TextStyle(
                                      fontFamily: 'Comfortaa',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.visibility),
                                    onPressed: () {
                                      // Hành động khi nhấn vào icon
                                      nextScreen(context, DSVanChuyenPage());
                                      // Điều hướng đến trang lịch sử hoặc thực hiện hành động khác
                                    },
                                  ),
                                ],
                              ),
                              const Divider(
                                height: 1,
                                color: AppConfig.primaryColor,
                              ),
                              Container(
                                child: Column(
                                  children: [
                                    Container(
                                      height: 6.h,
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(left: 10),
                                            child: const Text(
                                              'Loại xe: ',
                                              style: TextStyle(
                                                fontFamily: 'Comfortaa',
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF818180),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.70),
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Text(
                                                _data?.tenSanPham ?? '',
                                                textAlign: TextAlign.left,
                                                style: const TextStyle(
                                                  fontFamily: 'Coda Caption',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppConfig.primaryColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                    Item(
                                      title: 'Số khung: ',
                                      value: _data?.soKhung,
                                    ),
                                    const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                    Item(
                                        title: 'Màu: ',
                                        // value: _data != null
                                        //     ? "${_data?.tenMau} (${_data?.maMau})"
                                        //     : "",
                                        value: _data != null ? (_data?.tenMau != null && _data?.maMau != null ? "${_data?.tenMau} (${_data?.maMau})" : "") : ""),
                                    const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                    Item(
                                      title: 'Số máy: ',
                                      value: _data?.soMay,
                                    ),
                                    const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                    Item(
                                      title: 'Phương thức vận chuyển: ',
                                      value: _data?.tenPhuongThucVanChuyen,
                                    ),
                                    const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                    Item(
                                      title: 'Bên vận chuyển: ',
                                      value: _data?.benVanChuyen,
                                    ),
                                    const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                    Item(
                                      title: 'Biển số: ',
                                      value: _data?.soXe,
                                    ),
                                    const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                    Item(
                                      title: 'Nơi đi: ',
                                      value: _data?.noidi,
                                    ),
                                    const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                    Item(
                                      title: 'Nơi đến: ',
                                      value: _data?.noiden,
                                    ),
                                    const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                    Item(
                                      title: 'Người phụ trách: ',
                                      value: _data?.nguoiPhuTrach,
                                    ),
                                    const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RoundedLoadingButton(
                child: Text('Hủy',
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      color: AppConfig.textButton,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    )),
                controller: _btnController,
                onPressed: _data?.nguoiPhuTrach != null ? () => _showConfirmationDialogHuyXuatKho(context) : null,
              ),
            ],
          ),
        ),
      ],
    ));
  }
}

class Item extends StatelessWidget {
  final String title;
  final String? value;

  const Item({
    Key? key,
    required this.title,
    this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6.h,
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Center(
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF818180),
              ),
            ),
            SelectableText(
              value ?? "",
              style: const TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppConfig.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
