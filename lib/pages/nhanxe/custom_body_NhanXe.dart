import 'dart:async';
import 'dart:convert';
import 'package:Thilogi/pages/lsnhanxe/ls_danhan.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:Thilogi/models/scan.dart';
import 'package:Thilogi/pages/nhanxe/NhanXe2.dart';
import 'package:flutter_datawedge/models/scan_result.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import '../../blocs/scan_bloc.dart';
import '../../blocs/user_bloc.dart';
import '../../config/config.dart';
import '../../models/getdata.dart';
import '../../utils/next_screen.dart';
import '../../widgets/loading.dart';
import 'package:http/http.dart' as http;

class CustomBodyNhanXe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: BodyNhanxeScreen());
  }
}

class BodyNhanxeScreen extends StatefulWidget {
  const BodyNhanxeScreen({Key? key}) : super(key: key);

  @override
  _BodyNhanxeScreenState createState() => _BodyNhanxeScreenState();
}

class _BodyNhanxeScreenState extends State<BodyNhanxeScreen> with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();
  String _qrData = '';
  final _qrDataController = TextEditingController();
  ScanModel? _data;
  DataModel? _model;
  bool _loading = false;

  String? barcodeScanResult;
  late ScanBloc _sb;
  late FlutterDataWedge dataWedge;
  late StreamSubscription<ScanResult> scanSubscription;

  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  @override
  void initState() {
    super.initState();

    _sb = Provider.of<ScanBloc>(context, listen: false);
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

  Widget CardVin() {
    return Container(
      width: MediaQuery.of(context).size.width < 330 ? 100.w : 90.w,
      // width: 100.w,
      height: MediaQuery.of(context).size.height < 885 ? 8.h : 8.h,
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
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                bottomLeft: Radius.circular(5),
              ),
              color: AppConfig.primaryColor,
            ),
            child: Center(
              child: Text(
                'Số khung\n(VIN)'.tr(),
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
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                controller: _qrDataController,
                decoration: InputDecoration(
                  hintText: 'Nhập hoặc quét mã VIN'.tr(),
                ),
                onSubmitted: (value) {
                  _handleBarcodeScanResult(value);
                },
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 15,
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
    setState(() {
      _qrData = '';
      _qrDataController.text = '';
      _data = null;
      _model = null;
      Future.delayed(const Duration(seconds: 1), () {
        _qrData = barcodeScanResult;
        _qrDataController.text = barcodeScanResult;
        _onScan(barcodeScanResult);
      });
    });
  }

  String formatCurrentDateTime() {
    DateTime now = DateTime.now();
    // Định dạng lại đối tượng DateTime thành chuỗi với định dạng mong muốn
    String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(now);
    return formattedDate;
  }

  _onScan(value) {
    setState(() {
      _loading = true;
    });
    _sb.get(context, value).then((_) {
      setState(() {
        _qrData = value;
        print(_sb.data);

        if (_sb.data != null) {
          _model = _sb.data;
          _loading = false;
        } else {
          _qrData = '';
          _qrDataController.text = '';
          barcodeScanResult = null;
          _loading = false;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final UserBloc ub = context.watch<UserBloc>();
    return Container(
        child: Column(
      children: [
        CardVin(),
        const SizedBox(height: 5),
        _loading
            ? LoadingWidget(context)
            : Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: 90.w,
                    margin: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.only(left: 10),
                              child: Text(
                                'Thông Tin Xác Nhận',
                                style: TextStyle(
                                  fontFamily: 'Comfortaa',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.visibility),
                              onPressed: () {
                                // Hành động khi nhấn vào icon
                                nextScreen(context, LSDaNhanPage());
                              },
                            ),
                          ],
                        ),
                        const Divider(height: 1, color: Color(0xFFCCCCCC)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              height: 7.h,
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Text(
                                      'Loại xe: '.tr(),
                                      style: TextStyle(
                                        fontFamily: 'Comfortaa',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF818180),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.68),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: SelectableText(
                                        _model?.tenSanPham ?? '',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontFamily: 'Coda Caption',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppConfig.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 1, color: Color(0xFFCCCCCC)),
                        showInfoXe(
                          'Số khung: ',
                          _model?.soKhung ?? "",
                        ),
                        const Divider(height: 1, color: Color(0xFFCCCCCC)),
                        showInfoXe(
                            'Màu: ',
                            // _data?.tenMau ?? _model?.tenMau ?? "",
                            // _data != null
                            //     ? "${_data?.tenMau ?? ""}(${_data?.maMau ?? ""})"
                            //     : "${_model?.tenMau ?? ""}'(${_model?.maMau ?? ""})'",

                            (_model?.tenMau != null && _model?.maMau != null ? "${_model?.tenMau} (${_model?.maMau})" : "")),
                        const Divider(height: 1, color: Color(0xFFCCCCCC)),
                        showInfoXe(
                          'Nhà máy: ',
                          _model?.tenKho ?? "",
                        ),
                        const Divider(height: 1, color: Color(0xFFCCCCCC)),
                        Container(
                          padding: EdgeInsets.all(10),
                          child: ElevatedButton(
                            onPressed: (_model != null)
                                ? () {
                                    _handleButtonTap(NhanXe2Page(
                                      soKhung: _model?.soKhung ?? "",
                                      soMay: _model?.soMay ?? "",
                                      tenMau: _model?.maMau ?? "",
                                      tenSanPham: _model?.tenSanPham ?? "",
                                      ngayXuatKhoView:
                                          // _data?.ngayXuatKhoView ??
                                          formatCurrentDateTime(),
                                      tenTaiXe:
                                          // _data?.tenTaiXe ??
                                          ub.name ?? "",
                                      ghiChu: _model?.ghiChu ?? "",
                                      tenKho: _model?.tenKho ?? "",
                                      phuKien: _model?.phukien ?? [],
                                    ));
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE96327),
                              fixedSize: Size(85.w, 7.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: Text(
                              'NHẬN XE'.tr(),
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppConfig.textButton,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ],
    ));
  }

  void _handleButtonTap(Widget page) {
    setState(() {
      _loading = true;
    });
    nextScreen(context, page);
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _loading = false;
      });
    });
  }
}

Widget showInfoXe(String title, String value) {
  return Container(
    height: 8.h,
    padding: const EdgeInsets.all(10),
    child: Center(
      child: Row(
        children: [
          Text(
            title.tr(),
            style: TextStyle(
              fontFamily: 'Comfortaa',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF818180),
            ),
          ),
          SelectableText(
            value,
            style: TextStyle(
              fontFamily: 'Comfortaa',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppConfig.primaryColor,
            ),
          ),
        ],
      ),
    ),
  );
}
