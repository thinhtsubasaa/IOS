import 'dart:async';

import 'package:Thilogi/blocs/TrackingXe.dart';
import 'package:Thilogi/models/lsnhapbai.dart';
import 'package:Thilogi/models/lsxuatxe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutter_datawedge/models/scan_result.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:sizer/sizer.dart';

import '../../config/config.dart';
import '../../models/lsxequa.dart';

class BodyTrackingXe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: 100.w,
        alignment: Alignment.bottomCenter,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height < 600 ? MediaQuery.of(context).size.height * 0.9 : MediaQuery.of(context).size.height * 0.6,
          // Đặt chiều cao tối đa của popup là 90% của chiều cao màn hình
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
          border: Border.all(
            color: Color(0xFFCCCCCC),
            width: 1,
          ),
          color: Colors.white,
        ),
        child: Stack(
          children: [
            // Phần Text 1
            Positioned(
              left: 0, // Adjust left position as needed
              top: 0, // Adjust top position as needed
              child: Container(
                width: 15.w,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  color: Color(0xFFF6C6C7),
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
                  child: Image.asset(
                    'assets/images/road.png',
                    height: MediaQuery.of(context).size.height < 600 ? MediaQuery.of(context).size.height * 0.9 : MediaQuery.of(context).size.height * 0.6,
                  ),
                ),
              ),
            ),
            // Your BodyTrackingXe widget goes here
            Positioned(
              left: 0, // Adjust left position as needed
              top: 0, // Adjust top position as needed
              child: CustomTrackingXeScreen(),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTrackingXeScreen extends StatefulWidget {
  const CustomTrackingXeScreen({Key? key}) : super(key: key);

  @override
  _CustomTrackingXeScreenState createState() => _CustomTrackingXeScreenState();
}

class _CustomTrackingXeScreenState extends State<CustomTrackingXeScreen> with TickerProviderStateMixin, ChangeNotifier {
// ignore: use_key_in_widget_constructors
  late TrackingBloc _bl;
  late FlutterDataWedge dataWedge;

  String barcodeScanResult = '';
  String _qrData = '';
  final _qrDataController = TextEditingController();
  bool _loading = false;
  List<LSXeQuaModel>? _data;
  List<LSXeQuaModel>? get data => _data;
  List<LSNhapBaiModel>? _data1;
  List<LSNhapBaiModel>? get data1 => _data1;
  List<LSXuatXeModel>? _data2;
  List<LSXuatXeModel>? get data2 => _data2;
  late StreamSubscription<ScanResult> scanSubscription;
  @override
  void initState() {
    super.initState();
    _bl = Provider.of<TrackingBloc>(context, listen: false);

    dataWedge = FlutterDataWedge(profileName: "Example Profile");
    scanSubscription = dataWedge.onScanResult.listen((ScanResult result) {
      setState(() {
        barcodeScanResult = result.data;
      });
      print(barcodeScanResult);
      _handleBarcodeScanResult(barcodeScanResult);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget CardVin() {
    return Container(
      width: MediaQuery.of(context).size.width < 330 ? 100.w : 90.w,
      height: 8.h,
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF818180),
          width: 1,
        ),
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 20.w,
            height: 8.h,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                bottomLeft: Radius.circular(5),
              ),
              color: AppConfig.primaryColor,
            ),
            child: Center(
              child: Text(
                'Số khung\n(VIN)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                barcodeScanResult.isNotEmpty ? barcodeScanResult : '',
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFA71C20),
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            color: Colors.black,
            onPressed: () async {
              String result = await FlutterBarcodeScanner.scanBarcode(
                '#A71C20',
                'Cancel',
                false,
                ScanMode.QR,
              );
              setState(() {
                barcodeScanResult = result;
              });
              print(barcodeScanResult);
              _handleBarcodeScanResult(barcodeScanResult);
            },
          ),
        ],
      ),
    );
  }

  void _handleBarcodeScanResult(String barcodeScanResult) {
    print('ab:$barcodeScanResult');

    setState(() {
      _qrData = '';
      _qrDataController.text = barcodeScanResult;
      _data = null;
      _data1 = null;
      _data2 = null;
      Future.delayed(const Duration(seconds: 0), () {
        _qrData = barcodeScanResult;
        _qrDataController.text = barcodeScanResult;
        _onScan(barcodeScanResult);
      });
    });
  }

  String formatDateTime(String dateTimeString) {
    // Parse chuỗi ngày tháng thành đối tượng DateTime
    DateTime dateTime = DateTime.parse(dateTimeString);
    // Định dạng lại đối tượng DateTime thành chuỗi với định dạng mong muốn
    String formattedDate = DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);
    return formattedDate;
  }

  _onScan(value) {
    setState(() {
      _loading = true;
    });
    _bl.getTrackingXe(context, value).then((_) {
      setState(() {
        _qrData = value;
        if (_bl.lsxequa == null && _bl.lsnhapbai == null && _bl.lsxuatxe == null) {
          _qrData = '';
          _qrDataController.text = '';
        } else {
          _data = _bl.lsxequa;
          _data1 = _bl.lsnhapbai;
          _data2 = _bl.lsxuatxe;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            height: 20,
          ),
          // if (_data != null)
          //   Column(
          //     children: _data!.map((lsxeQuaModel) {
          //       return buildRowItem(
          //         customImage: CustomImage1(),
          //         textLine: formatDateTime(lsxeQuaModel.tuNgay ?? "") +
          //             ' - ' +
          //             (lsxeQuaModel.noiNhan ?? "") +
          //             ': ' +
          //             (lsxeQuaModel.nguoiNhan ?? ""),
          //       );
          //     }).toList(),
          //   ),
          // buildDivider(),
          // if (_data1 != null)
          //   Column(
          //     children: _data1!.map((item) {
          //       return buildRowItem(
          //         customImage: CustomImage2(),
          //         textLine: (item.ngay != null
          //                 ? formatDateTime(item.ngay ?? "")
          //                 : "") +
          //             '-' +
          //             (item.thongTinChiTiet ?? ""),
          //       );
          //     }).toList(),
          //   ),

          // buildDivider(),
          // if (_data2 != null)
          //   Column(
          //     children: _data2!.map((item) {
          //       return buildRowItem(
          //         customImage: CustomImage3(),
          //         textLine: (item.ngay != null
          //                 ? formatDateTime(item.ngay ?? "")
          //                 : "") +
          //             '-' +
          //             (item.thongTinChiTiet ?? "") +
          //             ': ' +
          //             (item.thongtinvanchuyen ?? ""),
          //       );
          //     }).toList(),
          //   ),
          // if (_data == null && _data1 == null && _data2 == null)
          //   Text('Không có dữ liệu'),
        ],
      ),
    );
  }
}

