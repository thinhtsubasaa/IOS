import 'package:Thilogi/pages/checkxeracong/custom_body_checkracong.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/config/config.dart';
import 'package:sizer/sizer.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_title.dart';

class CheckXeRaCongPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // appBar: customAppBar(context),
      body: Column(
        children: [
          // CustomCard(),
          SizedBox(
            height: 25,
          ),
          // Container(
          //   padding: EdgeInsets.only(left: 8, top: 10),
          //   alignment: Alignment.topLeft,
          //   child: BackButton(
          //     color: Colors.black,
          //     onPressed: () {
          //       Navigator.pop(context);
          //     },
          //   ),
          // ),
          Expanded(
            child: Container(
              width: 100.w,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              child: CustomBodyCheckRaCong(),
            ),
          ),
          // BottomContent(),
        ],
      ),
    );
  }
}

class BottomContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 11,
      padding: EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: AppConfig.bottom,
      ),
      child: Center(
        child: customTitle(
          'XE RA CỔNG',
        ),
      ),
    );
  }
}
