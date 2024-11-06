import 'dart:convert';
import 'package:Thilogi/models/timxe.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Thilogi/services/request_helper.dart';
import 'package:quickalert/quickalert.dart';

class TimXeBloc extends ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  TimXeModel? _timxe;
  TimXeModel? get timxe => _timxe;

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

  Future<void> getData(BuildContext context, String soKhung) async {
    _isLoading = true;
    _timxe = null;
    try {
      final http.Response response = await requestHelper
          .getData('KhoThanhPham/GetTimXeTrongBai?SoKhung=$soKhung');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("data: ${decodedData}");
        if (decodedData != null) {
          List<DieuChuyen> dieuChuyenList = [];
          if (decodedData['dieuChuyen'] != null &&
              decodedData['dieuChuyen'] is List) {
            dieuChuyenList = (decodedData['dieuChuyen'] as List<dynamic>)
                .map((item) => DieuChuyen.fromJson(item))
                .toList();
          }
          List<NhapKho> nhapKhoList = [];
          if (decodedData['nhapKho'] != null &&
              decodedData['nhapKho'] is List) {
            nhapKhoList = (decodedData['nhapKho'] as List<dynamic>)
                .map((item) => NhapKho.fromJson(item))
                .toList();
          }
          _timxe = TimXeModel(
            key: decodedData["key"],
            id: decodedData['id'],
            soKhung: decodedData['soKhung'],
            tenKho: decodedData['tenKho'],
            tenBaiXe: decodedData['tenBaiXe'],
            tenViTri: decodedData['tenViTri'],
            toaDo: decodedData['toaDo'],
            nguoiPhuTrach: decodedData['nguoiPhuTrach'],
            tenMau: decodedData['tenMau'],
            tenSanPham: decodedData['tenSanPham'],
            donVi: decodedData['donVi'],
            dieuChuyen: dieuChuyenList,
            nhapKho: nhapKhoList,
          );
        }
      } else {
        String errorMessage = response.body.replaceAll('"', '');
        notifyListeners();
        if (errorMessage.isEmpty) {
          errorMessage = "Xe chưa nhập kho";
        }

        QuickAlert.show(
          // ignore: use_build_context_synchronously
          context: context,
          type: QuickAlertType.info,
          title: '',
          text: errorMessage,
          confirmBtnText: 'Đồng ý',
        );
        _timxe = null;
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
