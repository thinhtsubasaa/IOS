import 'package:flutter/material.dart';

void nextScreen(context, page) {
  Navigator.push(context, MaterialPageRoute(builder: (builder) => page));
}

void nextScreenRoute(BuildContext context, String routeName) {
  Navigator.pushNamed(context, routeName);
}

void backScreen(context, page) {
  Navigator.pop(context, MaterialPageRoute(builder: (builder) => page));
}

void nextScreenCloseOthers(context, page) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (builder) => page),
    (route) => false,
  );
}

void nextScreenReplace(context, page) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (builder) => page),
  );
}

void nextScreenPopup(context, page) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (builder) => page, fullscreenDialog: true),
  );
}
