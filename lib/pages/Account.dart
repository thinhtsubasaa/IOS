// import 'package:Thilogi/pages/qrcode.dart';
// import 'package:Thilogi/utils/next_screen.dart';
// import 'package:Thilogi/widgets/divider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_icons/flutter_icons.dart';
// import 'package:provider/provider.dart';
// import 'package:sizer/sizer.dart';
// import '../../widgets/custom_appbar.dart';
// import '../../widgets/custom_card.dart';
// import '../../widgets/custom_title.dart';
// import '../blocs/user_bloc.dart';

// class AccountPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: customAppBar(context),
//       body: Column(
//         children: [
//           CustomCard(),
//           Expanded(
//             child: Container(
//               width: 100.w,
//               decoration: BoxDecoration(
//                 color: Theme.of(context).colorScheme.onPrimary,
//               ),
//               child: CustomBodyAccount(),
//             ),
//           ),
//           BottomContent(),
//         ],
//       ),
//     );
//   }
// }

// class CustomBodyAccount extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(child: BodyAccountScreen());
//   }
// }

// class BodyAccountScreen extends StatefulWidget {
//   const BodyAccountScreen({Key? key}) : super(key: key);

//   @override
//   _BodyAccountScreenState createState() => _BodyAccountScreenState();
// }

// class _BodyAccountScreenState extends State<BodyAccountScreen>
//     with SingleTickerProviderStateMixin {
//   late UserBloc? ub;

//   @override
//   void initState() {
//     super.initState();
//     ub = Provider.of<UserBloc>(context, listen: false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Container(
//         child: Column(children: [
//           const SizedBox(height: 5),
//           Center(
//             child: Container(
//               alignment: Alignment.bottomCenter,
//               decoration: BoxDecoration(
//                 color: Theme.of(context).colorScheme.onPrimary,
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             const Text(
//                               'Thông Tin Cá Nhân',
//                               style: TextStyle(
//                                 fontFamily: 'Comfortaa',
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.qr_code),
//                               onPressed: () {
//                                 nextScreen(context, qrCode());
//                               },
//                             ),
//                           ],
//                         ),
//                         const Divider(height: 1, color: Color(0xFFA71C20)),
//                         const SizedBox(height: 10),
//                         Column(
//                           children: [
//                             ListTile(
//                               contentPadding: EdgeInsets.all(0),
//                               title: Container(
//                                 width: 200,
//                                 height: 200,
//                                 child: Image.network(
//                                   ub?.hinhAnhUrl ?? "",
//                                   fit: BoxFit.contain,
//                                 ),
//                               ),
//                             ),
//                             const DividerWidget(),
//                             ListTile(
//                               contentPadding: const EdgeInsets.all(0),
//                               leading: const CircleAvatar(
//                                 backgroundColor: Colors.blueAccent,
//                                 radius: 18,
//                                 child: Icon(
//                                   Feather.user_check,
//                                   size: 18,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                               title: Text(
//                                 ub?.name ?? "",
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w500,
//                                   color: Theme.of(context).colorScheme.primary,
//                                 ),
//                               ),
//                             ),
//                             const DividerWidget(),
//                             ListTile(
//                               contentPadding: const EdgeInsets.all(0),
//                               leading: const CircleAvatar(
//                                 backgroundColor: Colors.blueAccent,
//                                 radius: 18,
//                                 child: Icon(
//                                   Feather.user_plus,
//                                   size: 18,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                               title: Text(
//                                 ub?.accessRole ?? "",
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w500,
//                                   color: Theme.of(context).colorScheme.primary,
//                                 ),
//                               ),
//                             ),
//                             const DividerWidget(),
//                             ListTile(
//                               contentPadding: const EdgeInsets.all(0),
//                               leading: CircleAvatar(
//                                 backgroundColor: Colors.indigoAccent[100],
//                                 radius: 18,
//                                 child: const Icon(
//                                   Feather.mail,
//                                   size: 18,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                               title: Text(
//                                 ub?.email ?? "",
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w500,
//                                   color: Theme.of(context).colorScheme.primary,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ]),
//       ),
//     );
//   }
// }

