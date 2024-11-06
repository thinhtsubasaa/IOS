import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:Thilogi/blocs/app_bloc.dart';
import 'package:Thilogi/blocs/dieuchuyen_bloc.dart';
import 'package:Thilogi/models/checksheet.dart';
import 'package:Thilogi/models/dieuchuyen.dart';
import 'package:Thilogi/models/taixe.dart';
import 'package:Thilogi/pages/lsdieuchuyen/ls_dieuchuyen.dart';
import 'package:Thilogi/utils/delete_dialog.dart';
import 'package:Thilogi/utils/next_screen.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/src/enums/location_accuracy.dart' as GeoLocationAccuracy;
import 'package:Thilogi/services/request_helper.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutter_datawedge/models/scan_result.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../config/config.dart';
import '../../models/baixe.dart';
import '../../models/khoxe.dart';
import '../../models/vitri.dart';
import 'package:http/http.dart' as http;

import '../../services/app_service.dart';
import '../../widgets/checksheet_upload_anh.dart';
import '../../widgets/loading.dart';

class CustomBodyChuyenXe extends StatelessWidget {
  final String? soKhung;
  CustomBodyChuyenXe({this.soKhung});
  @override
  Widget build(BuildContext context) {
    return Container(
        child: BodyChuyenXeScreen(
      soKhung: soKhung,
      lstFiles: [],
    ));
  }
}

class BodyChuyenXeScreen extends StatefulWidget {
  final String? soKhung;
  final List<CheckSheetFileModel?> lstFiles;
  const BodyChuyenXeScreen({super.key, required this.lstFiles, this.soKhung});

  @override
  _BodyChuyenXeScreenState createState() => _BodyChuyenXeScreenState();
}

