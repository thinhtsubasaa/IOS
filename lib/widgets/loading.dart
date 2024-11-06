import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

Widget LoadingWidget(BuildContext context) {
  final height = MediaQuery.of(context).size.height * 0.5;
  return Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.onPrimary,
    ),
    padding: const EdgeInsets.all(20),
    height: height,
    child: Center(
      child: LoadingAnimationWidget.twistingDots(
        leftDotColor: const Color.fromARGB(197, 1, 100, 198),
        rightDotColor: Color.fromARGB(255, 229, 25, 25),
        size: 40,
      ),
    ),
  );
}
