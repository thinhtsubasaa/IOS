import 'package:flutter/material.dart';
import 'package:Thilogi/pages/menu/custom_body_mainmenu.dart';
import 'package:Thilogi/config/config.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/custom_bottom.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_title.dart';

class MainMenuPage extends StatelessWidget {
  int currentPage = 0; // Đặt giá trị hiện tại của trang
  int pageCount = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(),
      body: Column(
        children: [
          CustomCard(),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                width: 100.w,
                child: CustomBodyMainMenu(),
              ),
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
      height: MediaQuery.of(context).size.height / 8,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(left: 20),
      child: customTitle(
        'HỆ THỐNG QUẢN LÝ NGUỒN LỰC DOANH NGHIỆP (ERP)',
      ),
    );
  }
}

PreferredSizeWidget customAppBar() {
  return AppBar(
    // automaticallyImplyLeading: false,

    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          AppConfig.appBarImagePath,
          width: 70.w,
        ),
      ],
    ),
  );
}
