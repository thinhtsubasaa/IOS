import 'dart:convert';

import 'package:Thilogi/models/listcongviec.dart';
import 'package:Thilogi/pages/login/Login.dart';
import 'package:Thilogi/pages/lscongviec/LSCongviec.dart';
import 'package:Thilogi/pages/qldongcont/qldongcont.dart';

import 'package:Thilogi/pages/vanchuyen/giaoxe/VanChuyen.dart';

import 'package:Thilogi/services/app_service.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/pages/QLBaixe/QLBaixe.dart';
import 'package:Thilogi/pages/nhanxe/NhanXe.dart';
import 'package:Thilogi/pages/tracking/TrackingXe_Vitri.dart';
import 'package:Thilogi/utils/next_screen.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import '../../blocs/menu_roles.dart';
import '../../config/config.dart';
import '../../models/menurole.dart';
import '../../widgets/loading.dart';
import '../congviecchuyenbai/cv_chuyenbai.dart';
import '../congviecvanchuyen/cv_vanchuyen.dart';
import '../qlkehoach/themkehoach.dart';

// ignore: use_key_in_widget_constructors
class CustomBodyQLKhoXe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 100.w, child: BodyQLKhoXeScreen());
  }
}

class BodyQLKhoXeScreen extends StatefulWidget {
  const BodyQLKhoXeScreen({Key? key}) : super(key: key);

  @override
  _BodyQLKhoXeScreenState createState() => _BodyQLKhoXeScreenState();
}

// ignore: use_key_in_widget_constructors, must_be_immutable
class _BodyQLKhoXeScreenState extends State<BodyQLKhoXeScreen> with TickerProviderStateMixin, ChangeNotifier {
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
  List<CongViecModel>? _chuyenbaiList;
  List<CongViecModel>? get chuyenbaiList => _chuyenbaiList;
  List<CongViecModel>? _vanchuyenList;
  List<CongViecModel>? get vanchuyenList => _vanchuyenList;

  @override
  void initState() {
    super.initState();
    _checkInternetAndShowAlert();
    _mb = Provider.of<MenuRoleBloc>(context, listen: false);
    _menuRoleFuture = _fetchMenuRoles();
    getListXeRaCong();
  }

