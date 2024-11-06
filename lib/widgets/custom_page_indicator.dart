import 'package:flutter/material.dart';
import 'package:dots_indicator/dots_indicator.dart';

class PageIndicator extends StatelessWidget {
  final int currentPage;
  final int pageCount;

  PageIndicator({required this.currentPage, required this.pageCount});

  @override
  Widget build(BuildContext context) {
    return DotsIndicator(
      dotsCount: pageCount,
      position: currentPage.toDouble(),
      decorator: DotsDecorator(
        size: const Size.square(9.0),
        activeSize: const Size(18.0, 9.0),
        color: Colors.grey, // Màu chấm khi không được chọn
        activeColor: Colors.blue, // Màu chấm khi được chọn
        spacing: const EdgeInsets.all(6.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
    );
  }
}


  //       DropdownButtonFormField<String>(
                                                //     isExpanded: true,
                                                //     items: _khoxeList?.map((item) {
                                                //       return DropdownMenuItem<String>(
                                                //         value: item.id,
                                                //         child: Container(
                                                //           padding: EdgeInsets.only(
                                                //               left: 15.sp),
                                                //           child: Text(
                                                //             item.tenKhoXe ?? "",
                                                //             style: const TextStyle(
                                                //               fontFamily: 'Comfortaa',
                                                //               fontSize: 14,
                                                //               fontWeight:
                                                //                   FontWeight.w600,
                                                //               color:
                                                //                   AppConfig.textInput,
                                                //             ),
                                                //           ),
                                                //         ),
                                                //       );
                                                //     }).toList(),
                                                //     value: KhoXeId,
                                                //     onChanged: (newValue) async {
                                                //       setState(() {
                                                //         KhoXeId = newValue;
                                                //       });
                                                //       if (newValue != null) {
                                                //         getBaiXeList(newValue);
                                                //         print("object : ${KhoXeId}");
                                                //       }
                                                //       ;
                                                //     },
                                                //   ),
                                                // ),