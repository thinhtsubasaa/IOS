import 'dart:convert';
import 'package:Thilogi/models/ds_chuadongcont.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../config/config.dart';
import '../../models/dongxe.dart';
import '../../widgets/loading.dart';
import 'package:http/http.dart' as http;

class CustomBodyChuaDongCont extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: BodyChuaDongContScreen());
  }
}

class BodyChuaDongContScreen extends StatefulWidget {
  const BodyChuaDongContScreen({Key? key}) : super(key: key);

  @override
  _BodyChuaDongContScreenState createState() => _BodyChuaDongContScreenState();
}

class _BodyChuaDongContScreenState extends State<BodyChuaDongContScreen> with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  bool _loading = false;

  String? id;
  String? KhoXeId;

  List<DSX_ChuaDongContModel>? _dn;
  List<DSX_ChuaDongContModel>? get dn => _dn;
  bool _hasError = false;
  bool get hasError => _hasError;
  String? selectedDate;
  String? DongXeId;
  String? _errorCode;
  String? get errorCode => _errorCode;
  final TextEditingController textEditingController = TextEditingController();
  final TextEditingController maNhanVienController = TextEditingController();
  List<DongXeModel>? _dongxeList;
  List<DongXeModel>? get dongxeList => _dongxeList;

  @override
  void initState() {
    super.initState();
    selectedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    getDSXChuaDongCont(DongXeId ?? "");
  }

  Future<void> getDSXChuaDongCont(String? DongXe_Id) async {
    _dn = [];
    try {
      final http.Response response = await requestHelper.getData('KhoThanhPham/GetDanhSachXeDongContAll_KH?&DongXe_Id=$DongXe_Id');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("data: " + decodedData.toString());
        if (decodedData != null) {
          _dn = (decodedData as List).map((item) => DSX_ChuaDongContModel.fromJson(item)).toList();

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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        selectedDate = DateFormat('dd/MM/yyyy').format(picked);
        // Gọi API với ngày đã chọn
        _loading = false;
      });
      print("Selected Date: $selectedDate");
      // await getDSXDongCont(selectedDate, maNhanVienController.text);
    }
  }

  Widget _buildTableOptions(BuildContext context) {
    int index = 0;

    const String defaultDate = "1970-01-01 ";
    _dn?.sort((a, b) {
      try {
        DateTime aTime = DateFormat("yyyy-MM-dd").parse(a.ngayTao ?? "");
        DateTime bTime = DateFormat("yyyy-MM-dd").parse(a.ngayTao ?? "");
        return bTime.compareTo(aTime); // Sắp xếp giảm dần
      } catch (e) {
        // Xử lý lỗi khi không thể phân tích cú pháp chuỗi thời gian
        return 0;
      }
    });

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: MediaQuery.of(context).size.width * 2.5,
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
                0: FlexColumnWidth(0.2),
                1: FlexColumnWidth(0.3),
                2: FlexColumnWidth(0.35),
                3: FlexColumnWidth(0.3),
                4: FlexColumnWidth(0.3),
                5: FlexColumnWidth(0.3),
                6: FlexColumnWidth(0.3),
              },
              children: [
                TableRow(
                  children: [
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Ngày tạo', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Số khung', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Vị trí', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Loại Xe', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Số máy', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Màu xe', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Nơi đến', textColor: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.7, // Chiều cao cố định
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(),
                  columnWidths: const {
                    0: FlexColumnWidth(0.2),
                    1: FlexColumnWidth(0.3),
                    2: FlexColumnWidth(0.35),
                    3: FlexColumnWidth(0.3),
                    4: FlexColumnWidth(0.3),
                    5: FlexColumnWidth(0.3),
                    6: FlexColumnWidth(0.3),
                  },
                  children: [
                    ..._dn?.map((item) {
                          index++; // Tăng số thứ tự sau mỗi lần lặp

                          return TableRow(
                            children: [
                              // _buildTableCell(index.toString()), // Số thứ tự
                              _buildTableCell(item.ngayTao ?? ""),
                              _buildTableCell(item.soKhung ?? ""),
                              _buildTableCell(item.viTri ?? ""),
                              _buildTableCell(item.loaiXe ?? ""),
                              _buildTableCell(item.soMay ?? ""),
                              _buildTableCell(item.mauXe ?? ""),
                              _buildTableCell(item.noiDen ?? ""),
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

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await getDSXChuaDongCont(DongXeId ?? "");
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
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Danh sách xe chưa đóng cont',
                                        style: TextStyle(
                                          fontFamily: 'Comfortaa',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  const Divider(height: 1, color: Color(0xFFA71C20)),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  // Container(
                                  //   height:
                                  //       MediaQuery.of(context).size.height < 600
                                  //           ? 10.h
                                  //           : 7.h,
                                  //   decoration: BoxDecoration(
                                  //     borderRadius: BorderRadius.circular(5),
                                  //     border: Border.all(
                                  //       color: const Color(0xFFBC2925),
                                  //       width: 1.5,
                                  //     ),
                                  //   ),
                                  //   child: Row(
                                  //     children: [
                                  //       Container(
                                  //         width: 30.w,
                                  //         decoration: const BoxDecoration(
                                  //           color: Color(0xFFF6C6C7),
                                  //           border: Border(
                                  //             right: BorderSide(
                                  //               color: Color(0xFF818180),
                                  //               width: 1,
                                  //             ),
                                  //           ),
                                  //         ),
                                  //         child: Center(
                                  //           child: Text(
                                  //             "Tìm kiếm",
                                  //             textAlign: TextAlign.left,
                                  //             style: const TextStyle(
                                  //               fontFamily: 'Comfortaa',
                                  //               fontSize: 16,
                                  //               fontWeight: FontWeight.w400,
                                  //               color: AppConfig.textInput,
                                  //             ),
                                  //           ),
                                  //         ),
                                  //       ),
                                  //       Expanded(
                                  //         flex: 1,
                                  //         child: Padding(
                                  //           padding: EdgeInsets.only(
                                  //               top: MediaQuery.of(context)
                                  //                           .size
                                  //                           .height <
                                  //                       600
                                  //                   ? 0
                                  //                   : 5),
                                  //           child: TextField(
                                  //             controller: maNhanVienController,
                                  //             decoration: const InputDecoration(
                                  //               border: InputBorder.none,
                                  //               isDense: true,
                                  //               hintText:
                                  //                   'Nhập mã nhân viên hoặc tên đầy đủ',
                                  //               contentPadding:
                                  //                   EdgeInsets.symmetric(
                                  //                       vertical: 12,
                                  //                       horizontal: 15),
                                  //             ),
                                  //             style: const TextStyle(
                                  //               fontFamily: 'Comfortaa',
                                  //               fontSize: 14,
                                  //               fontWeight: FontWeight.w500,
                                  //               color: Colors.black,
                                  //             ),
                                  //           ),
                                  //         ),
                                  //       ),
                                  //       SizedBox(
                                  //         width: 8,
                                  //       ),
                                  //       IconButton(
                                  //         icon: Icon(Icons.search),
                                  //         onPressed: () {
                                  //           setState(() {
                                  //             _loading = true;
                                  //           });
                                  //           // Gọi API với từ khóa tìm kiếm
                                  //           getDSXDongCont(selectedDate,
                                  //               maNhanVienController.text);
                                  //           setState(() {
                                  //             _loading = false;
                                  //           });
                                  //         },
                                  //       ),
                                  //     ],
                                  //   ),
                                  // ),
                                  Container(
                                    height: MediaQuery.of(context).size.height < 600 ? 10.h : 6.h,
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
                                              "Dòng xe",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontFamily: 'Comfortaa',
                                                fontSize: 15,
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
                                                  items: _dongxeList?.map((item) {
                                                    return DropdownMenuItem<String>(
                                                      value: item.id,
                                                      child: Container(
                                                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
                                                        child: SingleChildScrollView(
                                                          scrollDirection: Axis.horizontal,
                                                          child: Text(
                                                            item.tenDongXe ?? "",
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
                                                  value: DongXeId,
                                                  onChanged: (newValue) {
                                                    setState(() {
                                                      DongXeId = newValue;
                                                      // doiTac_Id = null;
                                                    });

                                                    if (newValue != null) {
                                                      if (newValue == '') {
                                                        getDSXChuaDongCont('');
                                                      } else {
                                                        getDSXChuaDongCont(newValue);
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
                                                          hintText: 'Tìm dòng xe',
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
                                                        return _dongxeList?.any((baiXe) => baiXe.id == itemId && baiXe.tenDongXe?.toLowerCase().contains(searchValue.toLowerCase()) == true) ?? false;
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
                                  SizedBox(height: 5),
                                  Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          'Tổng số xe: ${_dn?.length.toString() ?? ''}',
                                          style: const TextStyle(
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
