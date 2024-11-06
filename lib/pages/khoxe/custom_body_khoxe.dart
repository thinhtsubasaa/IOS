import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:Thilogi/blocs/app_bloc.dart';
import 'package:Thilogi/blocs/xuatkho_bloc.dart';
import 'package:Thilogi/models/checksheet.dart';
import 'package:Thilogi/models/danhsachphuongtien.dart';
import 'package:Thilogi/models/diadiem.dart';
import 'package:Thilogi/models/loaiphuongtien.dart';
import 'package:Thilogi/models/phuongthucvanchuyen.dart';
import 'package:Thilogi/models/xuatkho.dart';
import 'package:Thilogi/pages/ds_vanchuyen/ds_vanchuyen.dart';
import 'package:Thilogi/utils/delete_dialog.dart';
import 'package:Thilogi/utils/next_screen.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutter_datawedge/models/scan_result.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator_platform_interface/src/enums/location_accuracy.dart' as GeoLocationAccuracy;

import '../../config/config.dart';
import '../../models/bienso.dart';
import '../../models/noiden.dart';
import '../../services/app_service.dart';
import '../../widgets/checksheet_upload_anh.dart';
import '../../widgets/loading.dart';

// ignore: use_key_in_widget_constructors
class CustomBodyKhoXe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: BodyKhoXeScreen(
      lstFiles: [],
    ));
  }
}

class BodyKhoXeScreen extends StatefulWidget {
  final List<CheckSheetFileModel?> lstFiles;
  const BodyKhoXeScreen({super.key, required this.lstFiles});

  @override
  // ignore: library_private_types_in_public_api
  _BodyKhoXeScreenState createState() => _BodyKhoXeScreenState();
}

