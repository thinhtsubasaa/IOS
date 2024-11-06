import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:easy_localization/easy_localization.dart';

import '../config/config.dart';

class LanguagePopup extends StatefulWidget {
  const LanguagePopup({super.key});

  @override
  State<LanguagePopup> createState() => _LanguagePopupState();
}

class _LanguagePopupState extends State<LanguagePopup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn ngôn ngữ').tr(),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: AppConfig.languages.length,
        itemBuilder: (BuildContext context, int index) {
          return _itemList(AppConfig.languages[index]);
        },
      ),
    );
  }

  Widget _itemList(d) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(
            Feather.globe,
            size: 22,
          ),
          horizontalTitleGap: 10,
          title: Text(
            d,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          onTap: () async {
            if (d == 'Tiếng Việt') {
              await context.setLocale(const Locale('vi', 'VN'));
            } else if (d == 'English') {
              await context.setLocale(const Locale('en', 'US'));
            } else if (d == 'Chinese') {
              await context.setLocale(const Locale('zh', 'CN'));
            }
            Navigator.pop(context);
          },
        ),
        Divider(
          height: 0,
          indent: 50,
          color: Colors.grey[400],
        )
      ],
    );
  }
}