// class buildRowItem extends StatelessWidget {
//   final Widget customImage;
//   final String textLine;

//   const buildRowItem({
//     required this.customImage,
//     required this.textLine,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       constraints: BoxConstraints(
//         maxWidth: MediaQuery.of(context).size.width < 330
//             ? MediaQuery.of(context).size.width * 0.9
//             : MediaQuery.of(context).size.width * 0.9,
//       ),
//       height: 80, // Set a fixed height as needed
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           children: [
//             customImage,
//             // Custom Image widget goes here
//             RichText(
//               textAlign: TextAlign.left,
//               text: TextSpan(
//                 children: [
//                   TextSpan(
//                     text: '• ', // Dot character
//                     style: TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF0469B9),
//                     ),
//                   ),
//                   TextSpan(
//                     text: textLine,
//                     style: TextStyle(
//                       fontFamily: 'Comfortaa',
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF0469B9),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
class buildRowItem extends StatelessWidget {
  final Widget customImage;
  final String textLine;

  const buildRowItem({
    required this.customImage,
    required this.textLine,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width < 330 ? MediaQuery.of(context).size.width * 0.9 : MediaQuery.of(context).size.width * 0.9,
      ),
      // height: 18.h,
      height: 88,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          customImage,
          SizedBox(width: 8), // Add some space between image and text
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '• ', // Dot character
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0469B9),
                        ),
                      ),
                      TextSpan(
                        text: textLine,
                        style: TextStyle(
                          fontFamily: 'Comfortaa',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0469B9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomImage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 60,
      child: Image.asset(
        'assets/images/A-Tracking3D/A_Tracking_GiaoXe.png',
        width: 120, // Đảm bảo kích thước không vượt quá Container
        height: 80,
        fit: BoxFit.cover, // Hoặc BoxFit.fill tùy thuộc vào cách bạn muốn ảnh được hiển thị
      ),
    );
  }
}