// class BottomContent extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: MediaQuery.of(context).size.width,
//       height: MediaQuery.of(context).size.height / 11,
//       padding: EdgeInsets.all(10),
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//           colors: [
//             Color(0xFFE96327),
//             Color(0xFFBC2925),
//           ],
//         ),
//       ),
//       child: Center(
//         child: customTitle(
//           'KIỂM TRA - THÔNG TIN CÁ NHÂN',
//         ),
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'dart:io';

import 'package:Thilogi/blocs/app_bloc.dart';
import 'package:Thilogi/models/checksheet.dart';

import 'package:Thilogi/models/xeracong.dart';
import 'package:Thilogi/pages/qrcode.dart';
import 'package:Thilogi/services/app_service.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:Thilogi/utils/delete_dialog.dart';
import 'package:Thilogi/utils/next_screen.dart';
import 'package:Thilogi/widgets/divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:sizer/sizer.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_title.dart';
import '../blocs/user_bloc.dart';

class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context),
      body: Column(
        children: [
          CustomCard(),
          Expanded(
            child: Container(
              width: 100.w,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              child: CustomBodyAccount(),
            ),
          ),
          BottomContent(),
        ],
      ),
    );
  }
}

class CustomBodyAccount extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: BodyAccountScreen(
      lstFiles: [],
    ));
  }
}

class BodyAccountScreen extends StatefulWidget {
  final List<CheckSheetFileModel?> lstFiles;
  const BodyAccountScreen({super.key, required this.lstFiles});

  @override
  _BodyAccountScreenState createState() => _BodyAccountScreenState();
}

class _BodyAccountScreenState extends State<BodyAccountScreen> with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();
  late UserBloc? ub;
  late AppBloc? ab;
  File? _imageFile;
  PickedFile? _pickedFile;
  List<FileItem?> _lstFiles = [];
  final _picker = ImagePicker();
  String? imageUrl;
  late bool _loading = false;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  XeRaCongModel? _data;
  String? _message;
  String? get message => _message;
  bool _hasError = false;
  bool get hasError => _hasError;
  @override
  void initState() {
    super.initState();
    ub = Provider.of<UserBloc>(context, listen: false);
    ab = Provider.of<AppBloc>(context, listen: false);

    for (var file in widget.lstFiles) {
      _lstFiles.add(FileItem(
        uploaded: true,
        file: file!.path,
        local: false,
        isRemoved: file.isRemoved,
      ));
    }
  }

  Future imageSelector(BuildContext context, String pickerType) async {
    switch (pickerType) {
      case "gallery":

        /// GALLERY IMAGE PICKER
        _pickedFile = await _picker.getImage(source: ImageSource.gallery);
        break;

      case "camera":

        /// CAMERA CAPTURE CODE
        _pickedFile = await _picker.getImage(source: ImageSource.camera);
        break;
    }

    if (_pickedFile != null) {
      setState(() {
        _lstFiles.add(FileItem(
          uploaded: false,
          file: _pickedFile!.path,
          local: true,
          isRemoved: false,
        ));

        _loading = true;
        print("loading: ${_loading}");
      });

      print("url: ${_lstFiles}");
    }
  }

  Future<void> postData(XeRaCongModel? scanData, String? file) async {
    _isLoading = true;

    try {
      var newScanData = scanData;

      print("print data: ${newScanData?.soKhung}");
      final http.Response response = await requestHelper.postData('KhoThanhPham/Account?File=$file', newScanData?.toJson());
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("data: ${decodedData}");
        notifyListeners();
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Thành công',
          text: "Đổi Avatar thành công",
          confirmBtnText: 'Đồng ý',
        );
        ub?.hinhAnhUrl = imageUrl;
        clear(context);
      } else {}
    } catch (e) {
      _message = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear(context) async {
    Navigator.pop(context);
    Navigator.pop(context);
    nextScreenReplace(context, AccountPage());
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
        var response = await RequestHelper().uploadAvatar(file);
        print("Response: $response");
        if (response != null) {
          widget.lstFiles.add(CheckSheetFileModel(
            isRemoved: response["isRemoved"],
            id: response["id"],
            fileName: response["fileName"],
            path: response["path"],
          ));
          fileItem.uploaded = true;
          if (response["path"] != null) {
            imageUrls.add(response["path"]);
          }
          // setState(() {
          //   _loading = false;
          // });

          // fileItem.uploaded = true; // Đánh dấu file đã được upload

          // } else if (fileItem?.uploaded == true && fileItem?.file != null) {
          //   imageUrls.add(fileItem.path!); // Nếu đã upload trước đó, chỉ thêm URL
        }
      }
    }

