import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Thilogi/services/request_helper.dart';

import '../models/dongseal.dart';

class DongSealBloc extends ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  DongSealModel? _dongseal;
  DongSealModel? get dongseal => _dongseal;

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

  Future<void> getData(String qrcode) async {
    _isLoading = true;
    _dongseal = null;
    try {
      final http.Response response = await requestHelper
          .getData('KhoThanhPham/GetSoKhungDongContmobi?SoKhung=$qrcode');
      print(response.statusCode);
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("data: ${decodedData}");
        if (decodedData != null) {
          _dongseal = DongSealModel(
            key: decodedData["key"],
            id: decodedData['id'],
            soKhung: decodedData['soKhung'],
            soCont: decodedData['soCont'],
            soSeal: decodedData['soSeal'],
            lat: decodedData['lat'],
            long: decodedData['long'],
            toaDo: decodedData['toaDo'],
          );
        }
      } else {
        _dongseal = null;
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
