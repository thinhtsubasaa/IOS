import 'dart:convert';

import 'package:Thilogi/models/doimatkhau.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Thilogi/pages/qlkho/QLKhoXe.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/blocs/app_bloc.dart';
import 'package:Thilogi/blocs/user_bloc.dart';
import 'package:Thilogi/models/icon_data.dart';
import 'package:Thilogi/services/app_service.dart';
import 'package:Thilogi/services/auth_service.dart';
import 'package:Thilogi/utils/next_screen.dart';
import 'package:Thilogi/widgets/loading_button.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import '../../config/config.dart';
import '../../widgets/loading.dart';

class ChangePass extends StatefulWidget {
  const ChangePass({super.key});

  @override
  State<ChangePass> createState() => _ChangePassPopupState();
}

class _ChangePassPopupState extends State<ChangePass> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Đổi mật khẩu').tr(),
      ),
      body: CustomMatKhauForm(),
    );
  }
}

// ignore: use_key_in_widget_constructors
class CustomMatKhauForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 100.w,
        // ignore: prefer_const_constructors
        color: Color.fromRGBO(246, 198, 199, 0.2),
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: MatKhauScreen());
  }
}

class MatKhauScreen extends StatefulWidget {
  const MatKhauScreen({Key? key}) : super(key: key);
  @override
  _MatKhauScreenState createState() => _MatKhauScreenState();
}

