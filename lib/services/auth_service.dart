import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Thilogi/models/user.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:quickalert/quickalert.dart';

class AuthService extends ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  UserModel? _user;
  UserModel? get user => _user;

  bool _hasError = false;
  bool get hasError => _hasError;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorCode;
  String? get errorCode => _errorCode;

  Future login(BuildContext context, String userName, String password,
      String domain) async {
    _isLoading = true;
    _user = null;
    try {
      _hasError = false;
      final http.Response response = await requestHelper.loginAction(
        jsonEncode(
          {
            "username": userName,
            "password": password,
            "domain": domain,
          },
        ),
      );
      print('Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print('du lieu :  ${data}');

        _user = UserModel(
          id: data['id'],
          email: data['email'],
          fullName: data['fullName'],
          mustChangePass: data['mustChangePass'],
          token: data['token'],
          refreshToken: data['refreshToken'],
          accessRole: data['accessRole'],
          hinhAnhUrl: data['hinhAnhUrl'],
          qrCode: data['qrCode'],
          maNhanVien: data['maNhanVien'],
          tenPhongBan: data['tenPhongBan'],
          congBaoVe: data['congBaoVe'],
        );
      } else {
        String errorMessage = response.body.replaceAll('"', '');
        notifyListeners();
        QuickAlert.show(
          // ignore: use_build_context_synchronously
          context: context,
          type: QuickAlertType.error,
          title: 'Thất bại',
          confirmBtnText: 'Đồng ý',
          text: errorMessage,
        );
        _user = null;
        _isLoading = false;
      }
      notifyListeners();
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
      notifyListeners();
    }
  }
}
