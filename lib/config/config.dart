import 'dart:ui';
import 'package:flutter/material.dart';

class AppConfig {
  static const appName = "THILOGI";
  static const apiUrl = "https://apiwms.thilogi.vn";

  // Colors
  static const Color primaryColor = Color(0xFFA71C20);
  static const Color titleColor = Color.fromARGB(255, 216, 30, 16);
  static const Color buttonColorMenu = Color(0xFFCCCCCC);
  static const Color textButton = Color(0xFFFFFFFF);
  static const Color textInput = Color(0xFF000000);
  static const Color bottom = Color(0xFF808080);
  static const Color popup = Colors.green;

  // Constants
  static const double boxWidth = 320;
  static const double boxHeight = 180;
  static const double buttonWidth = 328;
  static const double buttonHeight = 55;
  static const double buttonMainMenuWidth = 150;
  static const double buttonMainMenuHeight = 100;

  static Color appThemeColor = const Color(0xFF00529C);

  // Image path
  static const String QLKhoImagePath = 'assets/images/AppBar_New.png';
  static const String appBarImagePath = 'assets/images/AppBar_New.png';
  static const String backgroundImagePath = 'assets/images/background.png';
  static const String homeImagePath = 'assets/images/BodyHome.png';
  static const String bottomHomeImagePath = 'assets/images/BottomHome.png';
  static const String logoSplash = 'assets/images/thilogi_logo_white.png';
  static const String defaultImage = 'https://portalgroupapi.thacochulai.vn/Uploads/noimage.jpg';
  static const List<String> languages = [
    'English',
    'Tiếng Việt',
    'Chinese',
  ];
}