// Chuyển đổi danh sách URL thành chuỗi cách nhau bởi dấu phẩy
    String? imageUrlsString = imageUrls.join(',');
    print("url: ${imageUrlsString}");
    imageUrl = imageUrlsString;

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
        postData(_data, imageUrlsString).then((_) {
          print("loading: ${_loading}");
          setState(() {
            _lstFiles.clear();
            _loading = false;
          });
        });
      }
    });
  }

  Future<void> _uploadAnh() async {
    for (var fileItem in _lstFiles) {
      if (fileItem!.uploaded == false && fileItem.isRemoved == false) {
        setState(() {
          _loading = true;
        });
        File file = File(fileItem.file!);
        var response = await RequestHelper().uploadAvatar(file);
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

  void showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          children: <Widget>[
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
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF00B528),
                      ),
                      onPressed: (_loading == false) ? null : () => _onSave(),
                      // onPressed: () => _onSave(),
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text("Lưu"),
                    ),
                  ],
                ),
              ),
            ),

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
                                '${ab?.apiUrl}/${image.file}',
                                errorBuilder: ((context, error, stackTrace) {
                                  return Container(
                                    height: 70,
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(children: [
          const SizedBox(height: 5),
          Center(
            child: Container(
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Thông Tin Cá Nhân',
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.qr_code),
                              onPressed: () {
                                nextScreen(context, qrCode());
                              },
                            ),
                          ],
                        ),
                        const Divider(height: 1, color: Color(0xFFA71C20)),
                        const SizedBox(height: 10),
                        Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.all(0),
                              title: Container(
                                width: 200,
                                height: 200,
                                child: Stack(
                                  children: [
                                    // Hiển thị hình ảnh
                                    Positioned.fill(
                                      child: imageUrl != null
                                          ? Image.network(
                                              imageUrl ?? "", // Hiển thị ảnh đã chọn
                                              fit: BoxFit.contain,
                                            )
                                          : Image.network(
                                              ub?.hinhAnhUrl ?? "", // Hiển thị ảnh từ URL nếu không có ảnh chọn
                                              fit: BoxFit.contain,
                                            ),
                                    ),
                                    // Đặt Icon edit ở góc trên phải
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () {
                                          showMenu(context);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const DividerWidget(),
                            ListTile(
                              contentPadding: const EdgeInsets.all(0),
                              leading: const CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                radius: 18,
                                child: Icon(
                                  Feather.user_check,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                ub?.name ?? "",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            const DividerWidget(),
                            ListTile(
                              contentPadding: const EdgeInsets.all(0),
                              leading: const CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                radius: 18,
                                child: Icon(
                                  Feather.user_plus,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                ub?.accessRole ?? "",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            const DividerWidget(),
                            ListTile(
                              contentPadding: const EdgeInsets.all(0),
                              leading: CircleAvatar(
                                backgroundColor: Colors.indigoAccent[100],
                                radius: 18,
                                child: const Icon(
                                  Feather.mail,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                ub?.email ?? "",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
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
        ]),
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

class BottomContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 11,
      padding: EdgeInsets.all(10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFE96327),
            Color(0xFFBC2925),
          ],
        ),
      ),
      child: Center(
        child: customTitle(
          'KIỂM TRA - THÔNG TIN CÁ NHÂN',
        ),
      ),
    );
  }
}
