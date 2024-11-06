import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:Thilogi/blocs/app_bloc.dart';
import 'package:Thilogi/models/checksheet.dart';
import 'package:Thilogi/models/rutcont.dart';
import 'package:Thilogi/utils/delete_dialog.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator_platform_interface/src/enums/location_accuracy.dart' as GeoLocationAccuracy;

import '../../blocs/dongseal_bloc.dart';
import '../../config/config.dart';
import '../../models/dongseal.dart';
import '../../models/dsdongcontseal.dart';
import '../../services/app_service.dart';
import '../../widgets/loading.dart';

class CustomBodyRutContXe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: BodyRutContScreen(
      lstFiles: [],
    ));
  }
}

class BodyRutContScreen extends StatefulWidget {
  final List<CheckSheetFileModel?> lstFiles;
  const BodyRutContScreen({super.key, required this.lstFiles});

  @override
  _BodyRutContScreenState createState() => _BodyRutContScreenState();
}

class _BodyRutContScreenState extends State<BodyRutContScreen> with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();
  String _qrData = '';
  String? SoContId;
  final _qrDataController = TextEditingController();
  String? soCont;
  String? TauId;
  String? viTri;
  final TextEditingController _soSeal = TextEditingController();

  List<RutContModel>? _dsxdongcontList;
  List<RutContModel>? get dsxdongcont => _dsxdongcontList;
  List<DS_DongSealModel>? _dongcontList;
  List<DS_DongSealModel>? get dongcont => _dongcontList;

  DongSealModel? _data;
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
  PickedFile? _pickedFile;
  List<FileItem?> _lstFiles = [];
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    getSoCont();
    _bl = Provider.of<DongSealBloc>(context, listen: false);
    for (var file in widget.lstFiles) {
      _lstFiles.add(FileItem(
        uploaded: true,
        file: file!.path,
        local: false,
        isRemoved: file.isRemoved,
      ));
    }
    requestLocationPermission();
  }

  @override
  void dispose() {
    textEditingController.dispose();
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

  void getSoCont() async {
    try {
      final http.Response response = await requestHelper.getData('DSX_DongCont/GetListContDaDong');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        _dsxdongcontList = (decodedData as List).map((item) => RutContModel.fromJson(item)).toList();

        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
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
      var tmp = _lstFiles.firstWhere((file) => file!.isRemoved == false, orElse: () => null);
      if (tmp == null) {
        isRemoved = true;
      }
    }
    return isRemoved;
  }

  void getDongCont(String SoContId) async {
    try {
      final http.Response response = await requestHelper.getData('DSX_DongCont/RutCont_Mobi?SoCont_Id=$SoContId');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        _dongcontList = (decodedData as List).map((item) => DS_DongSealModel.fromJson(item)).toList();

        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Future<void> postData(String viTri, String? soCont, String? file) async {
    _isLoading = true;

    try {
      final http.Response response = await requestHelper.postData('KhoThanhPham/RutCont?ViTri=$viTri&SoCont=$soCont&File=$file', _data?.toJson());
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
          text: "Rút cont thành công",
          confirmBtnText: 'Đồng ý',
        );
        _btnController.reset();
        setState(() {
          _dsxdongcontList?.removeWhere((item) => item.soCont == soCont);
          _soContIdMap.remove(soCont);
        });
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

  _onSave() async {
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
        setState(() {
          _loading = false;
        });

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
    Geolocator.getCurrentPosition(
      desiredAccuracy: GeoLocationAccuracy.LocationAccuracy.low,
    ).then((position) {
      setState(() {
        lat = "${position.latitude}";
        long = "${position.longitude}";
      });
      viTri = "${lat},${long}";

      print("viTri: ${viTri}");
      print("soCont:${soCont}");

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
          postData(viTri ?? "", soCont ?? "", imageUrlsString).then((_) {
            setState(() {
              soCont = null;
              SoContId = null;
              _dongcontList = null;
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
        text: 'Bạn có muốn rút cont không?',
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

  Widget _buildTableOptions(BuildContext context) {
    int index = 0; // Biến đếm số thứ tự
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: MediaQuery.of(context).size.width * 1.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Danh sách xe : ${_dongcontList?.length.toString() ?? ''}',
              style: TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Table(
              border: TableBorder.all(),
              columnWidths: {
                0: FlexColumnWidth(0.1),
                1: FlexColumnWidth(0.3),
                2: FlexColumnWidth(0.3),
                3: FlexColumnWidth(0.25),
                4: FlexColumnWidth(0.25),
              },
              children: [
                TableRow(
                  children: [
                    Container(
                      width: double.infinity,
                      color: Colors.red,
                      child: _buildTableCell('TT', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Số Khung', textColor: Colors.white),
                    ),
                    Container(
                      width: double.infinity,
                      color: Colors.red,
                      child: _buildTableCell('Loại Xe', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Số Seal', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Tàu', textColor: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              // height: MediaQuery.of(context).size.height, // Chiều cao cố định
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(),
                  columnWidths: {
                    0: FlexColumnWidth(0.1),
                    1: FlexColumnWidth(0.3),
                    2: FlexColumnWidth(0.3),
                    3: FlexColumnWidth(0.25),
                    4: FlexColumnWidth(0.25),
                  },
                  children: [
                    ..._dongcontList?.map((item) {
                          index++; // Tăng số thứ tự sau mỗi lần lặp

                          return TableRow(
                            children: [
                              _buildTableCell(index.toString()),
                              _buildTableCell(item.soKhung ?? ""),
                              _buildTableCell(item.loaiXe ?? ""),
                              _buildTableCell(item.soSeal ?? ""),
                              _buildTableCell(item.tau ?? ""),
                            ],
                          );
                        }).toList() ??
                        [],
                  ],
                ),
              ),
            ),
          ],
        ),
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
    _dsxdongcontList?.forEach((item) {
      _soContIdMap[item.soCont ?? ""] = item.dongCont_Id ?? ""; // Thêm cặp giá trị vào Map
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
                              Divider(height: 1, color: Color(0xFFA71C20)),
                              SizedBox(height: 10),
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
                                          child: Center(
                                            child: Text(
                                              "Số Cont",
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
                                                    onChanged: (newValue) {
                                                      setState(() {
                                                        soCont = newValue;
                                                        SoContId = _soContIdMap[newValue];
                                                      });
                                                      if (newValue != null) {
                                                        getDongCont(SoContId ?? "");
                                                        print("object : ${SoContId}");
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
                                  const SizedBox(height: 10),
                                  SizedBox(height: 4),
                                  _buildTableOptions(context),
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
        Container(
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
