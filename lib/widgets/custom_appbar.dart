import 'package:Thilogi/config/config.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

PreferredSizeWidget customAppBar(BuildContext context) {
  return AppBar(
    // automaticallyImplyLeading: false,
    title: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            AppConfig.QLKhoImagePath,
            width: 70.w,
          ),
          // Container(
          //   child: Text(
          //     'TCT VẬN TẢI ĐƯỜNG BỘ THILOGI',
          //     textAlign: TextAlign.center,
          //     style: TextStyle(
          //       fontFamily: 'Roboto',
          //       fontSize: 13.sp,
          //       fontWeight: FontWeight.w700,
          //       color: AppConfig.primaryColor,
          //     ),
          //   ),
          // ),
        ],
      ),
    ),
  );
}
