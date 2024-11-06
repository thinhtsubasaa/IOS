import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Thilogi/services/request_helper.dart';
import 'package:quickalert/quickalert.dart';

import '../models/dongcont.dart';

class HuyDongContBloc extends ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  DongContModel? _dongcont;
  DongContModel? get dongcont => _dongcont;

  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _success = false;
  bool get success => _success;

  String? _message;
  String? get message => _message;

  Future<void> getData(BuildContext context, String qrcode) async {
    _isLoading = true;
    _dongcont = null;
    try {
      final http.Response response = await requestHelper
          .getData('KhoThanhPham/GetSoKhungHuyDongContmobi?SoKhung=$qrcode');
      print(response.statusCode);
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("data: ${decodedData}");
        if (decodedData != null) {
          _dongcont = DongContModel(
            key: decodedData["key"],
            id: decodedData['id'],
            soKhung: decodedData['soKhung'],
            maSanPham: decodedData['maSanPham'],
            tenSanPham: decodedData['tenSanPham'],
            soMay: decodedData['soMay'],
            maMau: decodedData['maMau'],
            tenMau: decodedData['tenMau'],
            tenKho: decodedData['tenKho'],
            maViTri: decodedData['maViTri'],
            tenViTri: decodedData['tenViTri'],
            mauSon: decodedData['mauSon'],
            ngayNhapKhoView: decodedData['ngayNhapKhoView'],
            tenTaiXe: decodedData['tenTaiXe'],
            ghiChu: decodedData['ghiChu'],
            maKho: decodedData['maKho'],
            soCont: decodedData['soCont'],
            soSeal: decodedData['soSeal'],
            lat: decodedData['lat'],
            long: decodedData['long'],
            toaDo: decodedData['toaDo'],
            khuVuc: decodedData['khuVuc'],
          );
        }
      } else {
        String errorMessage = response.body.replaceAll('"', '');
        notifyListeners();
        QuickAlert.show(
          // ignore: use_build_context_synchronously
          context: context,
          type: QuickAlertType.info,
          title: '',
          confirmBtnText: 'Đồng ý',
          text: errorMessage,
        );
        _dongcont = null;
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
