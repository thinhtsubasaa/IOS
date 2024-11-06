import 'package:Thilogi/models/dieuchuyen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/scan.dart';

class AppBloc extends ChangeNotifier {
  SharedPreferences? _pref;

  String _apiUrl = "https://10.17.42.177:5001";
  // String _apiUrl = "https://apiwms.thilogi.vn";

  String get apiUrl => _apiUrl;

  String? _appFunctions = "none";
  String? get appFunctions => _appFunctions;

  ScanModel? _scan;
  ScanModel? get scan => _scan;
  DieuChuyenModel? _dieuChuyen;
  DieuChuyenModel? get dieuchuyen => _dieuChuyen;
  String? _id;
  String? get id => _id;

  String? _Kho_Id;
  String? get Kho_Id => Kho_Id;
  String? _soKhung;
  String? get soKhung => _soKhung;

  String? _tenKho;
  String? get tenKho => _tenKho;
  String? _tenSanPham;
  String? get tenSanPham => _tenSanPham;

  String? _tenMau;
  String? get tenMau => _tenMau;

  String? _appVersion = '1.0.0';
  String? get appVersion => _appVersion;

  AppBloc() {
    getAppFunction();
    getApiUrl();
  }
  _initPrefs() async {
    _pref ??= await SharedPreferences.getInstance();
  }

  Future getApiUrl() async {
    await _initPrefs();
    _apiUrl = _pref!.getString('apiUrl') != null ? _pref!.getString('apiUrl')! : _apiUrl;
    notifyListeners();
  }

  Future saveApiUrl(String url) async {
    await _initPrefs();
    await _pref!.setString('apiUrl', url);
    _apiUrl = url;
    notifyListeners();
  }

  Future saveData(String? iD, String kiD, String sK, String tK, String tSp, String tM) async {
    await _initPrefs();
    await _pref!.setString('id', iD!.toString());
    await _pref!.setString('Kho_Id', kiD!.toString());
    await _pref!.setString('soKhung', sK);
    await _pref!.setString('tenKho', tK);
    await _pref!.setString('tenSanPham', tSp);
    await _pref!.setString('tenMau', tM);

    _id = iD.toString();
    _Kho_Id = kiD.toString();
    _soKhung = sK;
    _tenKho = tK;
    _tenSanPham = tSp;
    _tenMau = tM;
    notifyListeners();
  }

  Future getData() async {
    await _initPrefs();
    _id = _pref!.getString('id');
    _Kho_Id = _pref!.getString('kho_Id');
    _soKhung = _pref!.getString('soKhung');
    _tenKho = _pref!.getString('tenKho');
    _tenSanPham = _pref!.getString('tenSanPham');
    _tenMau = _pref!.getString('tenMau');
    _appVersion = _pref!.getString('appVersion');
    notifyListeners();
  }

  Future clearData() async {
    _scan?.id = null;
    _scan?.Kho_Id = null;
    _scan?.soKhung = null;
    _scan?.tenKho = null;
    _scan?.tenSanPham = null;
    _scan?.tenMau = null;

    notifyListeners();
  }

  Future setAppFunction(String value) async {
    await _initPrefs();
    await _pref!.setString('appFunctions', value);
    _appFunctions = value;
    notifyListeners();
  }

  Future getAppFunction() async {
    await _initPrefs();
    _appFunctions = _pref!.getString('appFunctions');
    notifyListeners();
  }
}
