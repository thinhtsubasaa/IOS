import 'package:flutter/material.dart';
import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/pages/login/Login.dart';
import 'package:sizer/sizer.dart';
import '../utils/next_screen.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(),
      body: Column(
        children: [
          const Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  CustomImage(imagePath: AppConfig.homeImagePath),
                ],
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
      height: MediaQuery.of(context).size.height > 885 ? 30.h : null,
      child: Column(
        children: [
          Center(
            child: customTitleHome('LOGISTIC TRỌN GÓI\nHÀNG ĐẦU MIỀN TRUNG'),
          ),
          const SizedBox(height: 10),
          const CustomImage(imagePath: AppConfig.bottomHomeImagePath),
          const SizedBox(height: 15),
          CustomButton(onPressed: () {
            nextScreen(context, LoginPage());
          }),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

Widget customTitleHome(String text) {
  return Text(
    text,
    textAlign: TextAlign.center,
    style: const TextStyle(
      color: AppConfig.titleColor,
      fontFamily: 'Roboto',
      fontSize: 16,
      fontWeight: FontWeight.w700,
    ),
  );
}

class CustomImage extends StatelessWidget {
  final String imagePath;
  const CustomImage({required this.imagePath});
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
    );
  }
}

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  const CustomButton({required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        nextScreen(context, LoginPage());
      },
      style: ElevatedButton.styleFrom(
        fixedSize: Size(MediaQuery.of(context).size.width * 1.0, AppConfig.buttonHeight),
        backgroundColor: AppConfig.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: EdgeInsets.all(10),
      ),
      child: const Text(
        'WELCOME',
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

PreferredSizeWidget customAppBar() {
  return AppBar(
    // automaticallyImplyLeading: false,
    title: Center(
      child: Image.asset(
        AppConfig.appBarImagePath,
        width: 85.w,
      ),
    ),
  );
}
