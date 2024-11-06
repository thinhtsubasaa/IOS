import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:Thilogi/blocs/app_bloc.dart';
import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/models/checksheet.dart';
import 'package:Thilogi/models/scan.dart';
import 'package:Thilogi/pages/nhanxe/NhanXe.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:Thilogi/utils/delete_dialog.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/blocs/chucnang.dart';
import 'package:Thilogi/pages/nhanxe/NhanXe3.dart';
import 'package:Thilogi/utils/next_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:sizer/sizer.dart';
import 'package:geolocator_platform_interface/src/enums/location_accuracy.dart' as GeoLocationAccuracy;
import 'package:http/http.dart' as http;

// ignore: use_key_in_widget_constructors, must_be_immutable
class PopUp extends StatefulWidget {
  final List<CheckSheetFileModel?> lstFiles;
  String soKhung;
  String soMay;
  String tenMau;
  String tenSanPham;
  String ngayXuatKhoView;
  String tenTaiXe;
  String ghiChu;
  String tenKho;
  List phuKien;
  final TextEditingController ghiChuController = TextEditingController();
  PopUp(
      {required this.soKhung,
      required this.soMay,
      required this.tenMau,
      required this.tenSanPham,
      required this.ngayXuatKhoView,
      required this.tenTaiXe,
      required this.ghiChu,
      required this.tenKho,
      required this.phuKien,
      required this.lstFiles});

  @override
  _PopUpState createState() => _PopUpState();
}

class _PopUpState extends State<PopUp> with SingleTickerProviderStateMixin, ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();
  late TextEditingController ghiChuController;
  PickedFile? _pickedFile;
  List<FileItem?> _lstFiles = [];
  final _picker = ImagePicker();

  ScanModel? _scan;
  ScanModel? get scan => _scan;

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
  @override
  void initState() {
    super.initState();
    ghiChuController = TextEditingController(text: widget.ghiChu);
    for (var file in widget.lstFiles) {
      _lstFiles.add(FileItem(
        uploaded: true,
        file: file!.path,
        local: false,
        isRemoved: file.isRemoved,
      ));
    }
  }

  @override
  void dispose() {
    ghiChuController.dispose();
    super.dispose();
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

  Future<void> getData(BuildContext context, RoundedLoadingButtonController controller, String soKhung, String toaDo, String? ghiChu, String? hinhAnh) async {
    _isLoading = true;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      // Yêu cầu quyền truy cập vị trí
      await Geolocator.requestPermission();
    }
    // Lấy vị trí hiện tại
    Position? currentPosition;
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
        // setState(() {
        //   _loading = false;
        // });

        fileItem.uploaded = true; // Đánh dấu file đã được upload

        if (response["path"] != null) {
          imageUrls.add(response["path"]);
        }
        // } else if (fileItem?.uploaded == true && fileItem?.file != null) {
        //   imageUrls.add(fileItem.path!); // Nếu đã upload trước đó, chỉ thêm URL
      }
    }

