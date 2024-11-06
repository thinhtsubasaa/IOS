import 'package:Thilogi/widgets/custom_title.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/pages/guess/custom_body_guess.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:sizer/sizer.dart';
import '../../config/config.dart';
import '../../widgets/custom_page_indicator.dart';

import 'package:sizer/sizer.dart';

import '../../widgets/custom_appbar.dart';

class GuessPage extends StatelessWidget {
  int currentPage = 0; // Đặt giá trị hiện tại của trang
  int pageCount = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: 100.w,
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppConfig.backgroundImagePath),
                  fit: BoxFit.cover,
                ),
              ),
              child: CustomBodyGuess(),
            ),
          ),
          BottomContent(),
        ],
      ),
    );
  }
}

class BottomContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 12,
      padding: EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: AppConfig.bottom,
      ),
      child: Center(
        child: customTitle(
          'KIỂM TRA - TRA CỨU THÔNG TIN',
        ),
      ),
    );
  }
}
