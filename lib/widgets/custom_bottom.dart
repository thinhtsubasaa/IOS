import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

Widget customBottom(String text) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 5.w),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color(0xFF000000),
        fontFamily: 'Roboto',
        fontSize: 15.sp,
        fontWeight: FontWeight.w400,
      ),
    ),
  );
}
