import 'package:Thilogi/pages/qldongcont/custom_body_qldongcont.dart';
import 'package:Thilogi/pages/vanchuyen/giaoxe/custom_body_vanchuyen.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/config/config.dart';
import 'package:sizer/sizer.dart';

import '../../../widgets/custom_appbar.dart';
import '../../../widgets/custom_card.dart';
import '../../../widgets/custom_title.dart';

class QLDongContPage extends StatelessWidget {
  int currentPage = 0; // Đặt giá trị hiện tại của trang
  int pageCount = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context),
      body: Column(
        children: [
          CustomCard(),
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
              child: CustomBodyQLDongCont(),
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
      height: MediaQuery.of(context).size.height / 11,
      padding: EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: AppConfig.bottom,
      ),
      child: customTitle(
        'QUẢN LÝ ĐÓNG CONT',
      ),
    );
  }
}
