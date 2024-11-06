import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../config/config.dart';

Widget customTitle(String text) {
  return SelectableText(
    text.tr(),
    textAlign: TextAlign.center,
    style: const TextStyle(
      color: AppConfig.textButton,
      fontFamily: 'Roboto',
      fontSize: 16,
      fontWeight: FontWeight.w700,
    ),
  );
}

class CustomTitleBottom extends StatelessWidget {
  final String title;
  final String iconPath;

  CustomTitleBottom({required this.iconPath, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          iconPath,
        ),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Comfortaa',
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