// Chuyển đổi danh sách URL thành chuỗi cách nhau bởi dấu phẩy
    String? imageUrlsString = imageUrls.join(',');

    try {
      currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: GeoLocationAccuracy.LocationAccuracy.low,
      );
      double lat = currentPosition.latitude;
      double long = currentPosition.longitude;
      toaDo = "${lat},${long}";
      hinhAnh = imageUrlsString;

      final http.Response response = await requestHelper.getData('GetDataXeThaPham?keyword=$soKhung&ToaDo=$toaDo&GhiChu=$ghiChu&File=$hinhAnh');
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("data:${decodedData}");
        print("hinhAnh:${hinhAnh}");

        notifyListeners();
        controller.success();
        QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: 'Thành công',
            text: "Nhận xe thành công",
            confirmBtnText: 'Đồng ý',
            onConfirmBtnTap: () {
              clear(context);
            });
        controller.reset();
      } else {
        String errorMessage = response.body.replaceAll('"', '');
        notifyListeners();
        controller.error();
        QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Thất bại',
            text: errorMessage,
            confirmBtnText: 'Đồng ý',
            onConfirmBtnTap: () {
              clear(context);
            });
        print("Toa Do : $toaDo");
        controller.reset();
      }
    } catch (e) {
      _hasError = true;
      _isLoading = false;
      _message = e.toString();
      _errorCode = e.toString();
      notifyListeners();
    }
  }

  void clear(context) async {
    final AppBloc ab = Provider.of<AppBloc>(context, listen: false);
    await ab.clearData().then((_) {
      Navigator.pop(context);
      Navigator.pop(context);
      nextScreenReplace(context, NhanXePage());
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final AppBloc ab = context.watch<AppBloc>();
    return Center(
      child: Container(
        alignment: Alignment.bottomCenter,
        constraints: BoxConstraints(
          maxHeight: screenHeight < 600 ? screenHeight * 0.85 : screenHeight * 0.9, // Đặt chiều cao tối đa của popup là 90% của chiều cao màn hình

          // Đặt chiều cao tối đa của popup là 90% của chiều cao màn hình
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          // color: Colors.white.withOpacity(0.9),
          color: Theme.of(context).colorScheme.onPrimary,
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputFields(),
                    _buildCarDetails(context),
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
                                  // ElevatedButton.icon(
                                  //   style: ElevatedButton.styleFrom(
                                  //     backgroundColor:
                                  //         Color(0xFF00B528),
                                  //   ),
                                  //   onPressed: (_loading ||
                                  //           _allowUploadFile() ==
                                  //               false)
                                  //       ? null
                                  //       : () => _uploadAnh(),
                                  //   icon: const Icon(
                                  //       Icons.cloud_upload),
                                  //   label: const Text("Tải ảnh"),
                                  // ),
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
                    // ),
                  ],
                ),
              ),
            ),
            _buildButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 10.h,
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        color: Colors.red,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 50),
          const Text(
            'NHẬN XE',
            style: TextStyle(
              fontFamily: 'Myriad Pro',
              fontSize: 25,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInputFields() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông Tin Xác Nhận',
            style: TextStyle(
              fontFamily: 'Comfortaa',
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Divider(height: 1, color: Color(0xFFA71C20)),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomInputBox(
                text: "Ngày nhận",
                ngayXuatKhoView: widget.ngayXuatKhoView,
              ),
              const SizedBox(height: 4),
              CustomInputBox(
                text: "Nơi nhận xe",
                tenKho: widget.tenKho,
              ),
              const SizedBox(height: 4),
              CustomInputBox(
                text: "Người nhận",
                tenTaiXe: widget.tenTaiXe,
              ),
              const SizedBox(height: 4),
              CustomInputBox(
                text: "Ghi chú",
                // ghiChu: ghiChu,
                ghiChuController: ghiChuController,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCarDetails(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 10, left: 10, right: 10),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        widget.tenSanPham,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontFamily: 'Coda Caption',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppConfig.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 1, color: Color(0xFFCCCCCC)),
              Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    showInfoXe(
                      'Số khung (VIN):',
                      widget.soKhung,
                    ),
                    showInfoXe(
                      'Màu:',
                      widget.tenMau,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFCCCCCC)),
              Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    showInfoXe(
                      'Nhà máy',
                      widget.tenKho,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFCCCCCC)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    String? toaDo;
    String? hinhAnh;
    final ChucnangBloc _cv = ChucnangBloc();
    final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
    return Container(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              nextScreen(
                context,
                NhanXe3Page(
                  soKhung: widget.soKhung,
                  tenMau: widget.tenMau,
                  tenSanPham: widget.tenSanPham,
                  phuKien: widget.phuKien,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B528),
              fixedSize: Size(MediaQuery.of(context).size.width * 1.0, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    'KIỂM TRA OPTION THEO XE',
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppConfig.textButton,
                    ),
                  ),
                ),
                Expanded(child: Container()),
                const Padding(
                  padding: EdgeInsets.only(right: 5),
                  child: Icon(
                    Icons.edit,
                    color: AppConfig.textButton,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 7),
          RoundedLoadingButton(
            width: MediaQuery.of(context).size.width * 1.0,
            borderRadius: 5,
            elevation: 0,
            color: Color(0xFFE96327),
            child: Text('XÁC NHẬN',
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  color: AppConfig.textButton,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                )),
            controller: _btnController,
            onPressed: () {
              // _cv.getData(context, _btnController, soKhung, toaDo ?? "");
              QuickAlert.show(
                  context: context,
                  type: QuickAlertType.confirm,
                  text: 'Bạn có muốn nhận xe không?',
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
                    getData(context, _btnController, widget.soKhung, toaDo ?? "", ghiChuController.text, hinhAnh ?? "");
                  });
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class CustomInputBox extends StatelessWidget {
  final String text;
  final String? ngayXuatKhoView;
  final String? tenKho;
  final String? tenTaiXe;
  final String? ghiChu;
  final TextEditingController? ghiChuController;

  CustomInputBox({
    required this.text,
    this.ngayXuatKhoView,
    this.tenKho,
    this.tenTaiXe,
    this.ghiChu,
    this.ghiChuController,
  });

  @override
  Widget build(BuildContext context) {
    String displayText = '';
    Widget? inputWidget;

    // Chọn dữ liệu phù hợp để hiển thị
    switch (text) {
      // case 'Ngày nhận':
      //   displayText = ngayXuatKhoView ?? '';
      //   break;
      // case 'Nơi nhận xe':
      //   displayText = tenKho ?? '';
      //   break;
      // case 'Người nhận':
      //   displayText = tenTaiXe ?? '';
      //   break;
      case 'Ngày nhận':
        inputWidget = _buildDisplayBox(ngayXuatKhoView ?? '');
        break;
      case 'Nơi nhận xe':
        inputWidget = _buildDisplayBox(tenKho ?? '');
        break;
      case 'Người nhận':
        inputWidget = _buildDisplayBox(tenTaiXe ?? '');
        break;
      case 'Ghi chú':
        // displayText = ghiChuController?.text ?? "";
        inputWidget = _buildEditableBox(ghiChuController);
        break;
      default:
        break;
    }

    return Container(
      height: 6.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: const Color(0xFF818180),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
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
                  text,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontFamily: 'Comfortaa',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF000000),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              child: Center(
                child: inputWidget,
              ),
            ),
            // child: Container(
            //   color: Colors.white,
            //   child: Center(
            //     child: Text(
            //       displayText,
            //       textAlign: TextAlign.left,
            //       style: const TextStyle(
            //         fontFamily: 'Comfortaa',
            //         fontSize: 12,
            //         fontWeight: FontWeight.w400,
            //         color: Color(0xFF000000),
            //       ),
            //     ),
            //   ),
            // ),
          ),
        ],
      ),
    );
  }
}

Widget _buildDisplayBox(String displayText) {
  return Text(
    displayText,
    textAlign: TextAlign.left,
    style: const TextStyle(
      fontFamily: 'Comfortaa',
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Color(0xFF000000),
    ),
  );
}

Widget _buildEditableBox(TextEditingController? controller) {
  return TextFormField(
    controller: controller,
    decoration: const InputDecoration(
      border: InputBorder.none,
      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
    ),
    style: const TextStyle(
      fontFamily: 'Comfortaa',
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Color(0xFF000000),
    ),
  );
}

Widget showInfoXe(String title, String value) {
  return Container(
    padding: EdgeInsets.only(top: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Comfortaa',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF818180),
          ),
        ),
        SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Comfortaa',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppConfig.primaryColor,
          ),
        )
      ],
    ),
  );
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
