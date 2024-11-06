import 'package:flutter/material.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';

Future<void> deleteDialog(
    BuildContext context, String msg, String title, Function onPressed) {
  return Dialogs.materialDialog(
    dialogWidth: 0.3,
    msg: msg,
    title: title,
    color: Colors.white,
    context: context,
    actions: [
      IconsOutlineButton(
        onPressed: () => Navigator.pop(context),
        text: 'Huỷ',
        iconData: Icons.cancel_outlined,
        textStyle: const TextStyle(color: Colors.grey),
        iconColor: Colors.grey,
      ),
      IconsButton(
        onPressed: onPressed,
        text: 'Xoá',
        iconData: Icons.delete,
        color: Colors.red,
        textStyle: const TextStyle(color: Colors.white),
        iconColor: Colors.white,
      ),
    ],
  );
}

Future<void> confirmDialog(
    BuildContext context, String msg, String title, Function onPressed) {
  return Dialogs.materialDialog(
    dialogWidth: 0.3,
    msg: msg,
    title: title,
    color: Colors.white,
    context: context,
    actions: [
      IconsOutlineButton(
        onPressed: () => Navigator.pop(context),
        text: 'Huỷ',
        iconData: Icons.cancel_outlined,
        textStyle: const TextStyle(color: Colors.grey),
        iconColor: Colors.grey,
      ),
      IconsButton(
        onPressed: onPressed,
        text: 'Đồng ý',
        iconData: Icons.check_outlined,
        color: Theme.of(context).primaryColor,
        textStyle: const TextStyle(color: Colors.white),
        iconColor: Colors.white,
      ),
    ],
  );
}
