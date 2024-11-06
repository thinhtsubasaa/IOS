import 'package:flutter/material.dart';
import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/pages/qlkho/QLKhoXe.dart';
import 'package:Thilogi/utils/next_screen.dart';
import 'package:Thilogi/widgets/custom_page_indicator.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/loading.dart';

// ignore: use_key_in_widget_constructors

class CustomBodyMainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      color: Color.fromRGBO(246, 198, 199, 0.2),
      child: BodyMainMenu(),
    );
  }
}

class BodyMainMenu extends StatefulWidget {
  @override
  _BodyMainMenuState createState() => _BodyMainMenuState();
}

// ignore: use_key_in_widget_constructors, must_be_immutable
class _BodyMainMenuState extends State<BodyMainMenu> with SingleTickerProviderStateMixin {
  int currentPage = 0; // Đặt giá trị hiện tại của trang
  int pageCount = 3;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return _loading
        ? LoadingWidget(context)
        : Container(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            margin: const EdgeInsets.only(bottom: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        IconButton(
                          onPressed: () {
                            _handleButtonTap(QLKhoXePage());
                          },
                          icon: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                'assets/images/car3.png',
                                width: 120,
                                height: 80,
                              ),
                              Transform.translate(
                                offset: const Offset(0, 3),
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 60),
                                  child: Image.asset(
                                    'assets/images/car4.png',
                                    width: 40,
                                    height: 40,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          iconSize: AppConfig.buttonMainMenuWidth, // Kích thước của biểu tượng
                          padding: EdgeInsets.zero, // Xóa padding mặc định của IconButton
                          alignment: Alignment.center, // Căn chỉnh hình ảnh vào giữa nút
                        ),
                        const SizedBox(
                          child: Text(
                            "QUẢN LÝ KHO XE\n THÀNH PHẨM",
                            style: TextStyle(
                              fontFamily: 'Comfortaa',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const CustomButton(width: AppConfig.buttonMainMenuWidth, height: AppConfig.buttonMainMenuHeight, color: AppConfig.buttonColorMenu),
                  ],
                ),
                const SizedBox(height: 30),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomButton(width: AppConfig.buttonMainMenuWidth, height: AppConfig.buttonMainMenuHeight, color: AppConfig.buttonColorMenu),
                    CustomButton(width: AppConfig.buttonMainMenuWidth, height: AppConfig.buttonMainMenuHeight, color: AppConfig.buttonColorMenu),
                  ],
                ),
                const SizedBox(height: 30),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomButton(width: AppConfig.buttonMainMenuWidth, height: AppConfig.buttonMainMenuHeight, color: AppConfig.buttonColorMenu),
                    CustomButton(width: AppConfig.buttonMainMenuWidth, height: AppConfig.buttonMainMenuHeight, color: AppConfig.buttonColorMenu),
                  ],
                ),
                const SizedBox(height: 30),
                PageIndicator(currentPage: currentPage, pageCount: pageCount),
              ],
            ),
          );
  }

  void _handleButtonTap(Widget page) {
    setState(() {
      _loading = true;
    });
    nextScreen(context, page);
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _loading = false;
      });
    });
  }
}

class CustomButton extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  // ignore: use_key_in_widget_constructors
  const CustomButton({
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: color,
    );
  }
}
