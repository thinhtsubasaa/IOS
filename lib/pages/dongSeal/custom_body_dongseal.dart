import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:Thilogi/blocs/app_bloc.dart';
import 'package:Thilogi/models/checksheet.dart';
import 'package:Thilogi/models/dsdongcontseal.dart';
import 'package:Thilogi/models/huyseal.dart';
import 'package:Thilogi/pages/ds_dongcont/ds_dongcont.dart';
import 'package:Thilogi/utils/delete_dialog.dart';
import 'package:Thilogi/utils/next_screen.dart';
import 'package:Thilogi/widgets/checksheet_upload_anh.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/services/request_helper.dart';
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

import '../../blocs/dongseal_bloc.dart';
import '../../config/config.dart';
import '../../models/danhsachphuongtien.dart';
import '../../models/dongseal.dart';
import '../../models/dsdongcont.dart';
import '../../models/dsxdongcont.dart';

import '../../services/app_service.dart';
import '../../widgets/loading.dart';

class CustomBodyDongSealXe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: BodyBaiXeScreen(
      lstFiles: [],
    ));
  }
}

class BodyBaiXeScreen extends StatefulWidget {
  final List<CheckSheetFileModel?> lstFiles;
  const BodyBaiXeScreen({super.key, required this.lstFiles});

  @override
  _BodyBaiXeScreenState createState() => _BodyBaiXeScreenState();
}

