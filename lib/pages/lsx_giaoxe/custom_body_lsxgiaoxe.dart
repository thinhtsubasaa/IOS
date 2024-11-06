import 'dart:convert';

import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/models/baixe.dart';
import 'package:Thilogi/models/doitac.dart';
import 'package:Thilogi/models/dongxe.dart';
import 'package:Thilogi/models/khoxe.dart';
import 'package:Thilogi/models/lsu_giaoxe.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:sizer/sizer.dart';

import '../../services/app_service.dart';
import '../../widgets/loading.dart';
import 'package:http/http.dart' as http;

class CustomBodyLSXGiaoXe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: BodyLSGiaoXeScreen());
  }
}

class BodyLSGiaoXeScreen extends StatefulWidget {
  const BodyLSGiaoXeScreen({Key? key}) : super(key: key);

  @override
  _BodyLSGiaoXeScreenState createState() => _BodyLSGiaoXeScreenState();
}

class _BodyLSGiaoXeScreenState extends State<BodyLSGiaoXeScreen> with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  bool _loading = false;

  String? id;

  String? doiTac_Id;
  List<DoiTacModel>? _doitacList;
  List<DoiTacModel>? get doitacList => _doitacList;
  List<LSX_GiaoXeModel>? _dn;
  List<LSX_GiaoXeModel>? get dn => _dn;
  bool _hasError = false;
  bool get hasError => _hasError;
  String? selectedDate;
  String? selectedFromDate;
  String? selectedToDate;
  String? _errorCode;
  String? get errorCode => _errorCode;
  final TextEditingController textEditingController = TextEditingController();
  final TextEditingController maNhanVienController = TextEditingController();
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();

  final TextEditingController _textController = TextEditingController();
  String? BaiXeId;
  String? KhoXeId;
  String? DongXeId;
  LSX_GiaoXeModel? _data;
  List<KhoXeModel>? _khoxeList;
  List<KhoXeModel>? get khoxeList => _khoxeList;
  List<DongXeModel>? _dongxeList;
  List<DongXeModel>? get dongxeList => _dongxeList;
  List<BaiXeModel>? _baixeList;
  List<BaiXeModel>? get baixeList => _baixeList;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _message;
  String? get message => _message;

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
    // getDSXGiaoXe(selectedFromDate, selectedToDate, doiTac_Id ?? "", maNhanVienController.text);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> postData(String? soKhung, String? liDo) async {
    _isLoading = true;

    try {
      final http.Response response = await requestHelper.postData('Kho/UpdateLSGiaoXe?SoKhung=$soKhung&LiDo=$liDo', _data?.toJson());
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        print("data: ${decodedData}");

        notifyListeners();
      } else {}
    } catch (e) {
      _message = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  _onSave(String? soKhung, String? liDo) {
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
        postData(soKhung ?? "", _textController.text).then((_) {
          print("loading: ${_loading}");
        });
      }
    });
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
        getDSXGiaoXe(selectedFromDate, selectedToDate, doiTac_Id ?? "", KhoXeId ?? "", BaiXeId ?? "", DongXeId ?? "", maNhanVienController.text);
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

  Future<void> getDSXGiaoXe(String? tuNgay, String? denNgay, String? doiTac_Id, String? KhoXe_Id, String? BaiXe_Id, String? DongXe_Id, String? keyword) async {
    _dn = [];
    try {
      final http.Response response =
          await requestHelper.getData('KhoThanhPham/GetDanhSachXeGiaoXeAll?TuNgay=$tuNgay&DenNgay=$denNgay&DoiTac_Id=$doiTac_Id&KhoXe_Id=$KhoXe_Id&BaiXe_Id=$BaiXe_Id&DongXe_Id=$DongXe_Id&keyword=$keyword');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("data: " + decodedData.toString());
        if (decodedData != null) {
          _dn = (decodedData as List).map((item) => LSX_GiaoXeModel.fromJson(item)).toList();

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
        getDSXGiaoXe(selectedFromDate, selectedToDate, doiTac_Id ?? "", KhoXeId ?? "", BaiXeId ?? "", DongXeId ?? "", maNhanVienController.text);
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
        getDSXGiaoXe(selectedFromDate, selectedToDate, doiTac_Id ?? "", KhoXeId ?? "", BaiXeId ?? "", DongXeId ?? "", maNhanVienController.text);
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
        getDSXGiaoXe(selectedFromDate, selectedToDate, doiTac_Id ?? "", KhoXeId ?? "", BaiXeId ?? "", DongXeId ?? "", maNhanVienController.text);
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
      await getDSXGiaoXe(selectedFromDate, selectedToDate, doiTac_Id ?? "", KhoXeId ?? "", BaiXeId ?? "", DongXeId ?? "", maNhanVienController.text);
    }
  }

  Widget _buildTableOptions(BuildContext context) {
    int index = 0; // Biến đếm số thứ tự

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
                0: FlexColumnWidth(0.15),
                1: FlexColumnWidth(0.3),
                2: FlexColumnWidth(0.3),
                3: FlexColumnWidth(0.3),
                4: FlexColumnWidth(0.35),
                5: FlexColumnWidth(0.3),
                6: FlexColumnWidth(0.3),
                7: FlexColumnWidth(0.3),
                8: FlexColumnWidth(0.3),
              },
              children: [
                TableRow(
                  children: [
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Hủy', textColor: Colors.white),
                    ),
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
                      child: _buildTableCell('Màu Xe', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Nơi giao', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Người phụ trách', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Lí do', textColor: Colors.white),
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
                    0: FlexColumnWidth(0.15),
                    1: FlexColumnWidth(0.3),
                    2: FlexColumnWidth(0.3),
                    3: FlexColumnWidth(0.3),
                    4: FlexColumnWidth(0.35),
                    5: FlexColumnWidth(0.3),
                    6: FlexColumnWidth(0.3),
                    7: FlexColumnWidth(0.3),
                    8: FlexColumnWidth(0.3),
                  },
                  children: [
                    ..._dn?.map((item) {
                          index++; // Tăng số thứ tự sau mỗi lần lặp
                          bool isCancelled = item.liDoHuyXe != null;
                          return TableRow(
                            decoration: BoxDecoration(
                              color: item.liDoHuyXe != null ? Colors.yellow.withOpacity(0.4) : Colors.white, // Màu nền thay đổi theo giá trị isCheck
                            ),
                            children: [
                              // _buildTableCell(index.toString()), // Số thứ tự
                              IconButton(
                                icon: Icon(Icons.delete, color: item.isNew == true ? Colors.red : Colors.grey), // Icon thùng rác
                                onPressed: (item.isNew == true)
                                    ? () => showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return StatefulBuilder(
                                              builder: (BuildContext context, StateSetter setState) {
                                                return Scaffold(
                                                  resizeToAvoidBottomInset: false,
                                                  backgroundColor: Colors.transparent,
                                                  body: Center(
                                                    child: Container(
                                                      padding: EdgeInsets.all(20),
                                                      margin: EdgeInsets.symmetric(horizontal: 20),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(15),
                                                      ),
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          const Text(
                                                            'Vui lòng nhập lí do hủy của bạn?',
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          SizedBox(height: 10),
                                                          TextField(
                                                            controller: _textController,
                                                            onChanged: (text) {
                                                              // Gọi setState để cập nhật giao diện khi giá trị TextField thay đổi
                                                              setState(() {});
                                                            },
                                                            decoration: InputDecoration(
                                                              labelText: 'Nhập lí do',
                                                              border: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(10),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(height: 20),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                            children: [
                                                              ElevatedButton(
                                                                style: ElevatedButton.styleFrom(
                                                                  backgroundColor: Colors.red,
                                                                ),
                                                                onPressed: () {
                                                                  Navigator.of(context).pop();
                                                                  _btnController.reset();
                                                                },
                                                                child: const Text(
                                                                  'Không',
                                                                  style: TextStyle(
                                                                    fontFamily: 'Comfortaa',
                                                                    fontSize: 13,
                                                                    color: Colors.white,
                                                                    fontWeight: FontWeight.w700,
                                                                  ),
                                                                ),
                                                              ),
                                                              ElevatedButton(
                                                                style: ElevatedButton.styleFrom(
                                                                  backgroundColor: Colors.green,
                                                                ),
                                                                onPressed: _textController.text.isNotEmpty ? () => _onSave(item.soKhung, _textController.text) : null,
                                                                child: const Text(
                                                                  'Đồng ý',
                                                                  style: TextStyle(
                                                                    fontFamily: 'Comfortaa',
                                                                    fontSize: 13,
                                                                    color: Colors.white,
                                                                    fontWeight: FontWeight.w700,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        )
                                    : null,
                              ),
                              _buildTableCell(
                                item.ngay ?? "",
                                isCancelled: isCancelled,
                              ),
                              _buildTableCell(
                                item.donVi ?? "",
                                isCancelled: isCancelled,
                              ),
                              _buildTableCell(
                                item.soKhung ?? "",
                                isCancelled: isCancelled,
                              ),
                              _buildTableCell(
                                item.loaiXe ?? "",
                                isCancelled: isCancelled,
                              ),
                              _buildTableCell(
                                item.mauXe ?? "",
                                isCancelled: isCancelled,
                              ),
                              _buildTableCell(
                                item.noiGiao ?? "",
                                isCancelled: isCancelled,
                              ),
                              _buildTableCell(
                                item.nguoiPhuTrach ?? "",
                                isCancelled: isCancelled,
                              ),
                              _buildTableCell(
                                item.liDoHuyXe ?? "",
                                isCancelled: isCancelled,
                              ),
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

  Widget _buildTableCell(String content, {bool isCancelled = false, Color textColor = Colors.black}) {
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
          decoration: isCancelled ? TextDecoration.lineThrough : TextDecoration.none,
          decorationColor: Colors.red,
          decorationThickness: 3.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await getDSXGiaoXe(selectedFromDate, selectedToDate, doiTac_Id ?? "", KhoXeId ?? "", BaiXeId ?? "", DongXeId ?? "", maNhanVienController.text);
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
                                                    getDSXGiaoXe(selectedFromDate, selectedToDate, doiTac_Id ?? "", newValue, BaiXeId ?? "", DongXeId ?? "", maNhanVienController.text);
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
                                                      getDSXGiaoXe(selectedFromDate, selectedToDate, doiTac_Id ?? "", KhoXeId ?? "", BaiXeId ?? "", '', maNhanVienController.text);
                                                    } else {
                                                      getDSXGiaoXe(selectedFromDate, selectedToDate, doiTac_Id ?? "", KhoXeId ?? "", BaiXeId ?? "", newValue, maNhanVienController.text);
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
                                                        getDSXGiaoXe(selectedFromDate, selectedToDate, doiTac_Id ?? "", KhoXeId ?? "", '', DongXeId ?? "", maNhanVienController.text);
                                                      } else {
                                                        getDataDongXe();
                                                        getDSXGiaoXe(selectedFromDate, selectedToDate, doiTac_Id ?? "", KhoXeId ?? "", newValue, DongXeId ?? "", maNhanVienController.text);
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
                                  SizedBox(height: 5),
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
                                                        getDSXGiaoXe(selectedFromDate, selectedToDate, '', KhoXeId ?? "", BaiXeId ?? "", DongXeId ?? "", maNhanVienController.text);
                                                      } else {
                                                        getDSXGiaoXe(selectedFromDate, selectedToDate, newValue, KhoXeId ?? "", BaiXeId ?? "", DongXeId ?? "", maNhanVienController.text);
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
                                            getDSXGiaoXe(selectedFromDate, selectedToDate, doiTac_Id ?? "", KhoXeId ?? "", BaiXeId ?? "", DongXeId ?? "", maNhanVienController.text);
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
                                          'Đã thực hiện:${_dn != null && _dn!.isNotEmpty ? _dn?.where((xe) => xe.liDoHuyXe == null).length.toString() : "0"}/${_dn != null ? _dn?.length.toString() : "0"} (Đã hủy:${_dn != null && _dn!.isNotEmpty ? _dn?.where((xe) => xe.liDoHuyXe != null).length.toString() : "0"}) ',
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
