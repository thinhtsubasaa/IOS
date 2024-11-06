import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/pages/login/custom_form_login.dart';
import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/pages/guess/Guess.dart';
import 'package:Thilogi/utils/next_screen.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/custom_bottom.dart';
import '../../widgets/custom_page_indicator.dart';

class LoginPage extends StatelessWidget {
  int currentPage = 0; // Đặt giá trị hiện tại của trang
  int pageCount = 3;

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: customAppBar(context),
  //     body: LayoutBuilder(
  //       builder: (context, constraints) {
  //         return SingleChildScrollView(
  //           child: ConstrainedBox(
  //             constraints: BoxConstraints(
  //               minHeight: constraints.maxHeight,
  //             ),
  //             child: Container(
  //               color: Color.fromRGBO(246, 198, 199, 0.2),
  //               width: 100.w,
  //               height: 100.h,
  //               child: Column(
  //                 children: [
  //                   Container(
  //                     width: 100.w,
  //                     height: 100.h,
  //                     child: Column(
  //                       children: [
  //                         CustomLoginForm(),
  //                         const SizedBox(height: 20),
  //                         // customTitleLogin('DÀNH CHO KHÁCH HÀNG'),
  //                         // const SizedBox(height: 20),
  //                         // Container(
  //                         //   width: 100.w,
  //                         //   height: MediaQuery.of(context).size.height / 2,
  //                         //   color: const Color(0x21428FCA),
  //                         //   padding: const EdgeInsets.symmetric(horizontal: 50),
  //                         //   child: Column(
  //                         //     children: [
  //                         //       const SizedBox(height: 15),
  //                         //       customBottom(
  //                         //         "Tìm hiểu về THILOGI và các Dịch vụ Theo dõi Thông tin Đơn hàng",
  //                         //       ),
  //                         //       const SizedBox(height: 30),
  //                         //       PageIndicator(
  //                         //         currentPage: currentPage,
  //                         //         pageCount: pageCount,
  //                         //       ),
  //                         //       const SizedBox(height: 20),
  //                         //       CustomButtonLogin(onPressed: () {
  //                         //         nextScreen(context, GuessPage());
  //                         //       }),
  //                         //     ],
  //                         //   ),
  //                         // ),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: customAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: 100.w,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              child: CustomLoginForm(),
            ),
          ),
          BottomContent(),
        ],
      ),
    );
  }
}

class CustomButtonLogin extends StatelessWidget {
  final VoidCallback onPressed;

  const CustomButtonLogin({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(AppConfig.buttonWidth, AppConfig.buttonHeight),
        backgroundColor: const Color(0xFF428FCA),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(10),
      ),
      child: const Text(
        'TIẾP TỤC',
        style: TextStyle(
          color: AppConfig.textButton,
          fontFamily: 'Roboto',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

PreferredSizeWidget customAppBar(BuildContext context) {
  return AppBar(
    // automaticallyImplyLeading: false,
    title: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            AppConfig.appBarImagePath,
            width: 70.w,
          ),
        ],
      ),
    ),
  );
}

Widget customTitleLogin(String text) {
  return Text(
    text,
    textAlign: TextAlign.center,
    style: const TextStyle(
      color: Color(0xFF428FCA),
      fontFamily: 'Roboto',
      fontSize: 16,
      fontWeight: FontWeight.w700,
    ),
  );
}
