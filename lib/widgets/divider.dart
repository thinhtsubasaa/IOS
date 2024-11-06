import 'package:flutter/material.dart';

class DividerWidget extends StatelessWidget {
  const DividerWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 2.0,
      thickness: 0.2,
      indent: 50,
      color: Colors.grey[400],
    );
  }
}
