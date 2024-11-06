import 'package:flutter/material.dart';
import 'package:Thilogi/config/config.dart';

import 'package:Thilogi/pages/nhanxe/popup/custom_popup_NhanXe2.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_bottom.dart';
import '../../widgets/custom_title.dart';

class NhanXe3Page extends StatelessWidget {
  String? soKhung;
  String? tenMau;
  String? tenSanPham;
  List phuKien;

  NhanXe3Page({
    required this.soKhung,
    required this.tenMau,
    required this.tenSanPham,
    required this.phuKien,
  });

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
                  // Background Image
                  Positioned.fill(
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.8),
                        BlendMode.srcATop,
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(AppConfig.backgroundImagePath),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Main Content
                  Column(
                    children: [
                      Container(
                        width: 100.w,
                        child: Column(
                          children: [
                            // CustomCardVIN(),
                            // const SizedBox(height: 20),
                            // ignore: avoid_unnecessary_containers
                            // Container(
                            //   child: Column(
                            //     children: [
                            //       customTitle('KIỂM TRA - NHẬN XE'),
                            //       SizedBox(height: 10),
                            //       // customBottom(
                            //       //   "Kiểm tra chất lượng, tình trạng xe;\n Xác nhận nhận xe vào kho THILOGI,",
                            //       // ),
                            //     ],
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Popup
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: PopUp2(
                        soKhung: soKhung ?? "",
                        tenMau: tenMau ?? "",
                        tenSanPham: tenSanPham ?? "",
                        phuKien: phuKien ?? []),
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
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF818180),
          width: 1,
        ),
        color: Colors.white,
      ),
      child: Row(
        children: [
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
              String barcodeScanResult =
                  await FlutterBarcodeScanner.scanBarcode(
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
