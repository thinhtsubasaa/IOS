import 'dart:convert';

import 'package:Thilogi/models/lsu_giaoxe.dart';

import 'package:Thilogi/services/request_helper.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import '../../services/app_service.dart';
import '../../widgets/loading.dart';
import 'package:http/http.dart' as http;

class CustomBodyLSGiaoXe extends StatelessWidget {
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
  LSX_GiaoXeModel? _data;
  List<LSX_GiaoXeModel>? _dn;
  List<LSX_GiaoXeModel>? get dn => _dn;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _message;
  String? get message => _message;
  bool _hasError = false;
  bool get hasError => _hasError;

  String? selectedDate;

  String? _errorCode;
  String? get errorCode => _errorCode;
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  final TextEditingController textEditingController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    getDSXGiaoXe(selectedDate);
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

  Future<void> getDSXGiaoXe(String? ngay) async {
    _dn = [];
    try {
      final http.Response response = await requestHelper.getData('KhoThanhPham/GetDanhSachXeGiaoXe?Ngay=$ngay');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        _dn = (decodedData as List).map((item) => LSX_GiaoXeModel.fromJson(item)).toList();

        // Gọi setState để cập nhật giao diện
        setState(() {
          _loading = false;
        });
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
      await getDSXGiaoXe(selectedDate);
      // getDSXDaNhan(selectedDate);

      setState(() {
        _loading = false;
      });
    }
  }

  Widget _buildTableOptions(BuildContext context) {
    int index = 0;

    const String defaultDate = "1970-01-01 ";

    _dn?.sort((a, b) {
      try {
        DateTime aTime = DateFormat("yyyy-MM-dd HH:mm").parse(defaultDate + (a.gioNhan ?? "00:00"));
        DateTime bTime = DateFormat("yyyy-MM-dd HH:mm").parse(defaultDate + (b.gioNhan ?? "00:00"));
        return bTime.compareTo(aTime);
      } catch (e) {
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
                0: FlexColumnWidth(0.15),
                1: FlexColumnWidth(0.15),
                2: FlexColumnWidth(0.3),
                3: FlexColumnWidth(0.3),
                4: FlexColumnWidth(0.3),
                5: FlexColumnWidth(0.3),
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
                      child: _buildTableCell('Giờ nhận', textColor: Colors.white),
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
                      child: _buildTableCell('Nơi giao', textColor: Colors.white),
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
              height: MediaQuery.of(context).size.height, // Chiều cao cố định
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(),
                  columnWidths: const {
                    0: FlexColumnWidth(0.15),
                    1: FlexColumnWidth(0.15),
                    2: FlexColumnWidth(0.3),
                    3: FlexColumnWidth(0.3),
                    4: FlexColumnWidth(0.3),
                    5: FlexColumnWidth(0.3),
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
                                item.gioNhan ?? "",
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
                                item.noiGiao ?? "",
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
          fontSize: 11,
          fontWeight: FontWeight.w700,
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
        await getDSXGiaoXe(selectedDate);
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Danh sách xe đã giao',
                                        style: TextStyle(
                                          fontFamily: 'Comfortaa',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
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
                                              SizedBox(width: 8),
                                              Text(
                                                selectedDate ?? 'Chọn ngày',
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
                                  Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(),
                                        Text(
                                          'Tổng số xe đã thực hiện:${_dn != null && _dn!.isNotEmpty ? _dn?.where((xe) => xe.liDoHuyXe == null).length.toString() : "0"}/${_dn != null ? _dn?.length.toString() : "0"} ',
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
