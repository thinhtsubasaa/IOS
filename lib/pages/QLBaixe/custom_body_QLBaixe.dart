import 'package:Thilogi/pages/dsxchoxuat/dsx_choxuat.dart';

import 'package:Thilogi/pages/webview.dart';
import 'package:Thilogi/services/app_service.dart';
import 'package:Thilogi/widgets/loading.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/pages/baixe/baixe.dart';
import 'package:Thilogi/pages/chuyenxe/chuyenxe.dart';

import 'package:Thilogi/utils/next_screen.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:sizer/sizer.dart';

import '../../blocs/menu_roles.dart';
import '../../config/config.dart';
import '../../models/menurole.dart';
import '../../services/request_helper.dart';
import '../qrcoderutxe/qrcoderutxe.dart';
import '../timxe/timxe.dart';

// ignore: use_key_in_widget_constructors
class CustomBodyQLBaiXe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 100.w, child: BodyQLBaiXeScreen());
  }
}

class BodyQLBaiXeScreen extends StatefulWidget {
  const BodyQLBaiXeScreen({Key? key}) : super(key: key);

  @override
  _BodyQLBaiXeScreenState createState() => _BodyQLBaiXeScreenState();
}

// ignore: use_key_in_widget_constructors, must_be_immutable
class _BodyQLBaiXeScreenState extends State<BodyQLBaiXeScreen> with TickerProviderStateMixin, ChangeNotifier {
  int currentPage = 0; // Đặt giá trị hiện tại của trang
  int pageCount = 3;
  bool _loading = false;
  String DonVi_Id = '99108b55-1baa-46d0-ae06-f2a6fb3a41c8';
  String PhanMem_Id = 'cd9961bf-f656-4382-8354-803c16090314';
  late MenuRoleBloc _mb;
  static RequestHelper requestHelper = RequestHelper();

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

  // bool userHasPermission(String? url1) {
  //   print(_mb.menurole);
  //   print('url5:$url1');
  //   // Kiểm tra xem _mb.menurole có null không
  //   if (_mb.menurole != null) {
  //     url = _mb.menurole!
  //         .firstWhere((menuRole) => menuRole.url == url1,
  //             orElse: () => MenuRoleModel() as MenuRoleModel)
  //         ?.url;
  //     print('url1:$url');
  //     if (url == url1) {
  //       print("object:$url");
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   } else {
  //     // Trả về false nếu _mb.menurole là null
  //     return false;
  //   }
  // }
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
                  if (userHasPermission(menuRoles, 'nhap-bai-xe-mobi'))
                    CustomButton(
                        'NHẬP BÃI XE',
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              'assets/images/Button_QLBaiXe_NhapBai.png',
                            ),
                          ],
                        ), () {
                      _handleButtonTap(BaiXePage());
                    }),

                  if (userHasPermission(menuRoles, 'dieu-chuyen-xe-mobi'))
                    CustomButton(
                        'CHUYỂN BÃI',
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              'assets/images/Button_QLBaiXe_ChuyenBai.png',
                            ),
                          ],
                        ), () {
                      _handleButtonTap(ChuyenXePage());
                    }),
                  if (userHasPermission(menuRoles, 'tim-xe-mobi'))
                    CustomButton(
                        'TÌM XE',
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              'assets/images/Button_QLBaiXe_TimXeTrongBai.png',
                            ),
                          ],
                        ), () {
                      _handleButtonTap(TimXePage());
                    }),
                  if (userHasPermission(menuRoles, 'danh-sach-xe-cho-xuat-mobi'))
                    CustomButton(
                        'DANH SÁCH XE CHỜ XUẤT',
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              'assets/images/Button_02_QLBaiXe_XuatBai_DSChoXuat.png',
                            ),
                          ],
                        ), () {
                      _handleButtonTap(DSXChoXuatPage());
                    }),
                  // if (userHasPermission(
                  //     menuRoles, 'danh-sach-xe-nhap-bai-mobi'))
                  //   CustomButton(
                  //       'LỊCH SỬ XE NHẬP BÃI',
                  //       Stack(
                  //         alignment: Alignment.center,
                  //         children: [
                  //           Image.asset(
                  //             'assets/images/Button_09_LichSuCongViec_TheoCaNhan.png',
                  //           ),
                  //         ],
                  //       ), () {
                  //     _handleButtonTap(LSNhapBaiPage());
                  //   }),
                  if (userHasPermission(menuRoles, 'layout-bai-xe-mobi'))
                    CustomButton(
                        'LAYOUT BÃI XE',
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              'assets/images/Button_09_LichSuCongViec_TheoCaNhan.png',
                            ),
                          ],
                        ), () {
                      _handleButtonTap(MyApp());
                    }),
                  if (userHasPermission(menuRoles, 'qrcode-rut-xe-auto-mobi'))
                    CustomButtonRutXe(
                        'QRCODE_RÚT XE TẠI NHÀ MÁY',
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              'assets/images/Button_09_Barcode_maNV.png',
                            ),
                          ],
                        ), () {
                      _handleButtonTap(qrCodeRutXe());
                    }),
                ],
              ),

              // PageIndicator(currentPage: currentPage, pageCount: pageCount),
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
      child: Column(
        children: [
          Container(
            //  width: 28.w,
            // height: 35.h,
            alignment: Alignment.center,
            child: page,
          ),
          Text(
            buttonText.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppConfig.titleColor,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget CustomButtonRutXe(String buttonText, Widget page, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 32.w,
      child: Column(
        children: [
          Container(
            //  width: 28.w,
            // height: 35.h,
            alignment: Alignment.center,
            child: page,
          ),
          Text(
            buttonText.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    ),
  );
}
