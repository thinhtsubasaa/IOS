import 'dart:convert';
import 'package:Thilogi/models/lsxdieuchuyen.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../widgets/loading.dart';
import 'package:http/http.dart' as http;

class CustomBodyLSDieuChuyen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: BodyLSDieuChuyenScreen());
  }
}

class BodyLSDieuChuyenScreen extends StatefulWidget {
  const BodyLSDieuChuyenScreen({Key? key}) : super(key: key);

  @override
  _BodyLSDieuChuyenScreenState createState() => _BodyLSDieuChuyenScreenState();
}

class _BodyLSDieuChuyenScreenState extends State<BodyLSDieuChuyenScreen> with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();
  String _qrData = '';
  final _qrDataController = TextEditingController();
  bool _loading = false;

  String? id;
  String? KhoXeId;

  List<LSX_ChuyenBaiModel>? _dn;
  List<LSX_ChuyenBaiModel>? get dn => _dn;
  bool _hasError = false;
  bool get hasError => _hasError;
  String? selectedDate;

  String? _errorCode;
  String? get errorCode => _errorCode;
  final TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    getDSXDieuChuyen(selectedDate);
  }

  Future<void> getDSXDieuChuyen(String? ngay) async {
    _dn = [];
    try {
      final http.Response response = await requestHelper.getData('KhoThanhPham/GetDanhSachXeDieuChuyen?Ngay=$ngay');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        _dn = (decodedData as List).map((item) => LSX_ChuyenBaiModel.fromJson(item)).toList();

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
      await getDSXDieuChuyen(selectedDate);

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
        return bTime.compareTo(aTime); // Sắp xếp giảm dần
      } catch (e) {
        return 0;
      }
    });
    int countNotDash = _dn?.where((item) => item.noiDen != "-").length ?? 0;
    // int countDash = _dn?.where((item) => item.noiDen == "-").length ?? 0;

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tổng số xe đã thực hiện: ${countNotDash}/${_dn?.length.toString() ?? ""}',
            style: const TextStyle(
              fontFamily: 'Comfortaa',
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          SingleChildScrollView(
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
                      1: FlexColumnWidth(0.35),
                      2: FlexColumnWidth(0.3),
                      3: FlexColumnWidth(0.2),
                      4: FlexColumnWidth(0.35),
                      5: FlexColumnWidth(0.35),
                    },
                    children: [
                      TableRow(
                        children: [
                          Container(
                            color: Colors.red,
                            child: _buildTableCell('Giờ nhận', textColor: Colors.white),
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
                            child: _buildTableCell('Nơi đi', textColor: Colors.white),
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
                    height: MediaQuery.of(context).size.height, // Chiều cao cố định
                    child: SingleChildScrollView(
                      child: Table(
                        border: TableBorder.all(),
                        columnWidths: const {
                          0: FlexColumnWidth(0.15),
                          1: FlexColumnWidth(0.35),
                          2: FlexColumnWidth(0.3),
                          3: FlexColumnWidth(0.2),
                          4: FlexColumnWidth(0.35),
                          5: FlexColumnWidth(0.35),
                        },
                        children: [
                          ..._dn?.map((item) {
                                index++; // Tăng số thứ tự sau mỗi lần lặp
                                bool highlightRed = item.noiDen == "-";
                                return TableRow(
                                  children: [
                                    // _buildTableCell(index.toString()), // Số thứ tự
                                    _buildTableCell(item.gioNhan ?? "", highlightRed: highlightRed),
                                    _buildTableCell(item.soKhung ?? "", highlightRed: highlightRed),
                                    _buildTableCell(item.loaiXe ?? "", highlightRed: highlightRed),
                                    _buildTableCell(item.mauXe ?? "", highlightRed: highlightRed),
                                    _buildTableCell(item.noiDi ?? "", highlightRed: highlightRed),
                                    _buildTableCell(item.noiDen ?? "", highlightRed: highlightRed),
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
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String content, {Color textColor = Colors.black, bool highlightRed = false}) {
    if (highlightRed) {
      textColor = Colors.red;
    }
    return Container(
      padding: const EdgeInsets.all(8),
      child: SelectableText(
        content,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Comfortaa',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await getDSXDieuChuyen(selectedDate);
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
                                        'Danh sách xe chuyển bãi',
                                        style: TextStyle(
                                          fontFamily: 'Comfortaa',
                                          fontSize: 15,
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
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  const Divider(height: 1, color: Color(0xFFA71C20)),
                                  Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
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
