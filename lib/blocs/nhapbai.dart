import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Thilogi/models/khothanhpham.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:quickalert/quickalert.dart';

class NhapBaiBloc extends ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  KhoThanhPhamModel? _baixe;
  KhoThanhPhamModel? get baixe => _baixe;

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
    _baixe = null;
    try {
      final http.Response response = await requestHelper
          .getData('KhoThanhPham/GetSoKhungNhapKhoBaimobi?SoKhung=$qrcode');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("data: ${decodedData}");
        if (decodedData != null) {
          _baixe = KhoThanhPhamModel(
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
            Kho_Id: decodedData['Kho_Id'],
            BaiXe_Id: decodedData['BaiXe_Id'],
            viTri_Id: decodedData['viTri_Id'],
            toaDo: decodedData['toaDo'],
            hinhAnh: decodedData['hinhAnh'],
          );
        }
      } else {
        String errorMessage = response.body.replaceAll('"', '');
        notifyListeners();
        if (errorMessage.isEmpty) {
          errorMessage = "Xe chưa nhận xe";
        }
        QuickAlert.show(
          // ignore: use_build_context_synchronously
          context: context,
          type: QuickAlertType.info,
          title: '',
          text: errorMessage,
          confirmBtnText: 'Đồng ý',
        );
        _baixe = null;
        _isLoading = false;
      }

      notifyListeners();
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
      notifyListeners();
    }
  }

  Future<void> postData(KhoThanhPhamModel scanData) async {
    _isLoading = true;
    try {
      var newScanData = scanData;
      newScanData.soKhung =
          newScanData.soKhung == 'null' ? null : newScanData.soKhung;
      print("print data: ${newScanData.soKhung}");
      final http.Response response = await requestHelper.postData(
          'KhoThanhPham/NhapKhoBai', newScanData.toJson());
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        print("data: ${decodedData}");
        _isLoading = false;
        _success = decodedData["success"];
      }
    } catch (e) {
      _message = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
