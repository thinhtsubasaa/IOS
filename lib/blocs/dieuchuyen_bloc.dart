import 'dart:convert';

import 'package:Thilogi/models/dieuchuyen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Thilogi/services/request_helper.dart';
import 'package:quickalert/quickalert.dart';

class DieuChuyenBloc extends ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  DieuChuyenModel? _dieuchuyen;
  DieuChuyenModel? get dieuchuyen => _dieuchuyen;

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
    _dieuchuyen = null;
    try {
      final http.Response response = await requestHelper.getData('KhoThanhPham/GetSoKhungDieuchuyenmobi?SoKhung=$qrcode');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("data: ${decodedData}");
        if (decodedData != null) {
          _dieuchuyen = DieuChuyenModel(
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
            tenBaiXe: decodedData['tenBaiXe'],
            mauSon: decodedData['mauSon'],
            ngayNhapKhoView: decodedData['ngayNhapKhoView'],
            tenTaiXe: decodedData['tenTaiXe'],
            ghiChu: decodedData['ghiChu'],
            khoDen_Id: decodedData['khoDen_Id'],
            baiXe_Id: decodedData['baiXe_Id'],
            viTri_Id: decodedData['viTri_Id'],
            taiXe_Id: decodedData['taiXe_Id'],
            viTri: decodedData['viTri'],
            toaDo: decodedData['toaDo'],
            thoiGianBatDau: decodedData['thoiGianBatDau'],
            thoiGianKetThuc: decodedData['thoiGianKetThuc'],
            dangDiChuyen: decodedData['dangDiChuyen'],
            hinhAnh: decodedData['hinhAnh'],
            donVi: decodedData['donVi'],
            phuongThuc: decodedData['phuongThuc'],
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
        _dieuchuyen = null;
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
