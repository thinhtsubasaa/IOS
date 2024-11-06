import 'dart:convert';
import 'package:Thilogi/blocs/user_bloc.dart';
import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/models/baixe.dart';
import 'package:Thilogi/models/check.dart';
import 'package:Thilogi/models/doitac.dart';
import 'package:Thilogi/models/dongxe.dart';
import 'package:Thilogi/models/dsxchoxuat.dart';
import 'package:Thilogi/models/khoxe.dart';
import 'package:Thilogi/models/lsvanchuyen.dart';
import 'package:Thilogi/models/noiden.dart';
import 'package:Thilogi/services/app_service.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:Thilogi/widgets/custom_title.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:sizer/sizer.dart';
import '../../widgets/loading.dart';
import 'package:http/http.dart' as http;

class CustomBodyCheckRaCong extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: BodyCheckRaCongScreen());
  }
}

class BodyCheckRaCongScreen extends StatefulWidget {
  const BodyCheckRaCongScreen({Key? key}) : super(key: key);

  @override
  _BodyCheckRaCongScreenState createState() => _BodyCheckRaCongScreenState();
}

class _BodyCheckRaCongScreenState extends State<BodyCheckRaCongScreen> with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  bool _loading = false;
  String? doiTac_Id;
  List<LSVanChuyenModel>? _dn;
  List<LSVanChuyenModel>? get dn => _dn;
  List<DoiTacModel>? _doitacList;
  List<DoiTacModel>? get doitacList => _doitacList;
  List<DS_ChoXuatModel>? _cx;
  List<DS_ChoXuatModel>? get cx => _cx;
  List<NoiDenModel>? _noidenList;
  List<NoiDenModel>? get noidenList => _noidenList;
  bool _hasError = false;
  bool get hasError => _hasError;
  String? selectedDate;
  String? selectedFromDate;
  String? selectedToDate;

  String? _errorCode;
  String? get errorCode => _errorCode;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _success = false;
  bool get success => _success;

  String? _message;
  String? get message => _message;
  LSVanChuyenModel? _data;
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  final TextEditingController textEditingController = TextEditingController();
  final TextEditingController maNhanVienController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

  String? BienSo;
  String? BaiXeId;
  String? KhoXeId;
  String? DongXeId;
  CheckModel? _model;
  List<KhoXeModel>? _khoxeList;
  List<KhoXeModel>? get khoxeList => _khoxeList;
  List<DongXeModel>? _dongxeList;
  List<DongXeModel>? get dongxeList => _dongxeList;
  List<BaiXeModel>? _baixeList;
  List<BaiXeModel>? get baixeList => _baixeList;
  List<bool> _checkedItems = [];
  late UserBloc _ub;
  CheckModel? _scan;
  CheckModel? get scan => _scan;
  String _qrData = '';
  final _qrDataController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ub = Provider.of<UserBloc>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showConfirmationDialogXacNhan(context);
    });
    setState(() {
      KhoXeId = "9001663f-0164-477d-b576-09c7541f4cce";
      // getBaiXeList(KhoXeId ?? "");
      _loading = false;
    });
    getDataKho();
    // getDataDongXe();
    getDoiTac();
    selectedFromDate = DateFormat('MM/dd/yyyy').format(DateTime.now().add(Duration(days: -30)));
    selectedToDate = DateFormat('MM/dd/yyyy').format(DateTime.now().add(Duration(days: 1)));
  }

  @override
  void dispose() {
    _textController.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  Future<void> getBienSo(String? tuNgay, String? denNgay, String? doiTac_Id, String? KhoXe_Id, String? BaiXe_Id, String? keyword) async {
    try {
      final http.Response response = await requestHelper.getData('Kho/GetListBienSo_New?TuNgay=$tuNgay&DenNgay=$denNgay&DoiTac_Id=$doiTac_Id&KhoXe_Id=$KhoXe_Id&BaiXe_Id=$BaiXe_Id&keyword=$keyword');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("BienSo: ${decodedData}");

        _noidenList = (decodedData as List).map((item) => NoiDenModel.fromJson(item)).toList();

        // Gọi setState để cập nhật giao diện
        setState(() {
          BienSo = null;
          _loading = false;
        });
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Future<void> postData(String? soKhung, bool check, String? maPin) async {
    _isLoading = true;

    try {
      final http.Response response = await requestHelper.postData('Kho/CheckRaCong?SoKhung=$soKhung&Check=$check&MaPin=$maPin', _data?.toJson());
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

  _onSave(String? soKhung, bool? check, String? maPin) {
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
        print("Mapin: ${_model?.maPin ?? ""}");
        postData(soKhung ?? "", check ?? false, _model?.maPin ?? "").then((_) {
          print("loading: ${_loading}");
        });
      }
    });
  }

  Future<void> getBaoVe(String? maPin) async {
    _scan = null;
    _isLoading = true;
    try {
      final http.Response response = await requestHelper.getData('Kho/GetBaoVe?MaPin=$maPin');

      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("data2: ${decodedData}");
        if (decodedData != null) {
          _scan = CheckModel(
            id: decodedData['id'],
            fullName: decodedData['fullName'],
            maNhanVien: decodedData['maNhanVien'],
            maPin: decodedData['maPin'],
          );
        }
        Navigator.of(context).pop();
      } else {
        String errorMessage = response.body.replaceAll('"', '');
        notifyListeners();
        QuickAlert.show(
            context: context,
            type: QuickAlertType.info,
            title: '',
            text: errorMessage,
            confirmBtnText: 'Đồng ý',
            onConfirmBtnTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            });
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  _onScan(value) {
    getBaoVe(value).then((_) {
      setState(() {
        _qrData = value;
        if (scan == null) {
          _qrData = '';
          _qrDataController.text = '';
        }
        _model = scan;
        print("model: ${_model?.fullName}");
      });
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

        getBienSo(selectedFromDate, selectedToDate, doiTac_Id ?? "", KhoXeId ?? "", BaiXeId ?? "", maNhanVienController.text);
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
          // KhoXeId = "9001663f-0164-477d-b576-09c7541f4cce";
          _noidenList = [];
          _loading = false;
        });
        getBienSo(selectedFromDate, selectedToDate, doiTac_Id ?? "", KhoXeId ?? "", BaiXeId ?? "", maNhanVienController.text);
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
        getBienSo(selectedFromDate, selectedToDate, doiTac_Id ?? "", KhoXeId ?? "", BaiXeId ?? "", maNhanVienController.text);
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Future<void> getDSXVanChuyen(String? tuNgay, String? denNgay, String? BienSo, String? DongXe_Id) async {
    _dn = [];
    try {
      final http.Response response = await requestHelper.getData('Kho/GetDanhSachXeTrenLongAll?TuNgay=$tuNgay&DenNgay=$denNgay&BienSo=$BienSo&DongXe_Id=$DongXe_Id');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("data: " + decodedData.toString());
        if (decodedData != null) {
          _dn = (decodedData as List).map((item) => LSVanChuyenModel.fromJson(item)).toList();

          // Gọi setState để cập nhật giao diện
          setState(() {
            _checkedItems = List<bool>.filled(_dn?.length ?? 0, false);
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
      await getBienSo(selectedFromDate, selectedToDate, doiTac_Id ?? "", KhoXeId ?? "", BaiXeId ?? "", maNhanVienController.text);
    }
  }

  Widget _buildTableOptions(BuildContext context) {
    int index = 0; // Biến đếm số thứ tự

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: MediaQuery.of(context).size.width * 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '',
              style: TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            Table(
              border: TableBorder.all(),
              columnWidths: const {
                0: FlexColumnWidth(0.2),
                1: FlexColumnWidth(0.3),
                2: FlexColumnWidth(0.3),
                3: FlexColumnWidth(0.3),
                4: FlexColumnWidth(0.3),
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
                      child: _buildTableCell('Xác nhận bảo vệ', textColor: Colors.white), // Tiêu đề checkbox
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
                      child: _buildTableCell('Màu xe', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Đơn vị vận chuyển', textColor: Colors.white),
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
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Ngày nhận', textColor: Colors.white),
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
                    0: FlexColumnWidth(0.2),
                    1: FlexColumnWidth(0.3),
                    2: FlexColumnWidth(0.3),
                    3: FlexColumnWidth(0.3),
                    4: FlexColumnWidth(0.3),
                    5: FlexColumnWidth(0.3),
                    6: FlexColumnWidth(0.3),
                    7: FlexColumnWidth(0.3),
                    8: FlexColumnWidth(0.3),
                  },
                  children: [
                    ..._dn
                            ?.asMap()
                            .map((i, item) {
                              index++; // Tăng số thứ tự sau mỗi lần lặp
                              return MapEntry(
                                  i,
                                  TableRow(
                                    decoration: BoxDecoration(
                                      color: item.isCheck == true ? Colors.green.withOpacity(0.3) : Colors.white, // Màu nền thay đổi theo giá trị isCheck
                                    ),
                                    children: [
                                      Checkbox(
                                        value: item.isCheck ?? false,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            _checkedItems[i] = value ?? false;
                                            item.isCheck = _checkedItems[i];
                                            _onSave(item.soKhung, item.isCheck ?? false, _model?.maPin ?? ""); // Gọi hàm lưu dữ liệu
                                          });
                                        },
                                      ),

                                      _buildTableCell(item.soKhung ?? ""),
                                      _buildTableCell(item.loaiXe ?? ""),
                                      _buildTableCell(item.mauXe ?? ""),
                                      _buildTableCell(item.donVi ?? ""),
                                      _buildTableCell(item.thongTinChiTiet ?? ""),
                                      _buildTableCell(item.thongTinVanChuyen ?? ""),
                                      _buildTableCell(item.nguoiVanChuyen ?? ""),
                                      _buildTableCell(item.ngay ?? ""),
                                      // Cột checkbox
                                    ],
                                  ));
                            })
                            .values
                            .toList() ??
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
      padding: const EdgeInsets.all(5),
      child: SelectableText(
        content,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Comfortaa',
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  void _showConfirmationDialogMaPin(BuildContext context) {
    setState(() {
      _onScan(_textController.text);
    });

    // Navigator.of(context).pop();
  }

  void _showConfirmationDialogXacNhan(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
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
                        'Vui lòng nhập mã pin của bạn?',
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
                          labelText: 'Nhập mã pin',
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

                          // RoundedLoadingButton(
                          //   child: Text(
                          //     'Đồng ý',
                          //     style: TextStyle(
                          //       fontFamily: 'Comfortaa',
                          //       fontSize: 13,
                          //       color: Colors.white,
                          //       fontWeight: FontWeight.w700,
                          //     ),
                          //   ),
                          //   width: 40.w,
                          //   controller: _btnController, // Controller cho nút
                          //   color: Colors.green,
                          //   onPressed: _textController.text.isNotEmpty ? () => _showConfirmationDialogMaPin(context) : null,
                          // ),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: _textController.text.isNotEmpty ? () => _showConfirmationDialogMaPin(context) : null,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await getBienSo(
          selectedFromDate,
          selectedToDate,
          doiTac_Id ?? "",
          KhoXeId ?? "",
          BaiXeId ?? "",
          maNhanVienController.text,
        );
        _dn = [];
      }, // Gọi hàm tải lại dữ liệu
      child: Container(
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
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                                    Container(
                                      padding: EdgeInsets.only(left: 0),
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
                                        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.blue),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.calendar_today, color: Colors.blue),
                                            // SizedBox(width: 2),
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
                                    SelectableText(
                                      _model?.fullName ?? "",
                                      style: const TextStyle(
                                        fontFamily: 'Comfortaa',
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                    // Expanded(
                                    //   child: ElevatedButton(
                                    //       style: ElevatedButton.styleFrom(
                                    //         backgroundColor: Colors.green,
                                    //         shape: RoundedRectangleBorder(
                                    //           borderRadius: BorderRadius.circular(15.0),
                                    //         ),
                                    //         minimumSize: Size(200, 50),
                                    //       ),
                                    //       onPressed: () => _showConfirmationDialogXacNhan(context),
                                    //       child: const Text(
                                    //         'Xác nhận',
                                    //         style: TextStyle(
                                    //           fontFamily: 'Comfortaa',
                                    //           color: Colors.white,
                                    //           fontWeight: FontWeight.w700,
                                    //           fontSize: 10,
                                    //         ),
                                    //       )),
                                    // ),
                                  ]),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  const Divider(height: 1, color: Color(0xFFA71C20)),
                                  const SizedBox(
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
                                                    getDoiTac();
                                                    getBienSo(selectedFromDate, selectedToDate, doiTac_Id ?? "", newValue, BaiXeId ?? "", maNhanVienController.text);
                                                    _dn = [];
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
                                      // Expanded(
                                      //   child: Container(
                                      //       padding: EdgeInsets.only(top: MediaQuery.of(context).size.height < 600 ? 0 : 5),
                                      //       decoration: BoxDecoration(
                                      //         borderRadius: BorderRadius.circular(5),
                                      //         border: Border.all(
                                      //           color: const Color(0xFFBC2925),
                                      //           width: 1.5,
                                      //         ),
                                      //       ),
                                      //       child: DropdownButtonHideUnderline(
                                      //         child: DropdownButton2<String>(
                                      //           isExpanded: true,
                                      //           items: _dongxeList?.map((item) {
                                      //             return DropdownMenuItem<String>(
                                      //               value: item.id,
                                      //               child: Container(
                                      //                 child: Text(
                                      //                   item.tenDongXe ?? "",
                                      //                   textAlign: TextAlign.center,
                                      //                   style: const TextStyle(
                                      //                     fontFamily: 'Comfortaa',
                                      //                     fontSize: 14,
                                      //                     fontWeight: FontWeight.w600,
                                      //                     color: AppConfig.textInput,
                                      //                   ),
                                      //                 ),
                                      //               ),
                                      //             );
                                      //           }).toList(),
                                      //           value: DongXeId,
                                      //           onChanged: (newValue) async {
                                      //             setState(() {
                                      //               DongXeId = newValue;
                                      //             });
                                      //             if (newValue != null) {
                                      //               if (newValue == '') {
                                      //                 getDSXVanChuyen(selectedFromDate, selectedToDate, BienSo ?? "", '');
                                      //               } else {
                                      //                 getDSXVanChuyen(selectedFromDate, selectedToDate, BienSo ?? "", newValue);

                                      //                 print("objectcong : ${newValue}");
                                      //               }
                                      //             }
                                      //           },
                                      //           buttonStyleData: const ButtonStyleData(
                                      //             padding: EdgeInsets.symmetric(horizontal: 16),
                                      //             height: 40,
                                      //             width: 200,
                                      //           ),
                                      //           dropdownStyleData: const DropdownStyleData(
                                      //             maxHeight: 200,
                                      //           ),
                                      //           menuItemStyleData: const MenuItemStyleData(
                                      //             height: 40,
                                      //           ),
                                      //           dropdownSearchData: DropdownSearchData(
                                      //             searchController: textEditingController,
                                      //             searchInnerWidgetHeight: 50,
                                      //             searchInnerWidget: Container(
                                      //               height: 50,
                                      //               padding: const EdgeInsets.only(
                                      //                 top: 8,
                                      //                 bottom: 4,
                                      //                 right: 8,
                                      //                 left: 8,
                                      //               ),
                                      //               child: TextFormField(
                                      //                 expands: true,
                                      //                 maxLines: null,
                                      //                 controller: textEditingController,
                                      //                 decoration: InputDecoration(
                                      //                   isDense: true,
                                      //                   contentPadding: const EdgeInsets.symmetric(
                                      //                     horizontal: 10,
                                      //                     vertical: 8,
                                      //                   ),
                                      //                   hintText: 'Tìm bãi xe',
                                      //                   hintStyle: const TextStyle(fontSize: 12),
                                      //                   border: OutlineInputBorder(
                                      //                     borderRadius: BorderRadius.circular(8),
                                      //                   ),
                                      //                 ),
                                      //               ),
                                      //             ),
                                      //             searchMatchFn: (item, searchValue) {
                                      //               if (item is DropdownMenuItem<String>) {
                                      //                 // Truy cập vào thuộc tính value để lấy ID của ViTriModel
                                      //                 String itemId = item.value ?? "";
                                      //                 // Kiểm tra ID của item có tồn tại trong _vl.vitriList không
                                      //                 return _dongxeList?.any((viTri) => viTri.id == itemId && viTri.tenDongXe?.toLowerCase().contains(searchValue.toLowerCase()) == true) ?? false;
                                      //               } else {
                                      //                 return false;
                                      //               }
                                      //             },
                                      //           ),
                                      //           onMenuStateChange: (isOpen) {
                                      //             if (!isOpen) {
                                      //               textEditingController.clear();
                                      //             }
                                      //           },
                                      //         ),
                                      //       )),
                                      // ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Container(
                                    height: MediaQuery.of(context).size.height < 600 ? 10.h : 5.h,
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
                                              "DVVC",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
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
                                                              fontSize: 12,
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
                                                        getBienSo(selectedFromDate, selectedToDate, '', KhoXeId ?? "", BaiXeId ?? "", maNhanVienController.text);
                                                        _dn = [];
                                                      } else {
                                                        getBienSo(selectedFromDate, selectedToDate, newValue, KhoXeId ?? "", BaiXeId ?? "", maNhanVienController.text);
                                                        _dn = [];

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
                                    height: 4,
                                  ),
                                  Container(
                                    height: MediaQuery.of(context).size.height < 600 ? 10.h : 5.h,
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
                                              "Biển số",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
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
                                          child: Container(
                                              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height < 600 ? 0 : 5),
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButton2<String>(
                                                  isExpanded: true,
                                                  items: _noidenList?.map((item) {
                                                    return DropdownMenuItem<String>(
                                                      value: item.bienSo,
                                                      child: Container(
                                                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
                                                        child: SingleChildScrollView(
                                                          scrollDirection: Axis.horizontal,
                                                          child: Text(
                                                            item.bienSo ?? "",
                                                            textAlign: TextAlign.center,
                                                            style: const TextStyle(
                                                              fontFamily: 'Comfortaa',
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w600,
                                                              color: AppConfig.textInput,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                  value: BienSo,
                                                  onChanged: (newValue) {
                                                    setState(() {
                                                      BienSo = newValue;
                                                    });
                                                    if (newValue != null) {
                                                      getDSXVanChuyen(selectedFromDate, selectedToDate, newValue, DongXeId ?? "");

                                                      print("object : ${BienSo}");
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
                                                          hintText: 'Tìm biển số',
                                                          hintStyle: const TextStyle(fontSize: 12),
                                                          border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    searchMatchFn: (item, searchValue) {
                                                      final itemValue = item.value?.toLowerCase().toString() ?? ''; // Kiểm tra null
                                                      return itemValue.contains(searchValue.toLowerCase());
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
                                    height: 4,
                                  ),
                                  Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          'Tổng số xe đã thực hiện: ${_dn != null && _dn!.isNotEmpty ? _dn?.where((xe) => xe.isCheck == true).length.toString() : "0"}/${_dn != null ? _dn?.length.toString() : "0"}',
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
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 11,
              padding: EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppConfig.bottom,
              ),
              child: customTitle(
                "KIỂM TRA XE LÊN LỒNG: ${_ub?.congBaoVe?.toUpperCase() ?? ""}",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