class _BodyBaiXeScreenState extends State<BodyBaiXeScreen> with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();
  String _qrData = '';
  String? SoContId;
  final _qrDataController = TextEditingController();
  String? soCont;
  String? TauId;
  String? viTri;
  final TextEditingController _soSeal = TextEditingController();

  List<DSX_DongContModel>? _dsxdongcontList;
  List<DSX_DongContModel>? get dsxdongcont => _dsxdongcontList;
  List<DS_DongContModel>? _dsdongcontList;
  List<DS_DongContModel>? get dsdongcont => _dsdongcontList;
  List<DS_DongSealModel>? _dsdongsealList;
  List<DS_DongSealModel>? get dsdongseal => _dsdongsealList;

  List<DanhSachPhuongTienModel>? _danhsachphuongtientauList;
  List<DanhSachPhuongTienModel>? get danhsachphuongtientauList => _danhsachphuongtientauList;

  DongSealModel? _data;
  HuySealModel? _datahuy;

  bool _loading = false;
  String? lat;
  String? long;
  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _message;
  String? get message => _message;

  late DongSealBloc _bl;
  Map<String, String> _soContIdMap = {};

  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  final TextEditingController textEditingController = TextEditingController();
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  PickedFile? _pickedFile;
  List<FileItem?> _lstFiles = [];
  final _picker = ImagePicker();
  bool _isAlertShown = false;

  @override
  void initState() {
    super.initState();
    for (var file in widget.lstFiles) {
      _lstFiles.add(FileItem(
        uploaded: true,
        file: file!.path,
        local: false,
        isRemoved: file.isRemoved,
      ));
    }
    _bl = Provider.of<DongSealBloc>(context, listen: false);
    requestLocationPermission();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true); // Lặp lại chuyển đổi màu

    _colorAnimation = ColorTween(
      begin: Colors.redAccent.withOpacity(1), // Màu vàng sáng
      end: Colors.green.withOpacity(1),
    ).animate(_controller);
  }

  @override
  void dispose() {
    textEditingController.dispose();
    _controller.dispose();
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

  void requestLocationPermission() async {
    // Kiểm tra quyền truy cập vị trí
    LocationPermission permission = await Geolocator.checkPermission();
    // Nếu chưa có quyền, yêu cầu quyền truy cập vị trí
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      // Yêu cầu quyền truy cập vị trí
      await Geolocator.requestPermission();
    }
  }

  void getSoCont() async {
    try {
      final http.Response response = await requestHelper.getData('DM_DongCont/GetListContMobi');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        _dsxdongcontList = (decodedData as List).map((item) => DSX_DongContModel.fromJson(item)).toList();

        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Future<void> getDongCont(String SoContId) async {
    try {
      final http.Response response = await requestHelper.getData('DSX_DongCont/Mobi?SoCont_Id=$SoContId');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        _dsdongcontList = (decodedData as List).map((item) => DS_DongContModel.fromJson(item)).toList();

        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Future<void> getListDongSeal(String SoContId) async {
    try {
      final http.Response response = await requestHelper.getData('DSX_DongCont/ListDaDongSeal?SoCont_Id=$SoContId');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        _dsdongsealList = (decodedData["query"] as List).map((item) => DS_DongSealModel.fromJson(item)).toList();

        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Future<void> getData(String SoContId) async {
    _isLoading = true;
    _datahuy = null;
    try {
      final http.Response response = await requestHelper.getData('DSX_DongCont/ListDaDongSeal?SoCont_Id=$SoContId');
      print(response.statusCode);
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("data: ${decodedData}");
        if (decodedData["data"] != null) {
          _datahuy = HuySealModel(
            key: decodedData["data"]["key"],
            id: decodedData["data"]['id'],
            soKhung: decodedData["data"]['soKhung'],
            soCont: decodedData["data"]['soCont'],
            soSeal: decodedData["data"]['soSeal'],
            lat: decodedData["data"]['lat'],
            long: decodedData["data"]['long'],
            toaDo: decodedData["data"]['toaDo'],
            tau: decodedData["data"]['tau'],
          );
        }
      } else {
        String errorMessage = response.body.replaceAll('"', '');
        notifyListeners();
        QuickAlert.show(
          // ignore: use_build_context_synchronously
          context: context,
          type: QuickAlertType.info,
          title: '',
          confirmBtnText: 'Đồng ý',
          text: errorMessage,
        );
        _datahuy = null;
        _isLoading = false;
      }

      notifyListeners();
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
      notifyListeners();
    }
  }

  void getDanhSachPhuongTienTauList() async {
    try {
      final http.Response response = await requestHelper.getData('TMS_DanhSachPhuongTien/Tau');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        _danhsachphuongtientauList = (decodedData as List).map((item) => DanhSachPhuongTienModel.fromJson(item)).toList();
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Future<void> postData(String soSeal, String viTri, String soCont, String TauId, String? file) async {
    _isLoading = true;

    try {
      final http.Response response = await requestHelper.postData('KhoThanhPham/DongSeal?SoSeal=$soSeal&ViTri=$viTri&SoCont=$soCont&TauId=$TauId&File=$file', _data?.toJson());
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
          text: "Đóng seal thành công",
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

  Future<void> HuySealData(String? soSeal, String? viTri, String? soCont, String? Tau, String? file) async {
    _isLoading = true;

    try {
      final http.Response response = await requestHelper.postData('DSX_DongCont/HuyDongSeal?SoSeal=$soSeal&ViTri=$viTri&SoCont=$soCont&Tau=$Tau&File=$file', _datahuy?.toJson());
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
          text: "Hủy đóng seal thành công",
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

  _onSaveHuySeal() async {
    setState(() {
      _loading = true;
    });
    List<String> imageUrls = [];

    for (var fileItem in _lstFiles) {
      if (fileItem?.uploaded == false && fileItem?.isRemoved == false) {
        File file = File(fileItem!.file!);
        var response = await RequestHelper().uploadFile(file);
        widget.lstFiles.add(CheckSheetFileModel(
          isRemoved: response["isRemoved"],
          id: response["id"],
          fileName: response["fileName"],
          path: response["path"],
        ));
        fileItem.uploaded = true;

        fileItem.uploaded = true; // Đánh dấu file đã được upload

        if (response["path"] != null) {
          imageUrls.add(response["path"]);
        }
      }
    }

// Chuyển đổi danh sách URL thành chuỗi cách nhau bởi dấu phẩy
    String? imageUrlsString = imageUrls.join(',');
    _datahuy?.hinhAnh = imageUrlsString;
    Geolocator.getCurrentPosition(
      desiredAccuracy: GeoLocationAccuracy.LocationAccuracy.low,
    ).then((position) {
      setState(() {
        lat = "${position.latitude}";
        long = "${position.longitude}";
      });

      viTri = "${lat},${long}";

      print("viTri: ${viTri}");
      print("soSeal:${_soSeal.text}");
      print("soCont:${soCont}");
      print("TauId: ${TauId}");
      print("SoContId:${SoContId}");

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
          HuySealData(_datahuy?.soSeal ?? "", viTri ?? "", soCont ?? "", _datahuy?.tau ?? "", _datahuy?.hinhAnh ?? "").then((_) {
            setState(() {
              soCont = null;
              _datahuy?.soSeal = null;
              _datahuy?.tau = null;
              _dsdongcontList = null;
              _datahuy = null;
              _lstFiles.clear();
              _qrData = '';
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

          fileItem.uploaded = true; // Đánh dấu file đã được upload

          if (response["path"] != null) {
            imageUrls.add(response["path"]);
          }
        }
      }
    }

// Chuyển đổi danh sách URL thành chuỗi cách nhau bởi dấu phẩy
    String? imageUrlsString = imageUrls.join(',');
    _data?.hinhAnh = imageUrlsString;

    Geolocator.getCurrentPosition(
      desiredAccuracy: GeoLocationAccuracy.LocationAccuracy.low,
    ).then((position) {
      setState(() {
        lat = "${position.latitude}";
        long = "${position.longitude}";
      });

      viTri = "${lat},${long}";
      _data?.soSeal = _soSeal.text;

      print("viTri: ${viTri}");
      print("soSeal:${_soSeal.text}");
      print("soCont:${soCont}");
      print("TauId: ${TauId}");
      print("SoContId:${SoContId}");

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
          postData(_soSeal.text, viTri ?? "", soCont ?? "", TauId ?? "", _data?.hinhAnh ?? "").then((_) {
            setState(() {
              soCont = null;
              _soSeal.text = '';
              TauId = null;
              _dsdongcontList = null;
              _data = null;
              _lstFiles.clear();
              _qrData = '';
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

  void _showConfirmationDialog(BuildContext context) {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        text: 'Bạn có muốn đóng seal không?',
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

  void _showConfirmationDialogHuy(BuildContext context) {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        text: 'Bạn có muốn hủy seal không?',
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
          _onSaveHuySeal();
        });
  }

  Widget _buildTableOptions(BuildContext context) {
    int index = 0; // Biến đếm số thứ tự
    Set<String> uniquePhuongThucSet = {};
    bool isDifferentPhuongThucFound = false;

    // Kiểm tra phương thức khác nhau trước khi tạo bảng
    for (var item in _dsdongcontList ?? []) {
      if (uniquePhuongThucSet.isNotEmpty && !uniquePhuongThucSet.contains(item.phuongThuc)) {
        setState(() {
          isDifferentPhuongThucFound = true;
        });
        break;
      }
      uniquePhuongThucSet.add(item.phuongThuc ?? "");
    }

    return Container(
      width: MediaQuery.of(context).size.width * 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDifferentPhuongThucFound && !_isAlertShown)
            AnimatedBuilder(
              animation: _colorAnimation,
              builder: (context, child) {
                return Text(
                  'Phát hiện các xe có PHƯƠNG THỨC ĐI TÀU khác nhau',
                  style: TextStyle(
                    fontFamily: 'Comfortaa',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _colorAnimation.value,
                  ),
                );
              },
            ),
          Text(
            'Danh sách xe : ${_dsdongcontList?.length.toString() ?? ''}',
            style: const TextStyle(
              fontFamily: 'Comfortaa',
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Table(
            border: TableBorder.all(),
            columnWidths: const {
              0: FlexColumnWidth(0.3),
              1: FlexColumnWidth(0.33),
              2: FlexColumnWidth(0.37),
            },
            children: [
              TableRow(
                children: [
                  Container(
                    color: Colors.red,
                    child: _buildTableCell('Phương thức', textColor: Colors.white),
                  ),
                  Container(
                    color: Colors.red,
                    child: _buildTableCell('Số Khung', textColor: Colors.white),
                  ),
                  Container(
                    color: Colors.red,
                    child: _buildTableCell('Loại Xe', textColor: Colors.white),
                  ),
                ],
              ),
              ..._dsdongcontList?.map((item) {
                    index++; // Tăng số thứ tự sau mỗi lần lặp
                    // bool isBackgroundRed = _dsdongcontList!.length > 2 && uniquePhuongThucSet.isNotEmpty && !uniquePhuongThucSet.contains(item.phuongThuc);

                    // // Thêm `phuongThuc` vào `Set`
                    // uniquePhuongThucSet.add(item.phuongThuc ?? "");

                    return TableRow(
                      // decoration: BoxDecoration(
                      //   color: isBackgroundRed ? Colors.yellow.withOpacity(0.4) : Colors.white, // Màu nền thay đổi theo giá trị isCheck
                      // ),
                      children: [
                        // _buildTableCell(index.toString()), // Số thứ tự
                        _buildTableCell(item.phuongThuc ?? ""),
                        _buildTableCell(item.soKhung ?? ""),
                        _buildTableCell(item.loaiXe ?? ""),
                      ],
                    );
                  }).toList() ??
                  [],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableOptionsDS(BuildContext context) {
    int index = 0;
    return Container(
      width: 100.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedBuilder(
            animation: _colorAnimation,
            builder: (context, child) {
              return Text(
                'Các xe này đã đóng seal, bạn có thể hủy seal',
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _colorAnimation.value, // Đổi màu chữ theo animation
                ),
              );
            },
          ),
          Text(
            'Danh sách xe : ${_dsdongsealList?.length.toString() ?? ''}',
            style: const TextStyle(
              fontFamily: 'Comfortaa',
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Table(
            border: TableBorder.all(),
            columnWidths: {
              0: FlexColumnWidth(0.5),
              1: FlexColumnWidth(0.5),
            },
            children: [
              TableRow(
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.red,
                    child: _buildTableCell('Loại Xe', textColor: Colors.white),
                  ),
                  Container(
                    color: Colors.red,
                    child: _buildTableCell('Số Khung', textColor: Colors.white),
                  ),
                ],
              ),
              ..._dsdongsealList?.map((item) {
                    index++; // Tăng số thứ tự sau mỗi lần lặp

                    return TableRow(
                      children: [
                        // _buildTableCell(index.toString()), // Số thứ tự
                        _buildTableCell(item.loaiXe ?? ""),
                        _buildTableCell(item.soKhung ?? ""),
                      ],
                    );
                  }).toList() ??
                  [],
              // TableRow(
              //   children: [
              //     _buildTableCell('Tổng số', textColor: Colors.red),
              //     _buildTableCell(_dsdongcontList?.length.toString() ?? ''),
              //   ],
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String content, {Color textColor = Colors.black}) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Text(
        content,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Comfortaa',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    getSoCont();
    getDanhSachPhuongTienTauList();
    _dsxdongcontList?.forEach((item) {
      _soContIdMap[item.soCont ?? ""] = item.id ?? ""; // Thêm cặp giá trị vào Map
    });
    final AppBloc ab = context.watch<AppBloc>();
    return Container(
        child: Column(
      children: [
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
                                      // Hành động khi nhấn vào icon
                                      nextScreen(context, LSDaDongContPage());
                                    },
                                  ),
                                ],
                              ),
                              Divider(height: 1, color: Color(0xFFA71C20)),
                              SizedBox(height: 5),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                                              "Số Cont",
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
                                                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height < 600 ? 0 : 5),
                                                child: DropdownButtonHideUnderline(
                                                  child: DropdownButton2<String>(
                                                    isExpanded: true,
                                                    // items: _dsxdongcontList
                                                    //     ?.map((item) {

                                                    items: _soContIdMap.keys.map((String soCont) {
                                                      return DropdownMenuItem<String>(
                                                        value: soCont,
                                                        child: Container(
                                                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
                                                          child: SingleChildScrollView(
                                                            scrollDirection: Axis.horizontal,
                                                            child: Text(
                                                              soCont ?? "",
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
                                                    value: soCont,
                                                    onChanged: (newValue) async {
                                                      setState(() {
                                                        soCont = newValue;
                                                        SoContId = _soContIdMap[newValue];
                                                      });
                                                      if (newValue != null) {
                                                        getData(SoContId ?? "");
                                                        await getDongCont(SoContId ?? "");
                                                        await getListDongSeal(SoContId ?? "");
                                                        print("object: ${SoContId}");
                                                        print("dsdongcont : ${_dsdongcontList}");
                                                        print("dsdongseal : ${_dsdongsealList}");
                                                      }
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
                                                            hintText: 'Tìm số cont',
                                                            hintStyle: const TextStyle(fontSize: 12),
                                                            border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(8),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      searchMatchFn: (item, searchValue) {
                                                        return item.value.toString().toLowerCase().contains(searchValue.toLowerCase());
                                                      },
                                                    ),
                                                    onMenuStateChange: (isOpen) {
                                                      if (!isOpen) {
                                                        textEditingController.clear();
                                                      }
                                                    },
                                                  ),
                                                ))),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  (_datahuy?.soSeal == null)
                                      ? MyInputWidget(
                                          title: 'Số Seal',
                                          controller: _soSeal,
                                          textStyle: const TextStyle(
                                            fontFamily: 'Comfortaa',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: AppConfig.textInput,
                                          ),
                                        )
                                      : MyDataWidget(
                                          title: 'Số Seal',
                                          data: _datahuy?.soSeal ?? "",
                                          textStyle: const TextStyle(
                                            fontFamily: 'Comfortaa',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppConfig.textInput,
                                          ),
                                        ),
                                  SizedBox(height: 5),
                                  (_datahuy?.tau == null)
                                      ? Container(
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
                                                    "Tàu",
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
                                                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height < 600 ? 0 : 5),
                                                      child: DropdownButtonHideUnderline(
                                                        child: DropdownButton2<String>(
                                                          isExpanded: true,
                                                          items: _danhsachphuongtientauList?.map((item) {
                                                            return DropdownMenuItem<String>(
                                                              value: item.id,
                                                              child: Container(
                                                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
                                                                child: SingleChildScrollView(
                                                                  scrollDirection: Axis.horizontal,
                                                                  child: Text(
                                                                    item.bienSo ?? "",
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
                                                          value: TauId,
                                                          onChanged: (newValue) {
                                                            setState(() {
                                                              TauId = newValue;
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
                                                                  hintText: 'Tìm tên phương tiện',
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
                                                                return _danhsachphuongtientauList?.any((ds) => ds.id == itemId && ds.tenPhuongTien?.toLowerCase().contains(searchValue.toLowerCase()) == true) ?? false;
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
                                                      ))),
                                            ],
                                          ),
                                        )
                                      : MyDataWidget(
                                          title: 'Tàu',
                                          data: _datahuy?.tau ?? "",
                                          textStyle: const TextStyle(
                                            fontFamily: 'Comfortaa',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppConfig.textInput,
                                          ),
                                        ),
                                  SizedBox(height: 4),
                                  _dsdongsealList != null && _dsdongsealList!.isNotEmpty ? _buildTableOptionsDS(context) : _buildTableOptions(context),
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
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
        _dsdongsealList != null && _dsdongsealList!.isNotEmpty
            ? Container(
                padding: const EdgeInsets.all(5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RoundedLoadingButton(
                      child: Text('Hủy seal',
                          style: TextStyle(
                            fontFamily: 'Comfortaa',
                            color: AppConfig.textButton,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          )),
                      controller: _btnController,
                      onPressed: _datahuy?.soSeal != null ? () => _showConfirmationDialogHuy(context) : null,
                    ),
                  ],
                ),
              )
            : Container(
                padding: const EdgeInsets.all(5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RoundedLoadingButton(
                      child: Text('Xác nhận',
                          style: TextStyle(
                            fontFamily: 'Comfortaa',
                            color: AppConfig.textButton,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          )),
                      controller: _btnController,
                      onPressed: soCont != null ? () => _showConfirmationDialog(context) : null,
                    ),
                  ],
                ),
              ),
      ],
    ));
  }
}

class MyInputWidget extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final TextStyle textStyle;

  const MyInputWidget({
    Key? key,
    required this.title,
    required this.controller,
    required this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: Center(
              child: Text(
                title,
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
              padding: EdgeInsets.only(left: 15.sp),
              child: TextFormField(
                controller: controller,
                style: textStyle,
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MyDataWidget extends StatelessWidget {
  final String title;
  final String data; // Dữ liệu hiển thị thay vì controller
  final TextStyle textStyle;

  const MyDataWidget({
    Key? key,
    required this.title,
    required this.data, // Nhận dữ liệu
    required this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: Center(
              child: Text(
                title,
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
              padding: EdgeInsets.only(left: 15.sp),
              child: Text(
                data, // Hiển thị dữ liệu
                style: textStyle,
              ),
            ),
          ),
        ],
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
