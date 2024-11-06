import 'dart:convert';
import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/models/baixe.dart';
import 'package:Thilogi/models/doitac.dart';
import 'package:Thilogi/models/dongxe.dart';
import 'package:Thilogi/models/dsxchoxuat.dart';
import 'package:Thilogi/models/khoxe.dart';
import 'package:Thilogi/models/lsvanchuyen.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../widgets/loading.dart';
import 'package:http/http.dart' as http;

class CustomBodyLSXVanChuyen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: BodyLSVanChuyenScreen());
  }
}

class BodyLSVanChuyenScreen extends StatefulWidget {
  const BodyLSVanChuyenScreen({Key? key}) : super(key: key);

  @override
  _BodyLSVanChuyenScreenState createState() => _BodyLSVanChuyenScreenState();
}

class _BodyLSVanChuyenScreenState extends State<BodyLSVanChuyenScreen> with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  bool _loading = false;
  String? doiTac_Id;
  List<LSVanChuyenModel>? _dn;
  List<LSVanChuyenModel>? get dn => _dn;
  List<DoiTacModel>? _doitacList;
  List<DoiTacModel>? get doitacList => _doitacList;
  List<DS_ChoXuatModel>? _cx;
  List<DS_ChoXuatModel>? get cx => _cx;
  bool _hasError = false;
  bool get hasError => _hasError;
  String? selectedDate;
  String? selectedFromDate;
  String? selectedToDate;

  String? _errorCode;
  String? get errorCode => _errorCode;
  final TextEditingController textEditingController = TextEditingController();
  final TextEditingController maNhanVienController = TextEditingController();
  String? BaiXeId;
  String? KhoXeId;
  String? DongXeId;
  List<KhoXeModel>? _khoxeList;
  List<KhoXeModel>? get khoxeList => _khoxeList;
  List<DongXeModel>? _dongxeList;
  List<DongXeModel>? get dongxeList => _dongxeList;
  List<BaiXeModel>? _baixeList;
  List<BaiXeModel>? get baixeList => _baixeList;

  @override
  void initState() {
    super.initState();
    setState(() {
      KhoXeId = "9001663f-0164-477d-b576-09c7541f4cce";
      getBaiXeList(KhoXeId ?? "");
      _loading = false;
    });
    getDataKho();
    getDataDongXe();
    getDoiTac();
    selectedFromDate = DateFormat('MM/dd/yyyy').format(DateTime.now());
    selectedToDate = DateFormat('MM/dd/yyyy').format(DateTime.now().add(Duration(days: 1)));
    // getDSXVanChuyen(selectedFromDate, selectedToDate, doiTac_Id ?? "", maNhanVienController.text);
    getDSXChoXuat('', '', "", "");
  }

  void getDoiTac() async {
    try {
      final http.Response response = await requestHelper.getData('DM_DoiTac/GetDoiTacLogistic');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        _doitacList = (decodedData as List).map((item) => DoiTacModel.fromJson(item)).toList();
        _doitacList!.insert(0, DoiTacModel(id: '', tenDoiTac: 'Tất cả'));

        // Đặt giá trị mặc định cho DropdownButton là ID của "Tất cả"
        setState(() {
          doiTac_Id = '';
          _loading = false;
        });

        // Gọi hàm để lấy dữ liệu với giá trị mặc định "Tất cả"
        getDSXVanChuyen(selectedFromDate, selectedToDate, doiTac_Id ?? "", KhoXeId ?? "", BaiXeId ?? "", DongXeId ?? "", maNhanVienController.text);
        // Gọi setState để cập nhật giao diện
        // setState(() {
        //   _loading = false;
        // });
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  void getDSXChoXuat(String? KhoXe_Id, String? id, String? doiTac_Id, String? phuongThuc_Id) async {
    _cx = [];
    try {
      final http.Response response = await requestHelper.getData('KhoThanhPham/GetDanhSachXeChoXuat?KhoXe_Id=$KhoXe_Id&id=$id&DoiTac_Id=$doiTac_Id&PhuongThuc_Id=$phuongThuc_Id');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        if (decodedData != null) {
          // Lọc dữ liệu chỉ bao gồm các mục có 'isKeHoach' là true
          var filteredData = decodedData.where((item) => item['isKeHoach'] == true).toList();
          print("dayaaaa:$filteredData");

          if (filteredData.isNotEmpty) {
            _cx = (filteredData as List).map((item) => DS_ChoXuatModel.fromJson(item)).toList();
            print("Updated _cx: $_cx");

            setState(() {
              _loading = false;
            });
          }
        }
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  void getDataKho() async {
    try {
      final http.Response response = await requestHelper.getData('DM_WMS_Kho_KhoXe/GetKhoLogistic');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        _khoxeList = (decodedData as List).map((item) => KhoXeModel.fromJson(item)).where((item) => item.maKhoXe == "MT_CLA" || item.maKhoXe == "MN_NAMBO" || item.maKhoXe == "MB_BACBO").toList();

        // Gọi setState để cập nhật giao diện
        setState(() {
          KhoXeId = "9001663f-0164-477d-b576-09c7541f4cce";
          _loading = false;
        });
        getDSXVanChuyen(selectedFromDate, selectedToDate, doiTac_Id ?? "", KhoXeId ?? "", BaiXeId ?? "", DongXeId ?? "", maNhanVienController.text);
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  void getDataDongXe() async {
    try {
      final http.Response response = await requestHelper.getData('Xe_DongXe');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        _dongxeList = (decodedData["datalist"] as List).map((item) => DongXeModel.fromJson(item)).toList();
        _dongxeList!.insert(0, DongXeModel(id: '', tenDongXe: 'Tất cả'));

        // Gọi setState để cập nhật giao diện
        setState(() {
          DongXeId = '';
          _loading = false;
        });
        getDSXVanChuyen(selectedFromDate, selectedToDate, doiTac_Id ?? "", KhoXeId ?? "", BaiXeId ?? "", DongXeId ?? "", maNhanVienController.text);
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Future<void> getBaiXeList(String? KhoXeId) async {
    try {
      final http.Response response = await requestHelper.getData('DM_WMS_Kho_BaiXe?khoXe_Id=$KhoXeId');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        _baixeList = (decodedData as List).map((item) => BaiXeModel.fromJson(item)).toList();
        _baixeList!.insert(0, BaiXeModel(id: '', tenBaiXe: 'Tất cả'));
        setState(() {
          BaiXeId = '';
          _loading = false;
        });
        getDSXVanChuyen(selectedFromDate, selectedToDate, doiTac_Id ?? "", KhoXeId ?? "", BaiXeId ?? "", DongXeId ?? "", maNhanVienController.text);
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Future<void> getDSXVanChuyen(String? tuNgay, String? denNgay, String? doiTac_Id, String? KhoXe_Id, String? BaiXe_Id, String? DongXe_Id, String? keyword) async {
    _dn = [];
    try {
      final http.Response response =
          await requestHelper.getData('KhoThanhPham/GetDanhSachXeVanChuyenAll?TuNgay=$tuNgay&DenNgay=$denNgay&DoiTac_Id=$doiTac_Id&KhoXe_Id=$KhoXe_Id&BaiXe_Id=$BaiXe_Id&DongXe_Id=$DongXe_Id&keyword=$keyword');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("data: " + decodedData.toString());
        if (decodedData != null) {
          _dn = (decodedData as List).map((item) => LSVanChuyenModel.fromJson(item)).toList();

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
      await getDSXVanChuyen(selectedFromDate, selectedToDate, doiTac_Id ?? "", KhoXeId ?? "", BaiXeId ?? "", DongXeId ?? "", maNhanVienController.text);
    }
  }

  Widget _buildTableOptions(BuildContext context) {
    int index = 0; // Biến đếm số thứ tự

    const String defaultDate = "1970-01-01 ";

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: MediaQuery.of(context).size.width * 3.5,
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
                3: FlexColumnWidth(0.35),
                4: FlexColumnWidth(0.3),
                5: FlexColumnWidth(0.3),
                6: FlexColumnWidth(0.3),
              },
              children: [
                TableRow(
                  children: [
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Ngày nhận', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Đơn vị vận chuyển', textColor: Colors.white),
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
                      child: _buildTableCell('Thông tin chi tiết', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Thông tin vận chuyển', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Người vận chuyển', textColor: Colors.white),
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
                    3: FlexColumnWidth(0.35),
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
                              _buildTableCell(item.ngay ?? ""),
                              _buildTableCell(item.donVi ?? ""),
                              _buildTableCell(item.soKhung ?? ""),
                              _buildTableCell(item.loaiXe ?? ""),
                              _buildTableCell(item.thongTinChiTiet ?? ""),
                              _buildTableCell(item.thongTinVanChuyen ?? ""),
                              _buildTableCell(item.nguoiVanChuyen ?? ""),
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
        await getDSXVanChuyen(selectedFromDate, selectedToDate, doiTac_Id ?? "", KhoXeId ?? "", BaiXeId ?? "", DongXeId ?? "", maNhanVienController.text);
      }, // Gọi hàm tải lại dữ liệu
      child: Container(
        child: Column(
          children: [
            const SizedBox(height: 10),
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
                                  GestureDetector(
                                    onTap: () => _selectDate(context),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 6),
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
                                                            fontSize: 13,
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
                                                  setState(() {
                                                    KhoXeId = newValue;
                                                  });
                                                  if (newValue != null) {
                                                    getBaiXeList(newValue);
                                                    getDataDongXe();
                                                    getDSXVanChuyen(selectedFromDate, selectedToDate, doiTac_Id ?? "", newValue, BaiXeId ?? "", DongXeId ?? "", maNhanVienController.text);
                                                    print("object : ${newValue}");
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
                                                      return _khoxeList?.any((baiXe) => baiXe.id == itemId && baiXe.tenKhoXe?.toLowerCase().contains(searchValue.toLowerCase()) == true) ?? false;
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
                                                items: _dongxeList?.map((item) {
                                                  return DropdownMenuItem<String>(
                                                    value: item.id,
                                                    child: Container(
                                                      child: Text(
                                                        item.tenDongXe ?? "",
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
                                                value: DongXeId,
                                                onChanged: (newValue) {
                                                  setState(() {
                                                    DongXeId = newValue;
                                                  });
                                                  if (newValue != null) {
                                                    if (newValue == '') {
                                                      getDSXVanChuyen(selectedFromDate, selectedToDate, doiTac_Id ?? "", KhoXeId ?? "", BaiXeId ?? "", '', maNhanVienController.text);
                                                    } else {
                                                      getDSXVanChuyen(selectedFromDate, selectedToDate, doiTac_Id ?? "", KhoXeId ?? "", BaiXeId ?? "", newValue, maNhanVienController.text);
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
                                                      return _dongxeList?.any((viTri) => viTri.id == itemId && viTri.tenDongXe?.toLowerCase().contains(searchValue.toLowerCase()) == true) ?? false;
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
                                  SizedBox(
                                    height: 5,
                                  ),
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
                                              "Bãi xe",
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
                                                    setState(() {
                                                      BaiXeId = newValue;
                                                      // doiTac_Id = null;
                                                    });

                                                    if (newValue != null) {
                                                      if (newValue == '') {
                                                        getDSXVanChuyen(selectedFromDate, selectedToDate, doiTac_Id ?? "", KhoXeId ?? "", '', DongXeId ?? "", maNhanVienController.text);
                                                      } else {
                                                        getDataDongXe();
                                                        getDSXVanChuyen(selectedFromDate, selectedToDate, doiTac_Id ?? "", KhoXeId ?? "", newValue, DongXeId ?? "", maNhanVienController.text);
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
                                  SizedBox(
                                    height: 5,
                                  ),
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
                                          width: 30.w,
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
                                              "Đơn vị vận chuyển ",
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(
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
                                                  items: _doitacList?.map((item) {
                                                    return DropdownMenuItem<String>(
                                                      value: item.id,
                                                      child: Container(
                                                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
                                                        child: SingleChildScrollView(
                                                          scrollDirection: Axis.horizontal,
                                                          child: Text(
                                                            item.tenDoiTac ?? "",
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
                                                  value: doiTac_Id,
                                                  onChanged: (newValue) {
                                                    setState(() {
                                                      doiTac_Id = newValue;
                                                    });

                                                    if (newValue != null) {
                                                      if (newValue == '') {
                                                        getDSXVanChuyen(selectedFromDate, selectedToDate, '', KhoXeId ?? "", BaiXeId ?? "", DongXeId ?? "", maNhanVienController.text);
                                                      } else {
                                                        getDSXVanChuyen(selectedFromDate, selectedToDate, newValue, KhoXeId ?? "", BaiXeId ?? "", DongXeId ?? "", maNhanVienController.text);
                                                        print("object : ${doiTac_Id}");
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
                                                          hintText: 'Tìm đơn vị',
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
                                                        return _doitacList?.any((baiXe) => baiXe.id == itemId && baiXe.tenDoiTac?.toLowerCase().contains(searchValue.toLowerCase()) == true) ?? false;
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
                                  SizedBox(
                                    height: 5,
                                  ),
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
                                          width: 30.w,
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
                                                fontSize: 15,
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
                                                hintText: 'Nhập mã nhân viên hoặc tên đầy đủ',
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
                                            getDSXVanChuyen(selectedFromDate, selectedToDate, doiTac_Id ?? "", KhoXeId ?? "", BaiXeId ?? "", DongXeId ?? "", maNhanVienController.text);
                                            setState(() {
                                              _loading = false;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          'Tổng số xe đã thực hiện: ${_dn?.length.toString() ?? ""}/${_cx?.length.toString() ?? ""}',
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
