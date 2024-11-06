import 'package:Thilogi/blocs/app_bloc.dart';
import 'package:Thilogi/blocs/user_bloc.dart';
import 'package:Thilogi/utils/changepassword.dart';
import 'package:Thilogi/utils/language.dart';
import 'package:Thilogi/utils/next_screen.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_icons/flutter_icons.dart';

import '../blocs/theme_bloc.dart';
import '../utils/sign_out.dart';
import '../widgets/divider.dart';

// ignore: must_be_immutable
class SettingPage extends StatefulWidget {
  Function? disposeHome;
  bool? notAllowCauHinhTram = false;
  SettingPage({super.key, this.disposeHome, this.notAllowCauHinhTram});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late AppBloc _ab;
  String? _version;
  Map<String, dynamic>? values;

  @override
  void initState() {
    super.initState();
    _ab = Provider.of<AppBloc>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt').tr(),
      ),
      body: SingleChildScrollView(
        // physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          top: 15,
          bottom: 20,
        ),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 10,
              bottom: 10,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            child: UserUI(
              version: _version,
              values: values,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.onPrimary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Bản quyền thuộc về THACO THILOGI © 2024',
                  style: TextStyle(
                    fontSize: 14,
                    letterSpacing: -0.7,
                    wordSpacing: 1,
                  ),
                ).tr(),
              ],
            ),
          )
        ]),
      ),
    );
  }
}

class UserUI extends StatelessWidget {
  final String? version;
  final Map<String, dynamic>? values;

  const UserUI({
    super.key,
    required this.version,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    final UserBloc ub = context.watch<UserBloc>();
    final AppBloc ab = context.watch<AppBloc>();
    return Column(
      children: [
        // ListTile(
        //   contentPadding: EdgeInsets.all(0),
        //   leading: CircleAvatar(
        //     backgroundColor: Colors.greenAccent,
        //     radius: 18,
        //     child: Icon(
        //       Feather.cloud,
        //       size: 18,
        //       color: Colors.white,
        //     ),
        //   ),
        //   title: Text(
        //     ab.apiUrl,
        //     style: TextStyle(
        //       fontSize: 16,
        //       fontWeight: FontWeight.w500,
        //       color: Theme.of(context).colorScheme.primary,
        //     ),
        //   ),
        // ),
        // const DividerWidget(),
        // ListTile(
        //   contentPadding: const EdgeInsets.all(0),
        //   leading: const CircleAvatar(
        //     backgroundColor: Colors.black,
        //     radius: 18,
        //     child: Icon(
        //       Feather.activity,
        //       size: 18,
        //       color: Colors.white,
        //     ),
        //   ),
        //   title: Text("Phiên bản ${ab.appVersion}"),
        // ),
        // const DividerWidget(),
        ListTile(
          contentPadding: const EdgeInsets.all(0),
          leading: const CircleAvatar(
            backgroundColor: Colors.blueAccent,
            radius: 18,
            child: Icon(
              Feather.user_check,
              size: 18,
              color: Colors.white,
            ),
          ),
          title: Text(
            ub.name!.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const DividerWidget(),
        ListTile(
          contentPadding: const EdgeInsets.all(0),
          leading: CircleAvatar(
            backgroundColor: Colors.indigoAccent[100],
            radius: 18,
            child: const Icon(
              Feather.mail,
              size: 18,
              color: Colors.white,
            ),
          ),
          title: Text(
            ub.email!,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const DividerWidget(),
        ListTile(
          contentPadding: const EdgeInsets.all(0),
          leading: const CircleAvatar(
            backgroundColor: Colors.blueGrey,
            radius: 18,
            child: Icon(
              Icons.language,
              size: 18,
              color: Colors.white,
            ),
          ),
          title: Text(
            'Ngôn ngữ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary,
            ),
          ).tr(),
          trailing: const Icon(Feather.chevron_right),
          onTap: () => nextScreenPopup(context, const LanguagePopup()),
        ),
        const DividerWidget(),
        ListTile(
          contentPadding: const EdgeInsets.all(0),
          leading: CircleAvatar(
            backgroundColor: Colors.redAccent[100],
            radius: 18,
            child: Icon(
              Feather.lock,
              size: 18,
              color: Colors.white,
            ),
          ),
          title: Text(
            'Đổi mật khẩu',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary,
            ),
          ).tr(),
          trailing: const Icon(Feather.chevron_right),
          onTap: () => nextScreenPopup(context, const ChangePass()),
        ),
        const DividerWidget(),
        ListTile(
          contentPadding: const EdgeInsets.all(0),
          leading: CircleAvatar(
            backgroundColor: Colors.redAccent[100],
            radius: 18,
            child: const Icon(
              Feather.log_out,
              size: 18,
              color: Colors.white,
            ),
          ),
          title: Text(
            'Đăng xuất',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary,
            ),
          ).tr(),
          trailing: const Icon(Feather.chevron_right),
          onTap: () => openLogoutDialog(context),
        ),
      ],
    );
  }
}
