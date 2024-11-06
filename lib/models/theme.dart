import 'package:Thilogi/config/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThemeModel {
  final lightTheme = ThemeData(
      visualDensity: VisualDensity.adaptivePlatformDensity,
      primarySwatch: Colors.pink,
      primaryColor: AppConfig.appThemeColor,
     
      scaffoldBackgroundColor: Colors.grey[100],
      shadowColor: Colors.grey[200],
      brightness: Brightness.light,
      fontFamily: 'MyriadPro',
      
      colorScheme: ColorScheme.light(
        primary: Colors.black, //text
        secondary: Colors.grey[300]!, //text
        onPrimary: Colors.white, //card -1
        onSecondary: Colors.grey[100]!, //card -2
        surface: Colors.grey[300]!, //shadow color -1
        onBackground: Colors.grey[300]!, //loading card color
      ),
      dividerColor: Colors.grey[300],
      iconTheme: IconThemeData(color: Colors.grey[900]),
      primaryIconTheme: IconThemeData(
        color: Colors.grey[900],
      ),
      appBarTheme: AppBarTheme(
        color: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'MyriadPro',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.7,
          color: Colors.grey[900],
        ),
        iconTheme: IconThemeData(
          color: Colors.grey[900],
        ),
        actionsIconTheme: IconThemeData(
          color: Colors.grey[900],
        ),
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppConfig.appThemeColor,
        unselectedItemColor: Colors.blueGrey[200],
      ),
      popupMenuTheme: PopupMenuThemeData(
        textStyle: TextStyle(
          fontFamily: 'MyriadPro',
          color: Colors.grey[900],
          fontWeight: FontWeight.w500,
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: MaterialStateColor.resolveWith((states) => Colors.blue),
        trackColor: MaterialStateColor.resolveWith((states) => Colors.grey),
        trackBorderColor:
            MaterialStateColor.resolveWith((states) => Colors.grey),
        crossAxisMargin: 8.0,
        mainAxisMargin: 8.0,
        radius: const Radius.circular(10),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.white;
          }
          return Colors.white;
        }),
      ));

  final darkTheme = ThemeData(
    visualDensity: VisualDensity.adaptivePlatformDensity,
    primarySwatch: Colors.pink,
    primaryColor: AppConfig.appThemeColor,
    
    scaffoldBackgroundColor: const Color(0xff303030),
    shadowColor: Colors.grey[850],
    brightness: Brightness.dark,
    fontFamily: 'MyriadPro',
    
    colorScheme: ColorScheme.dark(
      primary: Colors.white, //text
      secondary: Colors.grey[200]!, //text
      onPrimary: Colors.grey[800]!, //card color -1
      onSecondary: Colors.grey[800]!, //card color -2
      surface: const Color(0xff303030), //shadow color - 1
      onBackground: Colors.grey[800]!, //loading card color
    ),
    dividerColor: Colors.grey[300],
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
    primaryIconTheme: const IconThemeData(
      color: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      color: Colors.grey[800],
      elevation: 0,
      titleTextStyle: const TextStyle(
        fontFamily: 'MyriadPro',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.7,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      actionsIconTheme: const IconThemeData(
        color: Colors.white,
      ),
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.grey[800],
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey[500],
    ),
    popupMenuTheme: const PopupMenuThemeData(
      textStyle: TextStyle(
        fontFamily: 'MyriadPro',
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}
