import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../config/config.dart';

// ignore: use_key_in_widget_constructors
class CustomBodyGuess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 100.w, child: MainButton());
  }
}

class MainButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        margin: const EdgeInsets.only(top: 25, bottom: 25),
        child: Wrap(
          spacing: 20.0, // khoảng cách giữa các nút
          runSpacing: 20.0, // khoảng cách giữa các hàng
          alignment: WrapAlignment.center,
          children: [
            // CustomButton(
            //   'THÔNG TIN DỊCH VỤ',
            //   Stack(
            //     alignment: Alignment.center,
            //     children: [
            //       Image.asset(
            //         'assets/images/Button_NhanXe_3b.png',
            //       ),
            //     ],
            //   ),
            //   () {
            //     nextScreen(context, TraCuuPage());
            //   },
            // ),
            // CustomButton(
            //   'TRA CỨU ĐƠN HÀNG',
            //   Stack(
            //     alignment: Alignment.center,
            //     children: [
            //       Image.asset(
            //         'assets/images/Button_NhanXe_3b.png',
            //       ),
            //     ],
            //   ),
            //   () {
            //     nextScreen(context, TraCuuPage());
            //   },
            // ),
            // CustomButton(
            //   'TRA CỨU THÔNG TIN NHÂN VIÊN',
            //   Stack(
            //     alignment: Alignment.center,
            //     children: [
            //       Image.asset(
            //         'assets/images/Button_NhanXe_3b.png',
            //       ),
            //     ],
            //   ),
            //   () {
            //     nextScreen(context, TraCuuPage());
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}

Widget CustomButton(String buttonText, Widget page, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40.w,
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            child: page,
          ),
          const SizedBox(height: 8),
          Text(
            buttonText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppConfig.titleColor,
            ),
          ),
        ],
      ),
    ),
  );
}
