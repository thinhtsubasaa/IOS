import 'dart:convert';

import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/models/congbaove.dart';
import 'package:Thilogi/models/dialy_vungmien.dart';
import 'package:Thilogi/models/lsx_racong.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/loading.dart';
import 'package:http/http.dart' as http;

class CustomBodyLSXRaCong extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: BodyLSRaCongScreen());
  }
}

class BodyLSRaCongScreen extends StatefulWidget {
  const BodyLSRaCongScreen({Key? key}) : super(key: key);

  @override
  _BodyLSRaCongScreenState createState() => _BodyLSRaCongScreenState();
}

class _BodyLSRaCongScreenState extends State<BodyLSRaCongScreen> with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  bool _loading = false;

  String? id;
  String? KhoXeId;
  String? doiTac_Id;
  String? vungMien_Id;
  String? congBaoVe_Id;

  List<LSX_RaCongModel>? _dn;
  List<LSX_RaCongModel>? get dn => _dn;
  List<VungMienModel>? _vm;
  List<VungMienModel>? get vm => _vm;
  List<CongBaoVeModel>? _baove;
  List<CongBaoVeModel>? get baove => _baove;
  bool _hasError = false;
  bool get hasError => _hasError;
  String? selectedDate;
  String? selectedFromDate;
  String? selectedToDate;
  String? _errorCode;
  String? get errorCode => _errorCode;
  final TextEditingController textEditingController = TextEditingController();
  final TextEditingController maNhanVienController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      vungMien_Id = "646c0969-773d-448f-8df1-6d7c8044613f";
      getRaCong(vungMien_Id ?? "");
      _loading = false;
    });
    getVungMien();
    selectedFromDate = DateFormat('MM/dd/yyyy').format(DateTime.now());
    selectedToDate = DateFormat('MM/dd/yyyy').format(DateTime.now().add(Duration(days: 1)));
    // getDSXRaCong(selectedFromDate, selectedToDate, vungMien_Id ?? "", congBaoVe_Id ?? "", maNhanVienController.text);
  }

  Future<void> getVungMien() async {
    _vm = [];
    try {
      final http.Response response = await requestHelper.getData('DM_DiaLy_VungMien');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("data: " + decodedData.toString());
        if (decodedData != null) {
          _vm = (decodedData as List).map((item) => VungMienModel.fromJson(item)).where((item) => item.parent_Id == null).toList();

          // Gọi setState để cập nhật giao diện
          setState(() {
            vungMien_Id = "646c0969-773d-448f-8df1-6d7c8044613f";
            _loading = false;
          });
        }
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Future<void> getRaCong(String? VungMien_Id) async {
    _baove = [];
    try {
      final http.Response response = await requestHelper.getData('BaoVe/GetAllTable?VungMien_Id=$VungMien_Id');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("data: " + decodedData.toString());
        if (decodedData != null) {
          _baove = (decodedData as List).map((item) => CongBaoVeModel.fromJson(item)).toList();
          _baove!.insert(0, CongBaoVeModel(id: '', tenCong: 'Tất cả'));

          // Gọi setState để cập nhật giao diện
          setState(() {
            congBaoVe_Id = '';
            _loading = false;
          });
          getDSXRaCong(selectedFromDate, selectedToDate, vungMien_Id ?? "", congBaoVe_Id ?? "", maNhanVienController.text);
        }
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Future<void> getDSXRaCong(String? tuNgay, String? denNgay, String? VungMien_Id, String? CongBaoVe_Id, String? keyword) async {
    _dn = [];
    try {
      final http.Response response = await requestHelper.getData('KhoThanhPham/GetDanhSachXeRaCongAll?TuNgay=$tuNgay&DenNgay=$denNgay&VungMien_Id=$VungMien_Id&CongBaoVe_Id=$CongBaoVe_Id&keyword=$keyword');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("data: " + decodedData.toString());
        if (decodedData != null) {
          _dn = (decodedData as List).map((item) => LSX_RaCongModel.fromJson(item)).toList();

          // Gọi setState để cập nhật giao diện
          setState(() {
            _loading = false;
          });
        }
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  void _selectDate(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(Duration(days: 1)),
      ),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        selectedFromDate = DateFormat('MM/dd/yyyy').format(picked.start);
        selectedToDate = DateFormat('MM/dd/yyyy').format(picked.end);
        _loading = false;
      });
      print("TuNgay: $selectedFromDate");
      print("DenNgay: $selectedToDate");
      await getDSXRaCong(selectedFromDate, selectedToDate, vungMien_Id ?? "", congBaoVe_Id ?? "", maNhanVienController.text);
    }
  }

  Widget _buildTableOptions(BuildContext context) {
    int index = 0;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: MediaQuery.of(context).size.width * 4.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '',
              style: TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Table(
              border: TableBorder.all(),
              columnWidths: const {
                0: FlexColumnWidth(0.3),
                1: FlexColumnWidth(0.3),
                2: FlexColumnWidth(0.3),
                3: FlexColumnWidth(0.3),
                4: FlexColumnWidth(0.3),
                5: FlexColumnWidth(0.3),
                6: FlexColumnWidth(0.3),
                7: FlexColumnWidth(0.3),
                8: FlexColumnWidth(0.3),
                9: FlexColumnWidth(0.3),
                10: FlexColumnWidth(0.3),
                11: FlexColumnWidth(0.3),
                12: FlexColumnWidth(0.3),
              },
              children: [
                TableRow(
                  children: [
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Ngày ra cổng', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Trạng thái', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Biển số', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Số khung', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Loại Xe', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Màu Xe', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Tên tài xế', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Nơi đi', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Nơi đến', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Ghi chú', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Lý do', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Tên bảo vệ', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Hình ảnh', textColor: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.6, // Chiều cao cố định
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(),
                  columnWidths: const {
                    0: FlexColumnWidth(0.3),
                    1: FlexColumnWidth(0.3),
                    2: FlexColumnWidth(0.3),
                    3: FlexColumnWidth(0.3),
                    4: FlexColumnWidth(0.3),
                    5: FlexColumnWidth(0.3),
                    6: FlexColumnWidth(0.3),
                    7: FlexColumnWidth(0.3),
                    8: FlexColumnWidth(0.3),
                    9: FlexColumnWidth(0.3),
                    10: FlexColumnWidth(0.3),
                    11: FlexColumnWidth(0.3),
                    12: FlexColumnWidth(0.3),
                  },
                  children: [
                    ..._dn?.map((item) {
                          index++; // Tăng số thứ tự sau mỗi lần lặp
                          // bool highlightRed = item.tenTaiXe == "-" || item.lyDo != null;
                          return TableRow(
                            decoration: BoxDecoration(
                              color: item.trangThaiChuyenXe == "Đã xác nhận ra cổng"
                                  ? Colors.green.withOpacity(0.3)
                                  : item.trangThaiChuyenXe == "Đã từ chối ra cổng"
                                      ? Colors.red.withOpacity(0.3)
                                      : Colors.white, // Màu trắng cho trạng thái Đang kiểm tra hoặc các trạng thái khác
                            ),
                            children: [
                              // _buildTableCell(index.toString()), // Số thứ tự
                              _buildTableCell(
                                item.ngayRaCong ?? "",
                              ),
                              _buildTableCell(
                                item.trangThaiChuyenXe ?? "",
                              ),
                              _buildTableCell(
                                item.bienSo ?? "",
                              ),
                              _buildTableCell(
                                item.soKhung ?? "",
                              ),
                              _buildTableCell(
                                item.loaiXe ?? "",
                              ),
                              _buildTableCell(
                                item.mauXe ?? "",
                              ),
                              _buildTableCell(
                                item.tenTaiXe ?? "",
                              ),
                              _buildTableCell(
                                item.noiDi ?? "",
                              ),
                              _buildTableCell(
                                item.noiDen ?? "",
                              ),
                              _buildTableCell(
                                item.ghiChu ?? "",
                              ),
                              _buildTableCell(
                                item.lyDo ?? "",
                              ),
                              _buildTableCell(
                                item.tenBaoVe ?? "",
                              ),
                              _buildTableHinhAnh(item.hinhAnh ?? ""),
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
      child: SelectableText(
        content,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Comfortaa',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildTableHinhAnh(String content, {Color textColor = Colors.black}) {
    List<String> imageUrls = content.split(',');

    return Container(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          String imageUrl = imageUrls[index];
          return GestureDetector(
            onTap: () {
              _showFullImageDialog(imageUrls, index); // Truyền danh sách ảnh và index hiện tại
            },
            child: Container(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFullImageDialog(List<String> imageUrls, int initialIndex) {
    showDialog(
      context: context,
      builder: (context) {
        final screenSize = MediaQuery.of(context).size;
        return Dialog(
          child: Container(
            // width: screenSize.width * 1,
            height: screenSize.height * 0.7,
            child: PhotoViewGallery.builder(
              itemCount: imageUrls.length,
              pageController: PageController(initialPage: initialIndex),
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(imageUrls[index]),
                  // minScale: PhotoViewComputedScale.contained, // Đảm bảo ảnh hiển thị đầy đủ
                  // maxScale: PhotoViewComputedScale.covered, // Cho phép phóng to vừa đủ nếu cần
                  // initialScale: PhotoViewComputedScale.covered,
                  // backgroundDecoration: BoxDecoration(color: Colors.black),
                );
              },
              scrollPhysics: BouncingScrollPhysics(),
              backgroundDecoration: BoxDecoration(color: Colors.black),
              loadingBuilder: (context, event) => Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        );
      },
    );
  }

  // Widget _buildTableHinhAnh(String content, {Color textColor = Colors.black}) {
  //   // Tách chuỗi URL thành danh sách các link ảnh
  //   List<String> imageUrls = content.split(',');

  //   return Container(
  //     height: 65,
  //     child: ListView.builder(
  //       scrollDirection: Axis.horizontal, // Cho phép cuộn ngang nếu có nhiều ảnh
  //       itemCount: imageUrls.length,
  //       itemBuilder: (context, index) {
  //         String imageUrl = imageUrls[index];
  //         return GestureDetector(
  //           onTap: () {
  //             _showFullImageDialog(imageUrl); // Hiển thị ảnh đầy đủ khi bấm vào
  //           },
  //           child: Container(
  //             child: Image.network(
  //               imageUrl,
  //               fit: BoxFit.contain,
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  // void _showFullImageDialog(String imageUrl) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => Dialog(
  //       child: Container(
  //         width: double.infinity,
  //         height: double.infinity,
  //         child: PhotoView(
  //           imageProvider: NetworkImage(imageUrl),
  //           backgroundDecoration: BoxDecoration(color: Colors.black),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await getDSXRaCong(selectedFromDate, selectedToDate, vungMien_Id ?? "", congBaoVe_Id ?? "", maNhanVienController.text);
      }, // Gọi hàm tải lại dữ liệu
      child: Container(
        child: Column(
          children: [
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
                              padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(left: 4),
                                        alignment: Alignment.topLeft,
                                        child: BackButton(
                                          color: Colors.black,
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => _selectDate(context),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.blue),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.calendar_today, color: Colors.blue),
                                              SizedBox(width: 8),
                                              Text(
                                                selectedFromDate != null && selectedToDate != null
                                                    ? '${DateFormat('dd/MM/yyyy').format(DateFormat('MM/dd/yyyy').parse(selectedFromDate!))} - ${DateFormat('dd/MM/yyyy').format(DateFormat('MM/dd/yyyy').parse(selectedToDate!))}'
                                                    : 'Chọn ngày',
                                                style: TextStyle(color: Colors.blue),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  const Divider(height: 1, color: Color(0xFFA71C20)),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height < 600 ? 0 : 5),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(5),
                                              border: Border.all(
                                                color: const Color(0xFFBC2925),
                                                width: 1.5,
                                              ),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton2<String>(
                                                isExpanded: true,
                                                items: _vm?.map((item) {
                                                  return DropdownMenuItem<String>(
                                                    value: item.id,
                                                    child: Container(
                                                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
                                                      child: SingleChildScrollView(
                                                        scrollDirection: Axis.horizontal,
                                                        child: Text(
                                                          item.tenVungMien ?? "",
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
                                                value: vungMien_Id,
                                                onChanged: (newValue) {
                                                  setState(() {
                                                    vungMien_Id = newValue;
                                                  });
                                                  if (newValue != null) {
                                                    getRaCong(newValue);
                                                    getDSXRaCong(selectedFromDate, selectedToDate, newValue, congBaoVe_Id ?? "", maNhanVienController.text);
                                                    print("object : ${vungMien_Id}");
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
                                                        hintText: 'Tìm vùng miền',
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
                                                      return _vm?.any((baiXe) => baiXe.id == itemId && baiXe.tenVungMien?.toLowerCase().contains(searchValue.toLowerCase()) == true) ?? false;
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
                                      SizedBox(
                                        width: 3,
                                      ),
                                      Expanded(
                                        child: Container(
                                            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height < 600 ? 0 : 5),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(5),
                                              border: Border.all(
                                                color: const Color(0xFFBC2925),
                                                width: 1.5,
                                              ),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton2<String>(
                                                isExpanded: true,
                                                items: _baove?.map((item) {
                                                  return DropdownMenuItem<String>(
                                                    value: item.id,
                                                    child: Container(
                                                      child: Text(
                                                        item.tenCong ?? "",
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
                                                value: congBaoVe_Id,
                                                onChanged: (newValue) {
                                                  setState(() {
                                                    congBaoVe_Id = newValue;
                                                  });
                                                  if (newValue != null) {
                                                    if (newValue == '') {
                                                      getDSXRaCong(selectedFromDate, selectedToDate, vungMien_Id ?? "", '', maNhanVienController.text);
                                                    } else {
                                                      getDSXRaCong(selectedFromDate, selectedToDate, vungMien_Id ?? "", newValue, maNhanVienController.text);
                                                      print("objectcong : ${newValue}");
                                                    }
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
                                                        hintText: 'Tìm cổng',
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
                                                      return _baove?.any((viTri) => viTri.id == itemId && viTri.tenCong?.toLowerCase().contains(searchValue.toLowerCase()) == true) ?? false;
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
                                  SizedBox(height: 5),
                                  Container(
                                    height: MediaQuery.of(context).size.height < 600 ? 10.h : 7.h,
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
                                              "Tìm kiếm",
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(
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
                                          child: Padding(
                                            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height < 600 ? 0 : 5),
                                            child: TextField(
                                              controller: maNhanVienController,
                                              decoration: const InputDecoration(
                                                border: InputBorder.none,
                                                isDense: true,
                                                hintText: 'Nhập số khung, người lái xe',
                                                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                                              ),
                                              style: const TextStyle(
                                                fontFamily: 'Comfortaa',
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.search),
                                          onPressed: () {
                                            setState(() {
                                              _loading = true;
                                            });
                                            // Gọi API với từ khóa tìm kiếm
                                            getDSXRaCong(selectedFromDate, selectedToDate, vungMien_Id ?? "", congBaoVe_Id ?? "", maNhanVienController.text);
                                            setState(() {
                                              _loading = false;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          'Tổng số xe đã thực hiện: ${_dn?.length.toString() ?? ''}',
                                          style: TextStyle(
                                            fontFamily: 'Comfortaa',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        _buildTableOptions(context),
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
          ],
        ),
      ),
    );
  }
}