class _MatKhauScreenState extends State<MatKhauScreen>
    with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();
  bool _loading = false;
  DoiMatKhauModel? _data;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _message;
  String? get message => _message;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var passwordCtrl = TextEditingController();
  var newpasswordCtrl = TextEditingController();
  var confirmpasswordCtrl = TextEditingController();

  bool obscureText = true;
  late String selectedDomain;

  final _btnController = RoundedLoadingButtonController();

  bool offsecureText = true;
  Icon lockIcon = LockIcon().lock;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    passwordCtrl.dispose();
    newpasswordCtrl.dispose();
    confirmpasswordCtrl.dispose();
    super.dispose();
  }

  void _onlockPressed() {
    if (offsecureText == true) {
      setState(() {
        offsecureText = false;
        lockIcon = LockIcon().open;
      });
    } else {
      setState(() {
        offsecureText = true;
        lockIcon = LockIcon().lock;
      });
    }
  }

  Future<void> postData(DoiMatKhauModel scanData) async {
    // _isLoading = true;
    try {
      var newScanData = scanData;

      print("print data: ${newScanData.newPassword}");
      final http.Response response = await requestHelper.postData(
          'Account/ChangePassword', newScanData.toJson());
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("data: ${decodedData}");

        notifyListeners();
        _btnController.success();
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Thành công',
          text: "Đổi mật khẩu thành công",
          confirmBtnText: 'Đồng ý',
        );
        _btnController.reset();
      } else {
        String errorMessage = response.body.replaceAll('"', '');
        if (errorMessage == "Mật khẩu hiện tại không đúng") {
          notifyListeners();
          _btnController.error();
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Thất bại',
            text: errorMessage,
            confirmBtnText: 'Đồng ý',
          );
        }
      }
    } catch (e) {
      _message = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  _onSave() {
    setState(() {
      _loading = true;
    });
    if (_data == null) {
      _data = DoiMatKhauModel();
    }
    if (passwordCtrl.text.isEmpty) {
      _btnController.reset();
      // openSnackBar(context, 'username is required'.trim());
      QuickAlert.show(
        // ignore: use_build_context_synchronously
        context: context,
        type: QuickAlertType.error,
        title: 'Thất bại',
        text: 'Hãy nhập mật khẩu cũ',
        confirmBtnText: 'Đồng ý',
      );
    } else if (newpasswordCtrl.text.isEmpty) {
      _btnController.reset();
      // ignore: use_build_context_synchronously
      // openSnackBar(context, 'password is required'.trim());
      QuickAlert.show(
        // ignore: use_build_context_synchronously
        context: context,
        type: QuickAlertType.error,
        title: 'Thất bại',
        text: 'Hãy nhập mật khẩu mới',
        confirmBtnText: 'Đồng ý',
      );
    } else if (confirmpasswordCtrl.text.isEmpty) {
      _btnController.reset();
      // ignore: use_build_context_synchronously
      // openSnackBar(context, 'password is required'.trim());
      QuickAlert.show(
        // ignore: use_build_context_synchronously
        context: context,
        type: QuickAlertType.error,
        title: 'Thất bại',
        text: 'Hãy xác nhận mật khẩu mới',
        confirmBtnText: 'Đồng ý',
      );
      // } else if (passwordCtrl.text == newpasswordCtrl.text) {
      //   _btnController.reset();
      //   // ignore: use_build_context_synchronously
      //   // openSnackBar(context, 'password is required'.trim());
      //   QuickAlert.show(
      //     // ignore: use_build_context_synchronously
      //     context: context,
      //     type: QuickAlertType.error,
      //     title: 'Thất bại',
      //     text: 'Mật khẩu mới và mật khẩu cũ đã trùng khớp',
      //     confirmBtnText: 'Đồng ý',
      //   );
    } else if (newpasswordCtrl.text != confirmpasswordCtrl.text) {
      _btnController.reset();
      // ignore: use_build_context_synchronously
      // openSnackBar(context, 'password is required'.trim());
      QuickAlert.show(
        // ignore: use_build_context_synchronously
        context: context,
        type: QuickAlertType.error,
        title: 'Thất bại',
        text: 'Mật khẩu mới và mật khẩu xác định không trùng khớp',
        confirmBtnText: 'Đồng ý',
      );
    }

    _data?.password = passwordCtrl.text;
    _data?.newPassword = newpasswordCtrl.text;
    _data?.confirmNewPassword = confirmpasswordCtrl.text;

    print("Pass: ${_data?.newPassword}");

    AppService().checkInternet().then((hasInternet) {
      if (!hasInternet!) {
        // openSnackBar(context, 'no internet'.tr());
        QuickAlert.show(
          // ignore: use_build_context_synchronously
          context: context,
          type: QuickAlertType.error,
          title: 'Thất bại',
          text: 'Không có kết nối internet. Vui lòng kiểm tra lại',
          confirmBtnText: 'Đồng ý',
        );
      } else {
        postData(_data!).then((_) {
          setState(() {
            _data = null;
            // passwordCtrl.text = '';
            // newpasswordCtrl.text = '';
            // confirmpasswordCtrl.text = '';
            _loading = false;
          });
        });
      }
    });
  }

  void _showConfirmationDialog(BuildContext context) {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        text: 'Bạn có đổi mật khẩu không?',
        title: '',
        confirmBtnText: 'Đồng ý',
        cancelBtnText: 'Không',
        confirmBtnTextStyle: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
        cancelBtnTextStyle: TextStyle(
          color: Colors.red,
          fontSize: 19.0,
          fontWeight: FontWeight.bold,
        ),
        onCancelBtnTap: () {
          Navigator.of(context).pop();
          _btnController.reset();
        },
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
          _onSave();
        });
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? LoadingWidget(context)
        : AutofillGroup(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    "Mật khẩu cũ",
                    style: TextStyle(
                      color: AppConfig.textInput,
                      fontFamily: 'Roboto',
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 70.w,
                  height: 8.h,
                  child: TextFormField(
                    controller: passwordCtrl,
                    autofillHints: [AutofillHints.password],
                    obscureText: obscureText,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureText ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            obscureText = !obscureText;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Mật khẩu mới",
                  style: TextStyle(
                    color: AppConfig.textInput,
                    fontFamily: 'Roboto',
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 70.w,
                  height: 8.h,
                  child: TextFormField(
                    controller: newpasswordCtrl,
                    autofillHints: [AutofillHints.password],
                    obscureText: obscureText,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureText ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            obscureText = !obscureText;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Xác nhận mật khẩu",
                  style: TextStyle(
                    color: AppConfig.textInput,
                    fontFamily: 'Roboto',
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 70.w,
                  height: 8.h,
                  child: TextFormField(
                    controller: confirmpasswordCtrl,
                    autofillHints: [AutofillHints.password],
                    obscureText: obscureText,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureText ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            obscureText = !obscureText;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RoundedLoadingButton(
                        child: Text('Lưu',
                            style: TextStyle(
                              fontFamily: 'Comfortaa',
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            )),
                        controller: _btnController,
                        onPressed: confirmpasswordCtrl.text != null
                            ? () => _showConfirmationDialog(context)
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
              ],
            ),
          );
  }

  // void _handleButtonTap(Widget page) {
  //   if (!mounted) return;
  //   setState(() {
  //     _loading = true;
  //   });
  //   nextScreenCloseOthers(context, page);
  //   Future.delayed(Duration(seconds: 1), () {
  //     setState(() {
  //       _loading = false;
  //     });
  //   });
  // }
}
