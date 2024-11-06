import 'package:Thilogi/pages/dsx_danhan/dsx_danhan.dart';
import 'package:Thilogi/pages/lsx_dongcont/ls_dongcont.dart';
import 'package:Thilogi/pages/lsnhanxe/ls_danhan.dart';
import 'package:Thilogi/pages/lsnhapchuyenbai/ls_nhapchuyen.dart';
import 'package:Thilogi/pages/lsx_giaoxe/lsx_giaoxe.dart';
import 'package:Thilogi/pages/lsx_racong/lsx_racong.dart';
import 'package:Thilogi/pages/lsx_rutcont/lsx_rutcont.dart';
import 'package:Thilogi/pages/lsx_vanchuyen/lsx_vanchuyen.dart';
import 'package:Thilogi/pages/nhanxe/NhanXe.dart';
import 'package:Thilogi/services/app_service.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/widgets/custom_page_indicator.dart';
import 'package:Thilogi/utils/next_screen.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import '../../../blocs/menu_roles.dart';
import '../../../config/config.dart';
import '../../../models/menurole.dart';
import '../../../widgets/loading.dart';

// ignore: use_key_in_widget_constructors
class CustomBodyLSCongViec extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 100.w, child: BodyLSCongViecScreen());
  }
}

class BodyLSCongViecScreen extends StatefulWidget {
  const BodyLSCongViecScreen({Key? key}) : super(key: key);

  @override
  _BodyLSCongViecScreenState createState() => _BodyLSCongViecScreenState();
}

// ignore: use_key_in_widget_constructors, must_be_immutable
class _BodyLSCongViecScreenState extends State<BodyLSCongViecScreen> with TickerProviderStateMixin, ChangeNotifier {
  int currentPage = 0;
  int pageCount = 3;
  bool _loading = false;
  String DonVi_Id = '99108b55-1baa-46d0-ae06-f2a6fb3a41c8';
  String PhanMem_Id = 'cd9961bf-f656-4382-8354-803c16090314';
  late MenuRoleBloc _mb;
  List<MenuRoleModel>? _menurole;
  List<MenuRoleModel>? get menurole => _menurole;
  static RequestHelper requestHelper = RequestHelper();
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  String? _message;
  String? get message => _message;

  String? url;
  late Future<List<MenuRoleModel>> _menuRoleFuture;

  @override
  void initState() {
    super.initState();
    _checkInternetAndShowAlert();
    _mb = Provider.of<MenuRoleBloc>(context, listen: false);
    _menuRoleFuture = _fetchMenuRoles();
  }

  Future<List<MenuRoleModel>> _fetchMenuRoles() async {
    // Thực hiện lấy dữ liệu từ MenuRoleBloc
    await _mb.getData(context, DonVi_Id, PhanMem_Id);
    return _mb.menurole ?? [];
  }

  void _checkInternetAndShowAlert() {
    AppService().checkInternet().then((hasInternet) async {
      if (!hasInternet!) {
        // Reset the button state if necessary

        QuickAlert.show(
          context: context,
          type: QuickAlertType.info,
          title: '',
          text: 'Không có kết nối internet. Vui lòng kiểm tra lại',
          confirmBtnText: 'Đồng ý',
        );
      }
    });
  }

