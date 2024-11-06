import 'dart:convert';

import 'package:Thilogi/models/giaoxe.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Thilogi/services/request_helper.dart';
import 'package:quickalert/quickalert.dart';

class GiaoXeBloc extends ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  GiaoXeModel? _giaoxe;
  GiaoXeModel? get giaoxe => _giaoxe;

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
    _giaoxe = null;
    try {
      final http.Response response = await requestHelper
          .getData('KhoThanhPham/GetSoKhungGiaoXemobi?SoKhung=$qrcode');
      print(response.statusCode);
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        if (decodedData != null) {
          _giaoxe = GiaoXeModel(
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
            kho_Id: decodedData['kho_Id'],
            bienSo_Id: decodedData['bienSo_Id'],
            taiXe_Id: decodedData['taiXe_Id'],
            nguoiNhan: decodedData['nguoiNhan'],
            tenDiaDiem: decodedData['tenDiaDiem'],
            tenPhuongThucVanChuyen: decodedData['tenPhuongThucVanChuyen'],
            toaDo: decodedData['toaDo'],
            noigiao: decodedData['noigiao'],
            dangDiChuyen: decodedData['dangDiChuyen'],
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
          text: errorMessage,
          confirmBtnText: 'Đồng ý',
        );
        _giaoxe = null;
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