class CustomImage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 60,
      child: Image.asset(
        'assets/images/A-Tracking3D/A_Tracking_VCDuongBo.png',
        fit: BoxFit.cover, // Hoặc BoxFit.fill tùy thuộc vào cách bạn muốn ảnh được hiển thị
      ),
    );
  }
}

class CustomImage3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // width: 120,
      // height: 80,
      width: 100,
      height: 60,
      child: Image.asset(
        'assets/images/A-Tracking3D/A_Tracking_LuuBai.png',
        fit: BoxFit.cover, // Hoặc BoxFit.fill tùy thuộc vào cách bạn muốn ảnh được hiển thị
      ),
    );
  }
}

class CustomImage4 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 60,
      child: Image.asset(
        'assets/images/A-Tracking3D/A_Tracking_KiemTraNhanXe.png',
        fit: BoxFit.cover, // Hoặc BoxFit.fill tùy thuộc vào cách bạn muốn ảnh được hiển thị
      ),
    );
  }
}

class CustomImage5 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 60,
      child: Image.asset(
        'assets/images/A-Tracking3D/A_Tracking_KhoTrungChuyen.png',
        fit: BoxFit.cover, // Hoặc BoxFit.fill tùy thuộc vào cách bạn muốn ảnh được hiển thị
      ),
    );
  }
}

class CustomImage6 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 60,
      child: Image.asset(
        'assets/images/A-Tracking3D/A_Tracking_VCDuongBien.png',
        fit: BoxFit.cover, // Hoặc BoxFit.fill tùy thuộc vào cách bạn muốn ảnh được hiển thị
      ),
    );
  }
}

class CustomImage7 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 60,
      child: Image.asset(
        'assets/images/A-Tracking3D/A_Tracking_VCDuongBo_1.png',
        fit: BoxFit.cover, // Hoặc BoxFit.fill tùy thuộc vào cách bạn muốn ảnh được hiển thị
      ),
    );
  }
}

class CustomImage8 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 60,
      child: Image.asset(
        'assets/images/A-Tracking3D/A_Tracking_LuuBai_1.png',
        fit: BoxFit.cover, // Hoặc BoxFit.fill tùy thuộc vào cách bạn muốn ảnh được hiển thị
      ),
    );
  }
}

class CustomImage9 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 80,
      child: Image.asset(
        'assets/images/A-Tracking3D/A_Tracking_KiemTraNhanXe_1.png',
        fit: BoxFit.cover, // Hoặc BoxFit.fill tùy thuộc vào cách bạn muốn ảnh được hiển thị
      ),
    );
  }
}

class CustomImage10 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 80,
      child: Image.asset(
        'assets/images/A-Tracking3D/A_Tracking_KhoTrungChuyen_1.png',
        fit: BoxFit.cover, // Hoặc BoxFit.fill tùy thuộc vào cách bạn muốn ảnh được hiển thị
      ),
    );
  }
}

Widget buildDivider() {
  return Container(
    width: 95.w,
    height: 2,
    padding: const EdgeInsets.only(right: 5),
    child: CustomPaint(
      painter: DashedLinePainter(
        color: const Color(0xFFD8D8D8), // Adjust the color as needed
        strokeWidth: 2, // Adjust the stroke width as needed
        dashLength: 5, // Adjust the length of each dash
        dashSpace: 3, // Adjust the space between dashes
      ),
    ),
  );
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double dashSpace;

  DashedLinePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square;

    final double totalWidth = size.width;
    final double dashTotal = dashLength + dashSpace;
    final double dashCount = (totalWidth / dashTotal).floor().toDouble();

    for (int i = 0; i < dashCount; i++) {
      final double dx = i * dashTotal;
      canvas.drawLine(Offset(dx, 0), Offset(dx + dashLength, 0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
