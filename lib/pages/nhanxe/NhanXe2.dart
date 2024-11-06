import 'package:flutter/material.dart';
import 'package:Thilogi/config/config.dart';

import 'package:Thilogi/pages/nhanxe/popup/custom_popup_NhanXe.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_bottom.dart';
import '../../widgets/custom_title.dart';

class NhanXe2Page extends StatelessWidget {
  String? soKhung;
  String? soMay;
  String? tenMau;
  String? tenSanPham;
  String? ngayXuatKhoView;
  String? tenTaiXe;
  String? ghiChu;
  String? tenKho;
  List phuKien;

  NhanXe2Page(
      {required this.soKhung,
      required this.soMay,
      required this.tenMau,
      required this.tenSanPham,
      required this.ngayXuatKhoView,
      required this.tenTaiXe,
      required this.ghiChu,
      required this.tenKho,
      required this.phuKien});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.8),
                        BlendMode.srcATop,
                      ),
                      child: Container(
                          // decoration: BoxDecoration(
                          //   image: DecorationImage(
                          //     image: AssetImage(AppConfig.backgroundImagePath),
                          //     fit: BoxFit.cover,
                          //   ),
                          // ),
                          ),
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 5.0.h), // 5% of the screen's height
                      // CustomCardQLKhoXe(),
                      // CustomCardVIN(),
                      // SizedBox(height: 2.0.h),
                      // // customTitle('KIỂM TRA - NHẬN XE'),
                      // SizedBox(height: 1.0.h),
                      // customBottom(
                      //   "Kiểm tra chất lượng, tình trạng xe;\n Xác nhận nhận xe vào kho THILOGI,",
                      // ),
                    ],
                  ),

                  // Popup
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: PopUp(
                      soKhung: soKhung ?? "",
                      soMay: soMay ?? "",
                      tenMau: tenMau ?? "",
                      tenSanPham: tenSanPham ?? "",
                      ngayXuatKhoView: ngayXuatKhoView ?? "",
                      tenTaiXe: tenTaiXe ?? "",
                      ghiChu: ghiChu ?? "",
                      tenKho: tenKho ?? "",
                      phuKien: phuKien ?? [],
                      lstFiles: [],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class CustomCardVIN extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 334,
      height: 50,
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        // Đặt border radius cho card
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF818180), // Màu của đường viền
          width: 1, // Độ dày của đường viền
        ),
        color: Colors.white, // Màu nền của card
      ),
      child: Row(
        children: [
          // Phần Text 1
          Container(
            width: 76.48,
            height: 48,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5),
                bottomLeft: Radius.circular(5),
              ),
              color: Color(0xFFA71C20),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Số Khung\n(VIN)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Comfortaa',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.08,
                    letterSpacing: 0,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          const Text(
            'MALA851CBHM557809',
            style: TextStyle(
              fontFamily: 'Comfortaa',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.11,
              letterSpacing: 0,
              color: Color(0xFFA71C20),
            ),
          ),
          const SizedBox(width: 3),

          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            color: Colors.black,
            onPressed: () async {
              String barcodeScanResult = await FlutterBarcodeScanner.scanBarcode(
                '#A71C20',
                'Cancel',
                false,
                ScanMode.QR,
              );
              print(barcodeScanResult);
            },
          ),
        ],
      ),
    );
  }
}