class _BodyKhoXeScreenState extends State<BodyKhoXeScreen> with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  String? lat;
  String? long;
  String _qrData = '';
  final _qrDataController = TextEditingController();
  XuatKhoModel? _data;
  bool _loading = false;
  String? barcodeScanResult;
  String? viTri;

  late XuatKhoBloc _bl;

  List<DiaDiemModel>? _diadiemList;

  List<DiaDiemModel>? get diadiemList => _diadiemList;
  List<PhuongThucVanChuyenModel>? _phuongthucvanchuyenList;
  List<PhuongThucVanChuyenModel>? get phuongthucvanchuyenList => _phuongthucvanchuyenList;
  List<DanhSachPhuongTienModel>? _danhsachphuongtienList;
  List<DanhSachPhuongTienModel>? get danhsachphuongtienList => _danhsachphuongtienList;
  List<LoaiPhuongTienModel>? _loaiphuongtienList;
  List<LoaiPhuongTienModel>? get loaiphuongtienList => _loaiphuongtienList;
  List<NoiDenModel>? _noidenList;
  List<NoiDenModel>? get noidenList => _noidenList;
  List<BienSoModel>? _biensoList;
  List<BienSoModel>? get biensoList => _biensoList;
  bool _hasError = false;
  bool get hasError => _hasError;
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  String? _errorCode;
  String? get errorCode => _errorCode;
  String? _message;
  String? get message => _message;
  late FlutterDataWedge dataWedge;
  late StreamSubscription<ScanResult> scanSubscription;
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  final TextEditingController textEditingController = TextEditingController();
  final TextEditingController _ghiChu = TextEditingController();
  PickedFile? _pickedFile;
  List<FileItem?> _lstFiles = [];
  final _picker = ImagePicker();
  bool _option1 = false;
  bool _option2 = false;

  String? BienSo;
  String? BienSoTam;

  @override
  void initState() {
    super.initState();
    _bl = Provider.of<XuatKhoBloc>(context, listen: false);
    getBienSo();
    getBienSoTam();
    for (var file in widget.lstFiles) {
      _lstFiles.add(FileItem(
        uploaded: true,
        file: file!.path,
        local: false,
        isRemoved: file.isRemoved,
      ));
    }
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
    textEditingController.dispose();
    super.dispose();
  }

  Future imageSelector(BuildContext context, String pickerType) async {
    if (pickerType == "gallery") {
      // Chọn nhiều ảnh từ thư viện
      List<Asset> resultList = <Asset>[];

      try {
        resultList = await MultiImagePicker.pickImages(
          maxImages: 100, // Số lượng ảnh tối đa bạn có thể chọn
          enableCamera: false, // Bật tính năng chụp ảnh nếu cần
          selectedAssets: [], // Các ảnh đã chọn (nếu có)
          materialOptions: const MaterialOptions(
            actionBarTitle: "Chọn ảnh",
            allViewTitle: "Tất cả ảnh",
            useDetailsView: false,
            selectCircleStrokeColor: "#000000",
          ),
        );

        if (resultList.isNotEmpty) {
          // Thêm các ảnh đã chọn vào danh sách _lstFiles

          for (var asset in resultList) {
            ByteData byteData = await asset.getByteData();
            List<int> imageData = byteData.buffer.asUint8List();

            // Lưu ảnh vào thư mục tạm
            final tempDir = await getTemporaryDirectory();
            final file = await File('${tempDir.path}/${asset.name}').create();
            file.writeAsBytesSync(imageData);

            print('file: ${file.path}');
            setState(() {
              _lstFiles.add(FileItem(
                uploaded: false,
                file: file.path, // Đường dẫn file tạm
                local: true,
                isRemoved: false,
              ));
            });
          }
        }
      } on Exception catch (e) {
        print(e);
      }
    } else if (pickerType == "camera") {
      // Sử dụng image_picker để chụp ảnh từ camera
      _pickedFile = await _picker.getImage(source: ImageSource.camera);

      if (_pickedFile != null) {
        setState(() {
          _lstFiles.add(FileItem(
            uploaded: false,
            file: _pickedFile!.path,
            local: true,
            isRemoved: false,
          ));
        });
      }
    }
  }

  Future<void> _uploadAnh() async {
    for (var fileItem in _lstFiles) {
      if (fileItem!.uploaded == false && fileItem.isRemoved == false) {
        setState(() {
          _loading = true;
        });
        File file = File(fileItem.file!);
        var response = await RequestHelper().uploadFile(file);
        widget.lstFiles.add(CheckSheetFileModel(
          isRemoved: response["isRemoved"],
          id: response["id"],
          fileName: response["fileName"],
          path: response["path"],
        ));
        fileItem.uploaded = true;
        setState(() {
          _loading = false;
        });
      }
    }
  }

  bool _allowUploadFile() {
    var item = _lstFiles.firstWhere(
      (file) => file!.uploaded == false,
      orElse: () => null,
    );
    if (item == null) {
      return false;
    }
    return true;
  }

  _removeImage(FileItem image) {
    // find and remove
    // if don't have
    setState(() {
      _lstFiles.removeWhere((img) => img!.file == image.file);
      // check item exists in widget.lstFiles
      if (image.local == true) {
        widget.lstFiles.removeWhere((img) => img!.path == image.file);
      } else {
        widget.lstFiles.map((file) {
          if (file!.path == image.file) {
            file.isRemoved = true;
            return file;
          }
        }).toList();
      }

      Navigator.pop(context);
    });
  }

  bool _isEmptyLstFile() {
    var isRemoved = false;
    if (_lstFiles.isEmpty) {
      isRemoved = true;
    } else {
      // find in list don't have isRemoved = false and have isRemoved = true
      var tmp = _lstFiles.firstWhere((file) => file!.isRemoved == false, orElse: () => null);
      if (tmp == null) {
        isRemoved = true;
      }
    }
    return isRemoved;
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

  Future<void> postData(XuatKhoModel scanData, String viTri, String? ghiChu, String? file, String? bienSo, String? bienSoTam) async {
    _isLoading = true;

    try {
      var newScanData = scanData;
      newScanData.soKhung = newScanData.soKhung == 'null' ? null : newScanData.soKhung;
      print("print data: ${newScanData.soKhung}");
      final http.Response response = await requestHelper.postData('KhoThanhPham/XuatKho?ToaDo=$viTri&GhiChu=$ghiChu&File=$file&BienSo=$bienSo&BienSoTam=$bienSoTam', newScanData.toJson());
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        print("data: ${decodedData}");

        notifyListeners();
        _btnController.success();
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Thành công',
          text: "Xuất kho thành công",
          confirmBtnText: 'Đồng ý',
        );
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
      height: MediaQuery.of(context).size.height < 880 ? 8.h : 8.h,
      margin: const EdgeInsets.only(top: 3),
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
            height: 10.h,
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
              padding: EdgeInsets.symmetric(horizontal: 10),
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

  Future<File> compressImage(File file) async {
    setState(() {
      _loading = true;
    });

    final bytes = await file.readAsBytes();
    final String extension = file.path.split('.').last.toLowerCase();
    CompressFormat format;

    // Xác định định dạng dựa trên phần mở rộng của tệp
    switch (extension) {
      case 'png':
        format = CompressFormat.png; // Định dạng PNG
        break;

      case 'jpeg':
        format = CompressFormat.jpeg; // Định dạng JPEG
        break;

      case 'jpg':
        format = CompressFormat.jpeg; // Định dạng JPG cũng coi như JPEG
        break;

      default:
        throw Exception('Unsupported file format'); // Nếu không hỗ trợ
    }

    try {
      final compressedBytes = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: 800,
        minHeight: 800,
        quality: 90,
        format: format, // Sử dụng định dạng đã xác định
      );

      final newFile = File(file.path)..writeAsBytesSync(compressedBytes);
      return newFile;
    } catch (e) {
      print("Error compressing image: $e"); // Ghi log lỗi
      return file; // Trả về tệp gốc nếu gặp lỗi
    }
  }

  _onSave() async {
    setState(() {
      _loading = true;
    });
    List<String> imageUrls = [];

    for (var fileItem in _lstFiles) {
      if (fileItem?.uploaded == false && fileItem?.isRemoved == false) {
        File file = File(fileItem!.file!);
        if (file.existsSync()) {
          file = await compressImage(file);
        }

        var response = await RequestHelper().uploadFile(file);
        print("Response: $response");
        if (response != null) {
          widget.lstFiles.add(CheckSheetFileModel(
            isRemoved: response["isRemoved"],
            id: response["id"],
            fileName: response["fileName"],
            path: response["path"],
          ));
          fileItem.uploaded = true;
          setState(() {
            _loading = false;
          });

          fileItem.uploaded = true;

          if (response["path"] != null) {
            imageUrls.add(response["path"]);
          }
          // } else if (fileItem?.uploaded == true && fileItem?.file != null) {
          //   imageUrls.add(fileItem.path!); // Nếu đã upload trước đó, chỉ thêm URL
        }
      }
    }

// Chuyển đổi danh sách URL thành chuỗi cách nhau bởi dấu phẩy
    String? imageUrlsString = imageUrls.join(',');
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
    _data?.ghiChu = _ghiChu.text;
    _data?.bienSo_Id = _bl.xuatkho?.bienSo_Id;
    _data?.taiXe_Id = _bl.xuatkho?.taiXe_Id;
    _data?.tenDiaDiem = _bl.xuatkho?.tenDiaDiem;
    _data?.tenPhuongThucVanChuyen = _bl.xuatkho?.tenPhuongThucVanChuyen;
    _data?.hinhAnh = imageUrlsString;
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
          postData(_data!, viTri ?? "", _ghiChu.text, _data?.hinhAnh ?? "", BienSo ?? "", BienSoTam ?? "").then((_) {
            setState(() {
              _data = null;
              _ghiChu.text = '';
              barcodeScanResult = null;
              _qrData = '';
              _qrDataController.text = '';
              _lstFiles.clear();
              _loading = false;
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

  void _showConfirmationDialog(BuildContext context) {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        text: 'Bạn có muốn vận chuyển không?',
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
          _onSave();
        });
  }

  Future<void> getBienSo() async {
    try {
      final http.Response response = await requestHelper.getData('TMS_DanhSachPhuongTien/DuongBo');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        _noidenList = (decodedData as List).map((item) => NoiDenModel.fromJson(item)).toList();

        // Gọi setState để cập nhật giao diện
        setState(() {
          BienSo = null;
          _loading = false;
        });
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Future<void> getBienSoTam() async {
    try {
      final http.Response response = await requestHelper.getData('BienSoTam');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        _biensoList = (decodedData as List).map((item) => BienSoModel.fromJson(item)).toList();

        // Gọi setState để cập nhật giao diện
        setState(() {
          BienSoTam = null;
          _loading = false;
        });
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppBloc ab = context.watch<AppBloc>();
    return Container(
        child: Column(
      children: [
        if (_option1 && BienSo != null || _option2 && BienSoTam != null) CardVin(),
        Row(
          children: [
            Checkbox(
              value: _option1,
              onChanged: (bool? value) {
                setState(() {
                  _option1 = value ?? false;
                  if (_option1) {
                    _option2 = false; // Bỏ chọn _option2 khi _option1 được tick
                  }
                });
              },
            ),
            const Text(
              "Xe lồng",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF818180),
              ),
            ),
            Checkbox(
              value: _option2,
              onChanged: (bool? value) {
                setState(() {
                  _option2 = value ?? false;
                  if (_option2) {
                    _option1 = false; // Bỏ chọn _option1 khi _option2 được tick
                  }
                });
              },
            ),
            const Text(
              "Trung chuyển",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF818180),
              ),
            ),
          ],
        ),
        if (_option1)
          Container(
            height: MediaQuery.of(context).size.height < 600 ? 10.h : 5.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: const Color(0xFFBC2925),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 20.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF6C6C7),
                    border: Border(
                      right: BorderSide(
                        color: Color(0xFF818180),
                        width: 1,
                      ),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "Biển số",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: 'Comfortaa',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppConfig.textInput,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height < 600 ? 0 : 5),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          items: _noidenList?.map((item) {
                            return DropdownMenuItem<String>(
                              value: item.bienSo,
                              child: Container(
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Text(
                                    item.bienSo ?? "",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'Comfortaa',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppConfig.textInput,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          value: BienSo,
                          onChanged: (newValue) {
                            setState(() {
                              BienSo = newValue;
                            });
                          },
                          buttonStyleData: const ButtonStyleData(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            height: 40,
                            width: 200,
                          ),
                          dropdownStyleData: const DropdownStyleData(
                            maxHeight: 200,
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            height: 40,
                          ),
                          dropdownSearchData: DropdownSearchData(
                            searchController: textEditingController,
                            searchInnerWidgetHeight: 50,
                            searchInnerWidget: Container(
                              height: 50,
                              padding: const EdgeInsets.only(
                                top: 8,
                                bottom: 4,
                                right: 8,
                                left: 8,
                              ),
                              child: TextFormField(
                                expands: true,
                                maxLines: null,
                                controller: textEditingController,
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  hintText: 'Tìm biển số',
                                  hintStyle: const TextStyle(fontSize: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            searchMatchFn: (item, searchValue) {
                              final itemValue = item.value?.toLowerCase().toString() ?? ''; // Kiểm tra null
                              return itemValue.contains(searchValue.toLowerCase());
                            },
                          ),
                          onMenuStateChange: (isOpen) {
                            if (!isOpen) {
                              textEditingController.clear();
                            }
                          },
                        ),
                      )),
                ),
              ],
            ),
          ),
        if (_option2)
          Container(
            height: MediaQuery.of(context).size.height < 600 ? 10.h : 5.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: const Color(0xFFBC2925),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 20.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF6C6C7),
                    border: Border(
                      right: BorderSide(
                        color: Color(0xFF818180),
                        width: 1,
                      ),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "Biển số tạm",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: 'Comfortaa',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppConfig.textInput,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height < 600 ? 0 : 5),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          items: _biensoList?.map((item) {
                            return DropdownMenuItem<String>(
                              value: item.bienSo,
                              child: Container(
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Text(
                                    item.bienSo ?? "",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'Comfortaa',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppConfig.textInput,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          value: BienSoTam,
                          onChanged: (newValue) {
                            setState(() {
                              BienSoTam = newValue;
                            });
                          },
                          buttonStyleData: const ButtonStyleData(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            height: 40,
                            width: 200,
                          ),
                          dropdownStyleData: const DropdownStyleData(
                            maxHeight: 200,
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            height: 40,
                          ),
                          dropdownSearchData: DropdownSearchData(
                            searchController: textEditingController,
                            searchInnerWidgetHeight: 50,
                            searchInnerWidget: Container(
                              height: 50,
                              padding: const EdgeInsets.only(
                                top: 8,
                                bottom: 4,
                                right: 8,
                                left: 8,
                              ),
                              child: TextFormField(
                                expands: true,
                                maxLines: null,
                                controller: textEditingController,
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  hintText: 'Tìm biển số tạm',
                                  hintStyle: const TextStyle(fontSize: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            searchMatchFn: (item, searchValue) {
                              final itemValue = item.value?.toLowerCase().toString() ?? ''; // Kiểm tra null
                              return itemValue.contains(searchValue.toLowerCase());
                            },
                          ),
                          onMenuStateChange: (isOpen) {
                            if (!isOpen) {
                              textEditingController.clear();
                            }
                          },
                        ),
                      )),
                ),
              ],
            ),
          ),
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
                          padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
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
                                      nextScreen(context, DSVanChuyenPage());
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
                                    Item(
                                      title: 'Số khung: ',
                                      value: _data?.soKhung,
                                    ),
                                    const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                    Item(
                                      title: 'Nơi đi: ',
                                      value: _data?.noidi,
                                    ),
                                    const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                    ItemGiaoXe(
                                      title: 'Nơi đến: ',
                                      value: _data?.noiden,
                                    ),
                                    const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                    Container(
                                      height: 6.h,
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.only(left: 10),
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
                                    ItemGhiChu(
                                      title: 'Ghi chú: ',
                                      controller: _ghiChu,
                                    ),
                                    const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                    Container(
                                      margin: const EdgeInsets.only(right: 5),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.onPrimary,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.87),
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                children: [
                                                  ElevatedButton.icon(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.orangeAccent,
                                                    ),
                                                    onPressed: () => imageSelector(context, 'gallery'),
                                                    icon: const Icon(Icons.photo_library),
                                                    label: const Text(""),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  ElevatedButton.icon(
                                                    style: ElevatedButton.styleFrom(
                                                        // backgroundColor: Theme.of(context).primaryColor,
                                                        ),
                                                    onPressed: () => imageSelector(context, 'camera'),
                                                    icon: const Icon(Icons.camera_alt),
                                                    label: const Text(""),
                                                  ),
                                                  const SizedBox(width: 10),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            "Ảnh đã chọn",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          if (_isEmptyLstFile())
                                            const SizedBox(
                                              height: 100,
                                              // child: Center(child: Text("Chưa có ảnh nào")),
                                            ),
                                          // Display list image
                                          ResponsiveGridRow(
                                            children: _lstFiles.map((image) {
                                              if (image!.isRemoved == false) {
                                                return ResponsiveGridCol(
                                                  xs: 6,
                                                  md: 3,
                                                  child: InkWell(
                                                    onLongPress: () {
                                                      deleteDialog(
                                                        context,
                                                        "Bạn có muốn xoá ảnh này? Việc xoá sẽ không thể quay lại.",
                                                        "Xoá ảnh",
                                                        () => _removeImage(image),
                                                      );
                                                    },
                                                    child: Container(
                                                      margin: const EdgeInsets.only(left: 5),
                                                      child: image.local == true
                                                          ? Image.file(File(image.file!))
                                                          : Image.network(
                                                              '${ab.apiUrl}/${image.file}',
                                                              errorBuilder: ((context, error, stackTrace) {
                                                                return Container(
                                                                  height: 100,
                                                                  decoration: BoxDecoration(
                                                                    border: Border.all(color: Colors.redAccent),
                                                                  ),
                                                                  child: const Center(
                                                                      child: Text(
                                                                    "Error Image (404)",
                                                                    style: TextStyle(color: Colors.redAccent),
                                                                  )),
                                                                );
                                                              }),
                                                            ),
                                                    ),
                                                  ),
                                                );
                                              }
                                              return ResponsiveGridCol(
                                                child: const SizedBox.shrink(),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // CheckSheetUploadAnh(
                                    //   lstFiles: [],
                                    // )
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
          width: 100.w,
          padding: const EdgeInsets.all(5),
          child: Column(
            children: [
              RoundedLoadingButton(
                child: Text('Xuất kho',
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      color: AppConfig.textButton,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    )),
                controller: _btnController,
                onPressed: _data?.soKhung != null ? () => _showConfirmationDialog(context) : null,
              ),
            ],
          ),
        ),
      ],
    ));
  }
}

class ItemGiaoXe extends StatelessWidget {
  final String title;
  final String? value;

  const ItemGiaoXe({
    Key? key,
    required this.title,
    this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: value != null ? Colors.red : Theme.of(context).colorScheme.onPrimary,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
        // color: AppConfig.titleColor,
      ),
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
                fontSize: 15,
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

class ItemGhiChu extends StatelessWidget {
  final String title;
  final TextEditingController controller;

  const ItemGhiChu({
    Key? key,
    required this.title,
    required this.controller,
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
            const SizedBox(width: 10), // Khoảng cách giữa title và text field
            Expanded(
              child: TextField(
                controller: controller,
                style: const TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppConfig.primaryColor,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none, // Loại bỏ đường viền mặc định
                  hintText: '',
                  // contentPadding: EdgeInsets.symmetric(vertical: 9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FileItem {
  bool? uploaded = false;
  String? file;
  bool? local = true;
  bool? isRemoved = false;

  FileItem({
    required this.uploaded,
    required this.file,
    required this.local,
    required this.isRemoved,
  });
}