class _BodyChuyenXeScreenState extends State<BodyChuyenXeScreen> with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  String _qrData = '';
  String? lat;
  String? long;
  String? KhoXeId = "9001663f-0164-477d-b576-09c7541f4cce";
  String? BaiXeId;
  String? ViTriId;
  String? TaiXeId;
  String? tenKhoXeDefault; // Lưu trữ tên kho xe mặc định
  // final _qrDataController = TextEditingController();
  late TextEditingController _qrDataController;
  DieuChuyenModel? _data;
  bool _loading = false;
  String? barcodeScanResult;
  List<KhoXeModel>? _khoxeList;
  List<KhoXeModel>? get khoxeList => _khoxeList;
  List<BaiXeModel>? _baixeList;
  List<BaiXeModel>? get baixeList => _baixeList;

  List<ViTriModel>? _vitriList;
  List<ViTriModel>? get vitriList => _vitriList;
  List<TaiXeModel>? _taixeList;
  List<TaiXeModel>? get taixeList => _taixeList;

  bool _isMovingStarted = false;
  String? _selectedViTri;

  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _success = false;
  bool get success => _success;

  String? _message;
  String? get message => _message;
  late FlutterDataWedge dataWedge;
  late StreamSubscription<ScanResult> scanSubscription;

  late DieuChuyenBloc _bl;
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();

  final TextEditingController textEditingController = TextEditingController();
  final TextEditingController _ghiChu = TextEditingController();
  PickedFile? _pickedFile;
  List<FileItem?> _lstFiles = [];
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _bl = Provider.of<DieuChuyenBloc>(context, listen: false);
    for (var file in widget.lstFiles) {
      _lstFiles.add(FileItem(
        uploaded: true,
        file: file!.path,
        local: false,
        isRemoved: file.isRemoved,
      ));
    }
    getData();
    setState(() {
      if (KhoXeId == "9001663f-0164-477d-b576-09c7541f4cce") {
        getBaiXeList(KhoXeId ?? "");
      }
    });
    requestLocationPermission();
    _checkInternetAndShowAlert();
    _qrDataController = TextEditingController(text: widget.soKhung ?? '');
    if (widget.soKhung != null && widget.soKhung!.isNotEmpty) {
      _handleBarcodeScanResult(widget.soKhung!);
    }
    dataWedge = FlutterDataWedge(profileName: "Example Profile");
    scanSubscription = dataWedge.onScanResult.listen((ScanResult result) {
      setState(() {
        barcodeScanResult = result.data;
      });
      print(barcodeScanResult);
      _handleBarcodeScanResult(barcodeScanResult ?? "");
    });
  }

  void onKhoXeChanged(String? newValue) {
    setState(() {
      KhoXeId = newValue;
    });

    if (newValue != null) {
      getBaiXeList(newValue);
      print("object : ${KhoXeId}");
    }
  }

  void onBaiXeChanged(String? newValue) {
    setState(() {
      BaiXeId = newValue;
    });

    if (newValue != null) {
      getViTriList(newValue);
      print("object2 : ${BaiXeId}");
    }
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

  String formatCurrentDateTime() {
    DateTime now = DateTime.now();
    // Định dạng lại đối tượng DateTime thành chuỗi với định dạng mong muốn
    String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(now);
    return formattedDate;
  }

  @override
  void dispose() {
    textEditingController.dispose();
    _qrDataController.dispose();
    super.dispose();
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

  Future<void> getData() async {
    try {
      final http.Response response = await requestHelper.getData('DM_WMS_Kho_KhoXe/GetKhoLogistic');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        _khoxeList = (decodedData as List).map((item) => KhoXeModel.fromJson(item)).toList();

        // Gọi setState để cập nhật giao diện
        setState(() {
          _loading = false;
        });
        setState(() {
          // Reset ViTri list and selected ViTriId
          // _baixeList = [];
          // KhoXeId = null;
          // BaiXeId = null;
        });
      }
      notifyListeners();
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
      notifyListeners();
    }
  }

  Future<void> getBaiXeList(String KhoXeId) async {
    try {
      final http.Response response = await requestHelper.getData('DM_WMS_Kho_BaiXe?khoXe_Id=$KhoXeId');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("data: ${decodedData}");

        _baixeList = (decodedData as List).map((item) => BaiXeModel.fromJson(item)).toList();
        // Gọi setState để cập nhật giao diện

        setState(() {
          // Reset ViTri list and selected ViTriId
          _vitriList = [];
          BaiXeId = null;
          ViTriId = null;
        });
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Future<void> getViTriList(String BaiXeId) async {
    try {
      final http.Response response = await requestHelper.getData('DM_WMS_Kho_ViTri/Mobi?baiXe_Id=$BaiXeId');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("data: ${decodedData}");
        // Xử lý dữ liệu và cập nhật UI tương ứng với danh sách bãi xe đã lấy được
        _vitriList = (decodedData as List).map((item) => ViTriModel.fromJson(item)).toList();
        // Gọi setState để cập nhật giao diện
        // setState(() {
        //   _loading = true;
        // });
        setState(() {
          // Reset selected ViTriId
          ViTriId = null;
        });
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Future<void> postData(DieuChuyenModel scanData, String ToaDo) async {
    _isLoading = true;

    try {
      var newScanData = scanData;
      newScanData.soKhung = newScanData.soKhung == 'null' ? null : newScanData.soKhung;
      print("print data: ${newScanData.soKhung}");
      final http.Response response = await requestHelper.postData('KhoThanhPham/DieuChuyen_New?ToaDo=$ToaDo', newScanData.toJson());
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        print("data: ${decodedData}");

        notifyListeners();
        _btnController.success();
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: "Thành công",
          text: "Điều chuyển thành công",
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

  // Future imageSelector(BuildContext context, String pickerType) async {
  //   switch (pickerType) {
  //     case "gallery":

  //       /// GALLERY IMAGE PICKER
  //       _pickedFile = await _picker.getImage(source: ImageSource.gallery);
  //       break;

  //     case "camera":

  //       /// CAMERA CAPTURE CODE
  //       _pickedFile = await _picker.getImage(source: ImageSource.camera);
  //       break;
  //   }

  //   if (_pickedFile != null) {
  //     setState(() {
  //       _lstFiles.add(FileItem(
  //         uploaded: false,
  //         file: _pickedFile!.path,
  //         local: true,
  //         isRemoved: false,
  //       ));
  //     });
  //   }
  // }
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

  // Upload image to server and return path(url)
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

  Future<void> BatDauDieuChuyen(DieuChuyenModel scanData, String ToaDo, String? ghiChu, String? file) async {
    _isLoading = true;
    try {
      var newScanData = scanData;
      newScanData.soKhung = newScanData.soKhung == 'null' ? null : newScanData.soKhung;
      print("print data: ${newScanData.soKhung}");
      final http.Response response = await requestHelper.postData('KhoThanhPham/BatDauDieuChuyen?ToaDo=$ToaDo&GhiChu=$ghiChu&File=$file', newScanData.toJson());
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
          title: "Bắt đầu di chuyển",
          text: "Bạn đang di chuyển xe:  ${_data?.soKhung}\n lưu ý xác nhận VỊ TRÍ MỚI khi hoàn thành di chuyển ",
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
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                bottomLeft: Radius.circular(5),
              ),
              color: AppConfig.primaryColor,
            ),
            child: Center(
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
                decoration: InputDecoration(
                  hintText: 'Nhập hoặc quét mã VIN',
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

        if (_bl.dieuchuyen == null) {
          _loading = false;
          _qrData = '';
          _qrDataController.text = '';
          barcodeScanResult = null;
        } else {
          _loading = false;
          _data = _bl.dieuchuyen;
          print("Thoi gian bat dau: ${_data?.thoiGianBatDau}");
          print("Thoi gian ket thuc: ${_data?.thoiGianKetThuc}");
          print("Dang Di chuyen: ${_data?.dangDiChuyen}");
          if (_data?.dangDiChuyen == true) {
            _isMovingStarted = true;
          } else if (_data?.dangDiChuyen == false) {
            _isMovingStarted = false;
          }
        }
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

  _onSave() {
    setState(() {
      _loading = true;
    });

    _data?.khoDen_Id = KhoXeId;
    _data?.baiXe_Id = BaiXeId;
    _data?.viTri_Id = ViTriId;
    _data?.taiXe_Id = TaiXeId;
    _data?.key = _bl.dieuchuyen?.key;
    _data?.id = _bl.dieuchuyen?.id;
    _data?.soKhung = _bl.dieuchuyen?.soKhung;
    _data?.tenSanPham = _bl.dieuchuyen?.tenSanPham;
    _data?.maSanPham = _bl.dieuchuyen?.maSanPham;
    _data?.soMay = _bl.dieuchuyen?.soMay;
    _data?.maMau = _bl.dieuchuyen?.maMau;
    _data?.tenMau = _bl.dieuchuyen?.tenMau;
    _data?.tenKho = _bl.dieuchuyen?.tenKho;
    _data?.tenViTri = _bl.dieuchuyen?.tenViTri;
    _data?.mauSon = _bl.dieuchuyen?.mauSon;
    _data?.ngayNhapKhoView = _bl.dieuchuyen?.ngayNhapKhoView;
    _data?.tenViTri = _bl.dieuchuyen?.tenViTri;
    _data?.mauSon = _bl.dieuchuyen?.mauSon;
    _data?.ngayNhapKhoView = _bl.dieuchuyen?.ngayNhapKhoView;
    _data?.tenTaiXe = _bl.dieuchuyen?.tenTaiXe;
    _data?.ghiChu = _ghiChu.text;
    _data?.donVi = _bl.dieuchuyen?.donVi;

    _data?.thoiGianKetThuc = _bl.dieuchuyen?.thoiGianKetThuc;

    // Get location here
    Geolocator.getCurrentPosition(
      desiredAccuracy: GeoLocationAccuracy.LocationAccuracy.low,
    ).then((position) {
      // Assuming `_data` is not null
      setState(() {
        lat = "${position.latitude}";
        long = "${position.longitude}";
      });
      _data?.toaDo = "${lat}, ${long}";
      print("viTri: ${_data?.toaDo}");
      print("Kho_ID:${_data?.khoDen_Id}");
      print("Bai_ID:${_data?.baiXe_Id}");
      print("ViTri_ID:${_data?.viTri_Id}");
      print("Ghi chu: ${_data?.ghiChu}");

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
          postData(_data!, _data?.toaDo ?? "").then((_) {
            setState(() {
              _data = null;
              KhoXeId = null;
              BaiXeId = null;
              ViTriId = null;

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

  _onSaveBatDau() async {
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
    _data?.key = _bl.dieuchuyen?.key;
    _data?.id = _bl.dieuchuyen?.id;
    _data?.soKhung = _bl.dieuchuyen?.soKhung;
    _data?.tenSanPham = _bl.dieuchuyen?.tenSanPham;
    _data?.maSanPham = _bl.dieuchuyen?.maSanPham;
    _data?.soMay = _bl.dieuchuyen?.soMay;
    _data?.maMau = _bl.dieuchuyen?.maMau;
    _data?.tenMau = _bl.dieuchuyen?.tenMau;
    _data?.tenKho = _bl.dieuchuyen?.tenKho;
    _data?.tenViTri = _bl.dieuchuyen?.tenViTri;
    _data?.mauSon = _bl.dieuchuyen?.mauSon;
    _data?.ngayNhapKhoView = _bl.dieuchuyen?.ngayNhapKhoView;
    _data?.tenViTri = _bl.dieuchuyen?.tenViTri;
    _data?.mauSon = _bl.dieuchuyen?.mauSon;
    _data?.ngayNhapKhoView = _bl.dieuchuyen?.ngayNhapKhoView;
    _data?.tenTaiXe = _bl.dieuchuyen?.tenTaiXe;
    _data?.ghiChu = _ghiChu.text;
    _data?.thoiGianBatDau = _bl.dieuchuyen?.thoiGianBatDau;
    _data?.hinhAnh == imageUrlsString;
    _data?.donVi = _bl.dieuchuyen?.donVi;

    // Get location here
    Geolocator.getCurrentPosition(
      desiredAccuracy: GeoLocationAccuracy.LocationAccuracy.low,
    ).then((position) {
      // Assuming `_data` is not null
      setState(() {
        lat = "${position.latitude}";
        long = "${position.longitude}";
      });
      _data?.toaDo = "${lat}, ${long}";
      print("viTri: ${_data?.toaDo}");
      print("Kho_ID:${_data?.khoDen_Id}");
      print("Bai_ID:${_data?.baiXe_Id}");

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
          BatDauDieuChuyen(_data!, _data?.toaDo ?? "", _ghiChu.text, _data?.hinhAnh ?? "").then((_) {
            setState(() {
              KhoXeId = null;
              BaiXeId = null;
              ViTriId = null;
              _qrData = '';
              _lstFiles.clear();
              _qrDataController.text = '';
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

  void _showConfirmationDialogBatDau(BuildContext context) {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        text: 'Bạn có muốn di chuyển không?',
        title: '',
        confirmBtnText: 'Đồng ý',
        cancelBtnText: 'Không',
        confirmBtnTextStyle: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
        cancelBtnTextStyle: TextStyle(
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
          _onSaveBatDau();
        });
  }

  void _showConfirmationDialog(BuildContext context, String viTri, String Kho) {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        text: 'Vui lòng xác nhận vị trí mới: \n$viTri\n$Kho ',
        title: '',
        confirmBtnText: 'Đồng ý',
        cancelBtnText: 'Không',
        confirmBtnTextStyle: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
        cancelBtnTextStyle: TextStyle(
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

  void _startMoving(BuildContext context) {
    _showConfirmationDialogBatDau(context); // Hiển thị hộp thoại xác nhận
  }

  @override
  Widget build(BuildContext context) {
    final AppBloc ab = context.watch<AppBloc>();
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
                                      nextScreen(context, LSDieuChuyenPage());
                                    },
                                  ),
                                ],
                              ),
                              const Divider(height: 1, color: Color(0xFFA71C20)),
                              const SizedBox(height: 10),
                              Column(
                                children: [
                                  if (_isMovingStarted)
                                    Container(
                                      height: MediaQuery.of(context).size.height < 600 ? 10.h : 7.h,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                          color: const Color(0xFF818180),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 25.w,
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
                                                "Kho đến",
                                                textAlign: TextAlign.left,
                                                style: const TextStyle(
                                                  fontFamily: 'Comfortaa',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  color: AppConfig.textInput,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height < 600 ? 0 : 10),
                                                child: DropdownButtonHideUnderline(
                                                  child: DropdownButton2<String>(
                                                    isExpanded: true,
                                                    items: _khoxeList?.map((item) {
                                                      return DropdownMenuItem<String>(
                                                        value: item.id,
                                                        child: Container(
                                                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
                                                          child: SingleChildScrollView(
                                                            scrollDirection: Axis.horizontal,
                                                            child: Text(
                                                              item.tenKhoXe ?? "",
                                                              textAlign: TextAlign.center,
                                                              style: const TextStyle(
                                                                fontFamily: 'Comfortaa',
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w600,
                                                                color: AppConfig.textInput,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                    value: KhoXeId,
                                                    onChanged: (newValue) {
                                                      onKhoXeChanged(newValue);
                                                      // setState(() {
                                                      //   KhoXeId = newValue;
                                                      // });
                                                      // if (newValue != null) {
                                                      //   getBaiXeList(newValue);
                                                      //   print(
                                                      //       "object : ${KhoXeId}");
                                                      // }
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
                                                            hintText: 'Tìm kho xe',
                                                            hintStyle: const TextStyle(fontSize: 12),
                                                            border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(8),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      searchMatchFn: (item, searchValue) {
                                                        if (item is DropdownMenuItem<String>) {
                                                          // Truy cập vào thuộc tính value để lấy ID của ViTriModel
                                                          String itemId = item.value ?? "";
                                                          // Kiểm tra ID của item có tồn tại trong _vl.vitriList không
                                                          return _khoxeList?.any((khoXe) => khoXe.id == itemId && khoXe.tenKhoXe?.toLowerCase().contains(searchValue.toLowerCase()) == true) ?? false;
                                                        } else {
                                                          return false;
                                                        }
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
                                  const SizedBox(height: 4),
                                  if (_isMovingStarted)
                                    Container(
                                      height: MediaQuery.of(context).size.height < 600 ? 10.h : 7.h,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                          color: const Color(0xFF818180),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 25.w,
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
                                                "Bãi xe đến",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontFamily: 'Comfortaa',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  color: AppConfig.textInput,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height < 600 ? 0 : 10),
                                                child: DropdownButtonHideUnderline(
                                                  child: DropdownButton2<String>(
                                                    isExpanded: true,
                                                    items: _baixeList?.map((item) {
                                                      return DropdownMenuItem<String>(
                                                        value: item.id,
                                                        child: Container(
                                                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
                                                          child: SingleChildScrollView(
                                                            scrollDirection: Axis.horizontal,
                                                            child: Text(
                                                              item.tenBaiXe ?? "",
                                                              textAlign: TextAlign.center,
                                                              style: const TextStyle(
                                                                fontFamily: 'Comfortaa',
                                                                fontSize: 13,
                                                                fontWeight: FontWeight.w600,
                                                                color: AppConfig.textInput,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                    value: BaiXeId,
                                                    onChanged: (newValue) {
                                                      onBaiXeChanged(newValue);
                                                      // setState(() {
                                                      //   BaiXeId = newValue;
                                                      // });
                                                      // if (newValue != null) {
                                                      //   getViTriList(newValue);
                                                      //   print(
                                                      //       "object : ${BaiXeId}");
                                                      // }
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
                                                            hintText: 'Tìm bãi xe',
                                                            hintStyle: const TextStyle(fontSize: 12),
                                                            border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(8),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      searchMatchFn: (item, searchValue) {
                                                        if (item is DropdownMenuItem<String>) {
                                                          // Truy cập vào thuộc tính value để lấy ID của ViTriModel
                                                          String itemId = item.value ?? "";
                                                          // Kiểm tra ID của item có tồn tại trong _vl.vitriList không
                                                          return _baixeList?.any((baiXe) => baiXe.id == itemId && baiXe.tenBaiXe?.toLowerCase().contains(searchValue.toLowerCase()) == true) ?? false;
                                                        } else {
                                                          return false;
                                                        }
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
                                  const SizedBox(height: 4),
                                  if (_isMovingStarted)
                                    Container(
                                      height: MediaQuery.of(context).size.height < 600 ? 10.h : 7.h,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                          color: const Color(0xFF818180),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 25.w,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFF6C6C7),
                                              border: Border(
                                                right: BorderSide(
                                                  color: Color(0xFF818180),
                                                  width: 1,
                                                ),
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                "Vị trí",
                                                textAlign: TextAlign.left,
                                                style: const TextStyle(
                                                  fontFamily: 'Comfortaa',
                                                  fontSize: 16,
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
                                                    items: _vitriList?.map((item) {
                                                      return DropdownMenuItem<String>(
                                                        value: item.id,
                                                        child: Container(
                                                          child: Text(
                                                            item.tenViTri ?? "",
                                                            textAlign: TextAlign.center,
                                                            style: const TextStyle(
                                                              fontFamily: 'Comfortaa',
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.w600,
                                                              color: AppConfig.textInput,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                    value: ViTriId,
                                                    onChanged: (newValue) {
                                                      setState(() {
                                                        ViTriId = newValue;
                                                        _selectedViTri = _vitriList?.firstWhere((item) => item.id == newValue).tenViTri;
                                                      });
                                                      print("object : ${ViTriId}");
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
                                                            hintText: 'Tìm vị trí',
                                                            hintStyle: const TextStyle(fontSize: 12),
                                                            border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(8),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      searchMatchFn: (item, searchValue) {
                                                        if (item is DropdownMenuItem<String>) {
                                                          // Truy cập vào thuộc tính value để lấy ID của ViTriModel
                                                          String itemId = item.value ?? "";
                                                          // Kiểm tra ID của item có tồn tại trong _vl.vitriList không
                                                          return _vitriList?.any((viTri) => viTri.id == itemId && viTri.tenViTri?.toLowerCase().contains(searchValue.toLowerCase()) == true) ?? false;
                                                        } else {
                                                          return false;
                                                        }
                                                      },
                                                    ),
                                                    onMenuStateChange: (isOpen) {
                                                      if (!isOpen) {
                                                        textEditingController.clear();
                                                      }
                                                    },
                                                  ),
                                                )),
                                          )
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              Column(
                                children: [
                                  Container(
                                    child: Column(
                                      children: [
                                        Item(
                                          title: 'Số khung: ',
                                          value: _data?.soKhung,
                                        ),
                                        const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                        Item(
                                          title: 'Phương thức: ',
                                          value: _data?.phuongThuc,
                                        ),
                                        const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                        Item(
                                          title: 'Đơn vị vận chuyển: ',
                                          value: _data?.donVi,
                                        ),
                                        const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                        Container(
                                          height: 7.h,
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
                                                      fontFamily: 'Comfortaa',
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w600,
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
                                          title: 'Kho đi: ',
                                          value: _data?.tenKho ?? "",
                                        ),
                                        const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                        Item(
                                          title: 'Bãi xe đi: ',
                                          value: _data?.tenBaiXe ?? "",
                                        ),
                                        const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                        Item(
                                          title: 'Vị trí: ',
                                          value: _data?.tenViTri ?? "",
                                        ),
                                        const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                        ItemGhiChu(
                                          title: 'Ghi chú: ',
                                          controller: _ghiChu,
                                        ),
                                        const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                        Container(
                                          margin: const EdgeInsets.only(right: 5),
                                          padding: const EdgeInsets.all(10),
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
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
        // Container(
        //   padding: const EdgeInsets.all(5),
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       RoundedLoadingButton(
        //         child: Text('Điều chuyển',
        //             style: TextStyle(
        //               fontFamily: 'Comfortaa',
        //               color: AppConfig.textButton,
        //               fontWeight: FontWeight.w700,
        //               fontSize: 16,
        //             )),
        //         controller: _btnController,
        //         onPressed: ViTriId != null
        //             ? () => _showConfirmationDialog(context)
        //             : null,
        //       ),
        //     ],
        //   ),
        // ),
        Container(
          width: 100.w,
          padding: const EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Chia đều không gian
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isMovingStarted ? Colors.green : Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(35.0), // Đường viền cong
                  ),
                  minimumSize: Size(200, 50), // Kích thước tối thiểu của button
                ),
                onPressed: _isMovingStarted
                    ? null // Không cho phép click khi đang di chuyển
                    : (_data?.soKhung != null ? () => _startMoving(context) : null),
                child: _isMovingStarted
                    ? Text(
                        'Đang di chuyển',
                        style: TextStyle(
                          fontFamily: 'Comfortaa',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      )
                    : Text(
                        'Bắt đầu di chuyển',
                        style: TextStyle(
                          fontFamily: 'Comfortaa',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
              )
                  // child: RoundedLoadingButton(
                  //   child: Text('Bắt đầu di chuyển',
                  //       style: TextStyle(
                  //         fontFamily: 'Comfortaa',
                  //         color: AppConfig.textButton,
                  //         fontWeight: FontWeight.w700,
                  //         fontSize: 16,
                  //       )),
                  //   controller: _btnController,
                  //   onPressed: _data?.soKhung != null
                  //       ? () => _startMoving(context)
                  //       : null,
                  //   successColor: Colors.green, // Thiết lập màu khi thành công
                  //   successIcon: Icons.check, // Icon hiển thị khi thành công
                  //   width: 200,
                  // ),

                  ),
              const SizedBox(width: 4),
              if (_isMovingStarted == true) // Chỉnh lại width thay vì height
                Expanded(
                  child: RoundedLoadingButton(
                      child: Text('Xác nhận',
                          style: TextStyle(
                            fontFamily: 'Comfortaa',
                            color: AppConfig.textButton,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          )),
                      controller: _btnController,
                      onPressed: (ViTriId != null) ? () => _showConfirmationDialog(context, _selectedViTri ?? "", _data?.tenKho ?? "") : null),
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
                fontWeight: FontWeight.w600,
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
            SizedBox(width: 10), // Khoảng cách giữa title và text field
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