  Future<void> getListXeRaCong() async {
    setState(() {
      _isLoading = true;
      _chuyenbaiList = [];
      _vanchuyenList = []; // Làm sạch danh sách cũ trước khi tải mới
    });
    try {
      final http.Response response = await requestHelper.getData('Kho/GetListCongViec');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        if (decodedData != null) {
          _chuyenbaiList = (decodedData['data'] as List).map((item) => CongViecModel.fromJson(item)).toList();
          _vanchuyenList = (decodedData['dulieu'] as List).map((item) => CongViecModel.fromJson(item)).toList();

          // Gọi setState để cập nhật giao diện
          setState(() {
            _loading = false;
          });
        }
      } else {
        _chuyenbaiList = [];
        _vanchuyenList = []; // Làm sạch danh sách cũ trước khi tải mới
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
      notifyListeners();
    }
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
  //             orElse: () => MenuRoleModel())
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
        : RefreshIndicator(
            onRefresh: () async {
              await getListXeRaCong();
              await _mb.getData(context, DonVi_Id, PhanMem_Id);
            }, // Gọi hàm tải lại dữ liệu
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(children: [
                SizedBox(
                  height: 5,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (userHasPermission(menuRoles, 'xe-dang-chuyen-bai-mobi'))
                      GestureDetector(
                        onTap: () {
                          // Chuyển sang màn hình hoặc xử lý sự kiện
                          nextScreen(context, CongViecChuyenBaiPage());
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent,
                            border: Border.all(color: Colors.orangeAccent, width: 5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: buildRow(
                            context,
                            imageUrl: 'assets/images/Button_QLBaiXe_ChuyenBai.png',
                            text: "Xe đang chuyển bãi: ${_chuyenbaiList?.length.toString() ?? ""}",
                            onTap: () {
                              // Chuyển trang hoặc xử lý sự kiện
                              nextScreen(context, CongViecChuyenBaiPage());
                            },
                          ),
                        ),
                      ),
                    if (userHasPermission(menuRoles, 'xe-dang-van-chuyen-mobi'))
                      GestureDetector(
                        onTap: () {
                          // Chuyển sang màn hình hoặc xử lý sự kiện
                          nextScreen(context, CongViecVanChuyenPage());
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent,
                            border: Border.all(color: Colors.orangeAccent, width: 5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: buildRow(
                            context,
                            imageUrl: 'assets/images/Button_04_VC_GX_XuatBai.png',
                            text: "Xe đang vận chuyển: ${_vanchuyenList?.length.toString() ?? ""}",
                            onTap: () {
                              // Chuyển trang hoặc xử lý sự kiện
                              nextScreen(context, CongViecVanChuyenPage());
                            },
                          ),
                        ),
                      ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  // margin: const EdgeInsets.only(top: 25, bottom: 25),
                  child: Wrap(
                    spacing: 20.0, // khoảng cách giữa các nút
                    runSpacing: 20.0, // khoảng cách giữa các hàng
                    alignment: WrapAlignment.center,
                    children: [
                      if (userHasPermission(menuRoles, 'kiem-tra-nhan-xe-mobi'))
                        CustomButton(
                          'KIỂM TRA NHẬN XE',
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                'assets/images/Button_NhanXe_3b.png',
                              ),
                            ],
                          ),
                          () {
                            _handleButtonTap(NhanXePage());
                          },
                        ),
                      if (userHasPermission(menuRoles, 'quan-ly-bai-xe-mobi'))
                        CustomButton(
                          'QUẢN LÝ BÃI XE',
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                'assets/images/Button_QLBaiXe.png',
                              ),
                            ],
                          ),
                          () {
                            _handleButtonTap(QLBaiXePage());
                          },
                        ),
                      if (userHasPermission(menuRoles, 'van-chuyen-giao-xe-mobi'))
                        CustomButton(
                          'VẬN CHUYỂN GIAO XE',
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                'assets/images/Button_VC_GX.png',
                              ),
                            ],
                          ),
                          () {
                            _handleButtonTap(VanChuyenPage());
                          },
                        ),
                      if (userHasPermission(menuRoles, 'quan-ly-dong-cont-mobi'))
                        CustomButton(
                          'QUẢN LÝ ĐÓNG CONT',
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                'assets/images/Button_DongCont.png',
                              ),
                            ],
                          ),
                          () {
                            _handleButtonTap(QLDongContPage());
                          },
                        ),
                      if (userHasPermission(menuRoles, 'tracking-xe-thanh-pham-mobi'))
                        CustomButton(
                          'TRACKING XE THÀNH PHẨM',
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                'assets/images/Button_Tracking.png',
                              ),
                            ],
                          ),
                          () {
                            _handleButtonTap(TrackingXeVitriPage());
                          },
                        ),
                      if (userHasPermission(menuRoles, 'lich-su-cong-viec-mobi'))
                        CustomButton(
                          'LỊCH SỬ CÔNG VIỆC',
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                'assets/images/Button_09_LichSuCongViec.png',
                              ),
                            ],
                          ),
                          () {
                            _handleButtonTap(LSCongViecPage());
                          },
                        ),
                      if (userHasPermission(menuRoles, 'quan-ly-ke-hoach-mobi'))
                        CustomButton(
                          'QUẢN LÝ KẾ HOẠCH',
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                'assets/images/Button_09_LichSuCongViec.png',
                              ),
                            ],
                          ),
                          () {
                            _handleButtonTap(ThemKeHoachPage());
                          },
                        ),
                      // if (userHasPermission(menuRoles, 'thong-tin-nhan-vien-mobi'))
                      //   CustomButton(
                      //     'TRA CỨU THÔNG TIN NHÂN VIÊN',
                      //     Stack(
                      //       alignment: Alignment.center,
                      //       children: [
                      //         Image.asset(
                      //           'assets/images/Button_TTTheNhanVien.png',
                      //         ),
                      //       ],
                      //     ),
                      //     () {
                      //       _handleButtonTap(TraCuuPage());
                      //     },
                      //   ),
                      // if (userHasPermission(menuRoles, 'thong-tin-xe-ra-cong-mobi'))
                      //   CustomButton(
                      //     'THÔNG TIN XE RA CỔNG',
                      //     Stack(
                      //       alignment: Alignment.center,
                      //       children: [
                      //         Image.asset(
                      //           'assets/images/Button_TTTheNhanVien.png',
                      //         ),
                      //       ],
                      //     ),
                      //     () {
                      //       _handleButtonTap(XeRaCongPage());
                      //     },
                      //   ),
                    ],
                  ),
                ),
              ]),
            ),
          );
  }

  Widget buildRow(BuildContext context, {required String imageUrl, required String text, required VoidCallback onTap}) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.white, width: 5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon(icon, color: Colors.blue),

          ClipRRect(
            borderRadius: BorderRadius.circular(6), // Bo góc ảnh theo viền
            child: Image.asset(
              imageUrl,
              fit: BoxFit.cover,
            ),
          ),

          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: text.split(':').first + ": ", // Phần trước dấu ":" có màu đen
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: text.split(':').last.trim(), // Phần số sau dấu ":" có màu đỏ
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onTap,
            child: Icon(Icons.arrow_forward_ios, color: AppConfig.primaryColor),
          ),
        ],
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
      width: 35.w,
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
