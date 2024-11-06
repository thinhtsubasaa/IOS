import 'dart:io';

import 'package:Thilogi/utils/delete_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid/responsive_grid.dart';

import '../blocs/app_bloc.dart';
import '../models/checksheet.dart';
import '../services/request_helper.dart';

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

class CheckSheetUploadAnh extends StatefulWidget {
  final List<CheckSheetFileModel?> lstFiles;
  const CheckSheetUploadAnh({super.key, required this.lstFiles});

  @override
  State<CheckSheetUploadAnh> createState() => _CheckSheetUploadAnhState();
}

class _CheckSheetUploadAnhState extends State<CheckSheetUploadAnh> {
  PickedFile? _pickedFile;
  List<FileItem?> _lstFiles = [];
  final _picker = ImagePicker();
  late bool _loading = false;

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
  }

  //* Call camera, gallery
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
      });
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
      var tmp = _lstFiles.firstWhere((file) => file!.isRemoved == false,
          orElse: () => null);
      if (tmp == null) {
        isRemoved = true;
      }
    }
    return isRemoved;
  }

  @override
  Widget build(BuildContext context) {
    final AppBloc ab = context.watch<AppBloc>();

    return Container(
      margin: const EdgeInsets.only(right: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.87),
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
                    onPressed: (_loading || _allowUploadFile() == false)
                        ? null
                        : () => _uploadAnh(),
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text("Tải ảnh"),
                  ),
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
    );
  }
}
