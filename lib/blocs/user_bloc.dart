import 'package:flutter/foundation.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class UserBloc extends ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  UserBloc() {
    checkSignIn();
  }

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  String? _fullName;
  String? get name => _fullName;
  String? _accessRole;
  String? get accessRole => _accessRole;

  String? _id;
  String? get id => _id;

  String? _email;
  String? get email => _email;

  String? _expires;
  String? get expires => _expires;

  bool _mustChangePass = false;
  bool get mustChangePass => _mustChangePass;

  String? _token;
  String? get token => _token;

  String? _refreshToken;
  String? get refreshToken => _refreshToken;
  String? _hinhAnhUrl;
  String? get hinhAnhUrl => _hinhAnhUrl;
  String? _qrCode;
  String? get qrCode => _qrCode;
  String? _maNhanVien;
  String? get maNhanVien => _maNhanVien;
  String? _tenPhongBan;
  String? get tenPhongBan => _tenPhongBan;
  String? _congBaoVe;
  String? get congBaoVe => _congBaoVe;

  Future saveUserData(UserModel userModel) async {
    // ignore: unnecessary_null_comparison
    if (userModel != null) {
      final SharedPreferences sp = await SharedPreferences.getInstance();
      sp.setString('id', userModel.id ?? '');
      sp.setString('fullName', userModel.fullName ?? '');
      sp.setString('email', userModel.email ?? '');
      sp.setBool('mustChangePass', userModel.mustChangePass ?? false);
      sp.setString('token', userModel.token ?? '');
      sp.setString('refreshToken', userModel.refreshToken ?? '');
      sp.setString('accessRole', userModel.accessRole ?? '');
      sp.setString('hinhAnhUrl', userModel.hinhAnhUrl ?? '');
      sp.setString('qrCode', userModel.qrCode ?? '');
      sp.setString('maNhanVien', userModel.maNhanVien ?? '');
      sp.setString('tenPhongBan', userModel.tenPhongBan ?? '');
      sp.setString('congBaoVe', userModel.congBaoVe ?? '');

      _id = userModel.id;
      _fullName = userModel.fullName;
      _email = userModel.email;
      _mustChangePass = userModel.mustChangePass ?? false;
      _token = userModel.token;
      _refreshToken = userModel.refreshToken;
      _accessRole = userModel.accessRole;
      _hinhAnhUrl = userModel.hinhAnhUrl;
      _qrCode = userModel.qrCode;
      _maNhanVien = userModel.maNhanVien;
      _tenPhongBan = userModel.tenPhongBan;
      _congBaoVe = userModel.congBaoVe;
      notifyListeners();
    }
  }

  Future getUserData() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _id = sp.getString('id');
    _fullName = sp.getString('fullName');
    _email = sp.getString('email');
    _expires = sp.getString('expires');
    _mustChangePass = sp.getBool('mustChangePass')!;
    _token = sp.getString('token');
    _refreshToken = sp.getString('refreshToken');
    _accessRole = sp.getString('accessRole');
    _hinhAnhUrl = sp.getString('hinhAnhUrl');
    _qrCode = sp.getString('qrCode');
    _maNhanVien = sp.getString('maNhanVien');
    _tenPhongBan = sp.getString('tenPhongBan');
    _congBaoVe = sp.getString('congBaoVe');
    notifyListeners();
  }

  set hinhAnhUrl(String? value) {
    _hinhAnhUrl = value;
    notifyListeners();
  }

  Future refreshTokenValue(data) async {
    _token = data["token"];
    _refreshToken = data["refreshToken"];
    notifyListeners();
  }

  Future setSignIn() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool('signed_in', true);
    _isSignedIn = true;
    notifyListeners();
  }

  Future checkSignIn() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _isSignedIn = sp.getBool('signed_in') ?? false;
    notifyListeners();
  }

  Future userSignout() async {
    await clearAllUserData().then((_) {
      _isSignedIn = false;
      _expires = null;
      _fullName = null;
      _email = null;
      _token = null;
      _refreshToken = null;
      _id = null;
      _accessRole = null;
      _hinhAnhUrl = null;
      _qrCode = null;
      _maNhanVien = null;
      _tenPhongBan = null;
      _congBaoVe = null;
      notifyListeners();
    });
  }

  Future clearAllUserData() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.clear();
  }
}
