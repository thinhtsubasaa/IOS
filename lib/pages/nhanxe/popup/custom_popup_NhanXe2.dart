import 'package:flutter/material.dart';

import 'package:sizer/sizer.dart';

import '../../../config/config.dart';

// ignore: use_key_in_widget_constructors
class PopUp2 extends StatelessWidget {
  String soKhung;
  String tenMau;
  String tenSanPham;
  List phuKien;

  PopUp2({
    required this.soKhung,
    required this.tenMau,
    required this.tenSanPham,
    required this.phuKien,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: Container(
        alignment: Alignment.bottomCenter,
        constraints: BoxConstraints(
          maxHeight: screenHeight *
              0.9, // Đặt chiều cao tối đa của popup là 90% của chiều cao màn hình
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white.withOpacity(0.9),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(
                context), // Đặt phần này ở đây để nó không cuộn cùng nội dung
            _buildInputFields(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCarDetails(context),
                    _buildTableOptions(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 10.h,
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        color: Colors.red,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 50),
          const Text(
            'NHẬN XE',
            style: TextStyle(
              fontFamily: 'Myriad Pro',
              fontSize: 25,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInputFields() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin xe kiểm tra',
            style: TextStyle(
              fontFamily: 'Comfortaa',
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Divider(
            height: 1,
            color: AppConfig.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildCarDetails(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(left: 10, right: 10),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.9,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        tenSanPham,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontFamily: 'Coda Caption',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppConfig.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 1, color: Color(0xFFCCCCCC)),
              Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    showInfoXe(
                      'Số khung (VIN):',
                      soKhung,
                    ),
                    showInfoXe(
                      'Màu:',
                      tenMau,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFCCCCCC)),
              const Divider(height: 1, color: Color(0xFFCCCCCC)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableOptions(BuildContext context) {
    int index = 0; // Biến đếm số thứ tự
    return Container(
      width: 100.w,
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DS Option theo xe',
            style: TextStyle(
              fontFamily: 'Comfortaa',
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          Table(
            border: TableBorder.all(),
            columnWidths: {
              0: FlexColumnWidth(0.15),
              1: FlexColumnWidth(0.5),
              2: FlexColumnWidth(0.25),
            },
            children: [
              TableRow(
                children: [
                  Container(
                    color: Colors.red,
                    child: _buildTableCell('TT', textColor: Colors.white),
                  ),
                  Container(
                    color: Colors.red,
                    child:
                        _buildTableCell('Tên Option', textColor: Colors.white),
                  ),
                  Container(
                    color: Colors.red,
                    child: _buildTableCell('Số lượng', textColor: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          Container(
            height:
                MediaQuery.of(context).size.height * 0.5, // Chiều cao cố định
            child: SingleChildScrollView(
              child: Table(
                border: TableBorder.all(),
                columnWidths: {
                  0: FlexColumnWidth(0.15),
                  1: FlexColumnWidth(0.5),
                  2: FlexColumnWidth(0.25),
                },
                children: [
                  ...phuKien?.map((item) {
                        index++; // Tăng số thứ tự sau mỗi lần lặp

                        return TableRow(
                          children: [
                            _buildTableCell(index.toString()), // Số thứ tự
                            _buildTableCell(item.tenPhuKien ?? ""),
                            _buildTableCell(item.giaTri ??
                                ""), // Giả sử mỗi item có một trường 'giaTri'
                          ],
                        );
                      })?.toList() ??
                      [],
                ],
              ),
            ),
          ),
        ],
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
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}

Widget showInfoXe(String title, String value) {
  return Container(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Comfortaa',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF818180),
          ),
        ),
        SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Comfortaa',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppConfig.primaryColor,
          ),
        )
      ],
    ),
  );
}
