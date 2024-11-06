import 'package:Thilogi/blocs/app_bloc.dart';
import 'package:Thilogi/blocs/dieuchuyen_bloc.dart';
import 'package:Thilogi/blocs/dongcont_bloc.dart';
import 'package:Thilogi/blocs/dongseal_bloc.dart';
import 'package:Thilogi/blocs/giaoxe_bloc.dart';
import 'package:Thilogi/blocs/huydongcont_bloc.dart';
import 'package:Thilogi/blocs/huydongseal_bloc.dart';
import 'package:Thilogi/blocs/huyxuatkho_bloc.dart';
import 'package:Thilogi/blocs/khoxe_bloc.dart';
import 'package:Thilogi/blocs/menu_roles.dart';
import 'package:Thilogi/blocs/nhapbai.dart';
import 'package:Thilogi/blocs/scan_bloc.dart';
import 'package:Thilogi/blocs/scan_nhanvien_bloc.dart';
import 'package:Thilogi/blocs/theme_bloc.dart';
import 'package:Thilogi/blocs/timxe.dart';
import 'package:Thilogi/blocs/user_bloc.dart';
import 'package:Thilogi/blocs/vitri_bloc.dart';
import 'package:Thilogi/blocs/xeracong_bloc.dart';
import 'package:Thilogi/blocs/xuatkho_bloc.dart';
import 'package:Thilogi/models/theme.dart';
import 'package:Thilogi/pages/splash.dart';
import 'package:Thilogi/services/auth_service.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'blocs/TrackingXe.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeBloc>(
      create: (_) => ThemeBloc(),
      child: Consumer<ThemeBloc>(
        builder: (_, mode, __) {
          return Sizer(
            builder: (context, orientation, deviceType) => MultiProvider(
              providers: [
                ChangeNotifierProvider<AppBloc>(
                  create: (context) => AppBloc(),
                ),
                ChangeNotifierProvider<NhapBaiBloc>(
                  create: (context) => NhapBaiBloc(),
                ),
                ChangeNotifierProvider<UserBloc>(
                  create: (context) => UserBloc(),
                ),
                ChangeNotifierProvider<AuthService>(
                  create: (context) => AuthService(),
                ),
                ChangeNotifierProvider<ScanBloc>(
                  create: (context) => ScanBloc(),
                ),
                ChangeNotifierProvider<KhoXeBloc>(
                  create: (context) => KhoXeBloc(),
                ),
                ChangeNotifierProvider<XuatKhoBloc>(
                  create: (context) => XuatKhoBloc(),
                ),
                ChangeNotifierProvider<GiaoXeBloc>(
                  create: (context) => GiaoXeBloc(),
                ),
                ChangeNotifierProvider<DieuChuyenBloc>(
                  create: (context) => DieuChuyenBloc(),
                ),
                ChangeNotifierProvider<DongContBloc>(
                  create: (context) => DongContBloc(),
                ),
                ChangeNotifierProvider<DongSealBloc>(
                  create: (context) => DongSealBloc(),
                ),
                ChangeNotifierProvider<MenuRoleBloc>(
                  create: (context) => MenuRoleBloc(),
                ),
                ChangeNotifierProvider<ViTriBloc>(
                  create: (context) => ViTriBloc(),
                ),
                ChangeNotifierProvider<TimXeBloc>(
                  create: (context) => TimXeBloc(),
                ),
                ChangeNotifierProvider<TrackingBloc>(
                  create: (context) => TrackingBloc(),
                ),
                ChangeNotifierProvider<Scan_NhanVienBloc>(
                  create: (context) => Scan_NhanVienBloc(),
                ),
                ChangeNotifierProvider<XeRaCongBloc>(
                  create: (context) => XeRaCongBloc(),
                ),
                ChangeNotifierProvider<HuyXuatKhoBloc>(
                  create: (context) => HuyXuatKhoBloc(),
                ),
                ChangeNotifierProvider<HuyDongContBloc>(
                  create: (context) => HuyDongContBloc(),
                ),
                ChangeNotifierProvider<HuyDongSealBloc>(
                  create: (context) => HuyDongSealBloc(),
                ),
              ],
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,

                title: 'THILOGI ',
                // theme: ThemeModel().lightTheme,
                // darkTheme: ThemeModel().darkTheme,

                // themeMode:
                //     mode.darkTheme == true ? ThemeMode.dark : ThemeMode.light,
                theme: ThemeData(
                  primarySwatch: Colors.blue,
                ),
                home: SplashPage(),
              ),
            ),
          );
        },
      ),
    );
  }
}
