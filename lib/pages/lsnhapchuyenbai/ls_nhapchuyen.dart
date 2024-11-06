import 'package:Thilogi/pages/lsnhapchuyenbai/custom_body_lsnhapbai.dart';
import 'package:Thilogi/pages/lsnhapchuyenbai/custom_body_lsnhapchuyen.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/config/config.dart';
import 'package:sizer/sizer.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_title.dart';

class LSNhapChuyenPage extends StatefulWidget {
  const LSNhapChuyenPage({super.key});

  @override
  State<LSNhapChuyenPage> createState() => _LSNhapChuyenPage();
}

class _LSNhapChuyenPage extends State<LSNhapChuyenPage> with SingleTickerProviderStateMixin, ChangeNotifier {
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
                  width: 100.w,
                  decoration: const BoxDecoration(
                      // color: Theme.of(context).colorScheme.onPrimary,
                      ),
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: _tabController,
                    children: [CustomBodyLSNhapBai(), CustomBodyLSNhapChuyen()],
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
                  const CustomCard(),
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Đã nhập bãi'),
                      Tab(text: 'Đã chuyển bãi'),
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
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: AppConfig.bottom,
      ),
      child: Center(
        child: customTitle(
          'LỊCH SỬ XE NHẬP CHUYỂN BÃI',
        ),
      ),
    );
  }
}