  bool userHasPermission(List<MenuRoleModel> menuRoles, String? url1) {
    // Kiểm tra xem menuRoles có chứa quyền truy cập đến url1 không
    return menuRoles.any((menuRole) => menuRole.url == url1);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MenuRoleModel>>(
      future: _menuRoleFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingWidget(context);
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          // Dữ liệu đã được tải, xây dựng giao diện
          return _buildContent(snapshot.data!);
        }
      },
    );
  }

  @override
  Widget _buildContent(List<MenuRoleModel> menuRoles) {
    return _loading
        ? LoadingWidget(context)
        : SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              margin: const EdgeInsets.only(top: 30, bottom: 30),
              child: Wrap(
                spacing: 25.0, // khoảng cách giữa các nút
                runSpacing: 20.0, // khoảng cách giữa các hàng
                alignment: WrapAlignment.center,
                children: [
                  if (userHasPermission(menuRoles, 'lich-su-cong-viec-giao-xe-mobi'))
                    CustomButton(
                      'LỊCH SỬ CÔNG VIỆC GIAO XE',
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/Button_09_LichSuCongViec_GiaoXe.png',
                          ),
                        ],
                      ),
                      () {
                        _handleButtonTap(NhanXePage());
                      },
                    ),
                  if (userHasPermission(menuRoles, 'lich-su-xe-da-nhan-mobi'))
                    CustomButton(
                      'LỊCH SỬ XE ĐÃ NHẬN',
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/Button_01_NhanXe_LichSuNhanXe.png',
                          ),
                        ],
                      ),
                      () {
                        _handleButtonTap(DSXDaNhanPage());
                      },
                    ),
                  if (userHasPermission(menuRoles, 'lich-su-nhap-chuyen-bai-mobi'))
                    CustomButton(
                      'LỊCH SỬ NHẬP CHUYỂN BÃI',
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/Button_09_LichSuCongViec_NhapChuyenBai.png',
                          ),
                        ],
                      ),
                      () {
                        _handleButtonTap(LSNhapChuyenPage());
                      },
                    ),
                  if (userHasPermission(menuRoles, 'lich-su-nhan-xe-mobi'))
                    CustomButton(
                      'LỊCH SỬ NHẬN XE',
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/Button_09_LichSuCongViec_TheoCaNhan.png',
                          ),
                        ],
                      ),
                      () {
                        _handleButtonTap(LSDaNhanPage());
                      },
                    ),
                  if (userHasPermission(menuRoles, 'lich-su-dong-cont-mobi'))
                    CustomButton(
                      'LỊCH SỬ ĐÓNG CONT',
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/Button_09_LichSuCongViec_DongCont.png',
                          ),
                        ],
                      ),
                      () {
                        _handleButtonTap(LSDongContPage());
                      },
                    ),
                  // if (userHasPermission(menuRoles, 'lich-su-nhap-bai-mobi'))
                  //   CustomButton(
                  //     'LỊCH SỬ NHẬP BÃI',
                  //     Stack(
                  //       alignment: Alignment.center,
                  //       children: [
                  //         Image.asset(
                  //           'assets/images/Button_09_LichSuCongViec_TheoCaNhan.png',
                  //         ),
                  //       ],
                  //     ),
                  //     () {
                  //       _handleButtonTap(DSXDaNhanPage());
                  //     },
                  //   ),
                  // if (userHasPermission(menuRoles, 'lich-su-xuat-bai-mobi'))
                  //   CustomButton(
                  //     'LỊCH SỬ XUẤT BÃI',
                  //     Stack(
                  //       alignment: Alignment.center,
                  //       children: [
                  //         Image.asset(
                  //           'assets/images/Button_09_LichSuCongViec_TheoCaNhan.png',
                  //         ),
                  //       ],
                  //     ),
                  //     () {
                  //       _handleButtonTap(DSXDaNhanPage());
                  //     },
                  //   ),
                  if (userHasPermission(menuRoles, 'lich-su-van-chuyen-mobi'))
                    CustomButton(
                      'LỊCH SỬ VẬN CHUYỂN',
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/Button_09_LichSuCongViec_VanChuyen.png',
                          ),
                        ],
                      ),
                      () {
                        _handleButtonTap(LSVanChuyenPage());
                      },
                    ),
                  if (userHasPermission(menuRoles, 'lich-su-giao-xe-mobi'))
                    CustomButton(
                      'LỊCH SỬ GIAO XE',
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/Button_09_LichSuCongViec_GiaoXe.png',
                          ),
                        ],
                      ),
                      () {
                        _handleButtonTap(LSGiaoXePage());
                      },
                    ),
                  if (userHasPermission(menuRoles, 'lich-su-xe-ra-cong-mobi'))
                    CustomButton(
                      'LỊCH SỬ XE RA CỔNG',
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/Button_09_KTXeRaCong_LichSuRaCong.png',
                          ),
                        ],
                      ),
                      () {
                        _handleButtonTap(LSXeRaCongPage());
                      },
                    ),
                  if (userHasPermission(menuRoles, 'lich-su-xe-rut-cont-mobi'))
                    CustomButton(
                      'LỊCH SỬ XE RÚT CONT',
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/Button_09_LichSuCongViec_GiaoXe.png',
                          ),
                        ],
                      ),
                      () {
                        _handleButtonTap(LSXeRutContPage());
                      },
                    ),
                ],
                // PageIndicator(currentPage: currentPage, pageCount: pageCount),
              ),
            ),
          );
  }

  void _handleButtonTap(Widget page) {
    setState(() {
      _loading = true;
    });
    nextScreen(context, page);
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _loading = false;
      });
    });
  }
}

Widget CustomButton(String buttonText, Widget page, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 33.w,
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            child: page,
          ),
          const SizedBox(height: 8),
          Text(
            buttonText.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppConfig.titleColor,
            ),
          ),
        ],
      ),
    ),
  );
}
