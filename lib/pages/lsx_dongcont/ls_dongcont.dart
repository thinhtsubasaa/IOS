import 'package:Thilogi/pages/lsx_dongcont/custom_body_chuadongcont.dart';
import 'package:Thilogi/pages/lsx_dongcont/custom_body_lsdongcont.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/config/config.dart';
import 'package:sizer/sizer.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_title.dart';

class LSDongContPage extends StatefulWidget {
  const LSDongContPage({super.key});

  @override
  State<LSDongContPage> createState() => _LSDongContPage();
}

class _LSDongContPage extends State<LSDongContPage> with SingleTickerProviderStateMixin, ChangeNotifier {
  TabController? _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    _tabController!.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController!.indexIsChanging) {
      // Call the action when the tab changes
      // print('Tab changed to: ${_tabController!.index}');
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: customAppBar(context),
      body: Stack(
        children: [
          Column(
            children: [
              CustomCard(),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: MediaQuery.of(context).size.height < 600 ? 10.h : 5.h),
                  // padding: EdgeInsets.only(left: 10, right: 10),
                  width: 100.w,
                  decoration: BoxDecoration(
                      // color: Theme.of(context).colorScheme.onPrimary,
                      ),
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: _tabController,
                    children: [CustomBodyLSDongCont(), CustomBodyChuaDongCont()],
                  ),
                ),
              ),
              BottomContent(),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                // mainAxisSize: MainAxisSize.min,
                children: [
                  CustomCard(),
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Đã đóng cont'),
                      Tab(text: 'Chưa đóng cont'),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
          'LỊCH SỬ XE ĐÓNG CONT',
        ),
      ),
    );
  }
}
