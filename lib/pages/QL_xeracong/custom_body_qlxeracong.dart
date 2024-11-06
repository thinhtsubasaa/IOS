import 'dart:convert';
import 'package:Thilogi/pages/checkxeracong/check_racong.dart';
import 'package:Thilogi/pages/login/Login.dart';
import 'package:Thilogi/pages/lsx_racong/lsx_racong.dart';
import 'package:Thilogi/pages/qrcode.dart';
import 'package:Thilogi/pages/tracuu/tracuu.dart';
import 'package:Thilogi/pages/xeracong/xeracong.dart';
import 'package:Thilogi/services/app_service.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/utils/next_screen.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import '../../blocs/menu_roles.dart';
import '../../config/config.dart';
import '../../models/menurole.dart';
import '../../widgets/loading.dart';

// ignore: use_key_in_widget_constructors
class CustomBodyQLXeRaCong extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 100.w, child: BodyQLXeRaCongScreen());
  }
}

class BodyQLXeRaCongScreen extends StatefulWidget {
  const BodyQLXeRaCongScreen({Key? key}) : super(key: key);

  @override
  _BodyQLXeRaCongScreenState createState() => _BodyQLXeRaCongScreenState();
}

// ignore: use_key_in_widget_constructors, must_be_immutable
class _BodyQLXeRaCongScreenState extends State<BodyQLXeRaCongScreen> with TickerProviderStateMixin, ChangeNotifier {
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
        } else if (snapshot.data == null || snapshot.data!.isEmpty) {
          // Chuyển hướng sang trang đăng nhập nếu không có dữ liệu
          Future.microtask(() => _goToLoginPage());
          return Container();
        } else {
          // Dữ liệu đã được tải, xây dựng giao diện
          return _buildContent(snapshot.data!);
        }
      },
    );
  }

  void _goToLoginPage() {
    nextScreenReplace(context, LoginPage());
  }

  @override
  Widget _buildContent(List<MenuRoleModel> menuRoles) {
    return _loading
        ? LoadingWidget(context)
        : SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              margin: const EdgeInsets.only(top: 25, bottom: 25),
              child: Wrap(
                spacing: 20.0, // khoảng cách giữa các nút
                runSpacing: 20.0, // khoảng cách giữa các hàng
                alignment: WrapAlignment.center,
                children: [
                  if (userHasPermission(menuRoles, 'kiem-tra-xe-len-long-mobi'))
                    CustomButton(
                      'KIỂM TRA XE LÊN LỒNG',
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/Button_09_KTXeRaCong_KTXeLenLong.png',
                          ),
                        ],
                      ),
                      () {
                        _handleButtonTap(CheckXeRaCongPage());
                      },
                    ),
                  if (userHasPermission(menuRoles, 'kiem-tra-xe-ra-cong-mobi'))
                    CustomButton(
                      'KIỂM TRA XE RA CỔNG',
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/Button_09_KTXeRaCong_BVQuet.png',
                          ),
                        ],
                      ),
                      () {
                        _handleButtonTap(XeRaCongPage());
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
                ],
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
      width: 32.w,
      // height: 35.h,
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            child: page,
          ),
          Text(
            buttonText.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppConfig.titleColor,
            ),
          ),
        ],
      ),
    ),
  );
}
