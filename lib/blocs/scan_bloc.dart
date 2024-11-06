// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:Thilogi/models/scan.dart';
// import 'package:Thilogi/services/request_helper.dart';
// import 'package:quickalert/quickalert.dart';

// import '../models/getdata.dart';

// class ScanBloc extends ChangeNotifier {
//   static RequestHelper requestHelper = RequestHelper();

//   ScanModel? _scan;
//   ScanModel? get scan => _scan;
//   DataModel? _data;
//   DataModel? get data => _data;
//   bool _hasError = false;
//   bool get hasError => _hasError;

//   String? _errorCode;
//   String? get errorCode => _errorCode;
//   bool _isLoading = true;
//   bool get isLoading => _isLoading;

//   bool _success = false;
//   bool get success => _success;

//   String? _message;
//   String? get message => _message;

//   var headers = {
//     'ApiKey': 'qtsx2023',
//   };
//   Future<void> getData(BuildContext context, String qrcode) async {
//     _scan = null;
//     _data = null;
//     _isLoading = true;
//     try {
//       // final http.Response response = await requestHelper
//       //     .getData('GetDataXeThaPham/GetDuLieuXe?SoKhung=$qrcode');

//       final response = await http.get(
//         Uri.parse(
//             "https://qtsxautoapi.thacochulai.vn/api/KhoThanhPham/TraCuuXeThanhPham_Thilogi1?SoKhung=$qrcode"),
//         headers: headers,
//       );
//       print(response.statusCode);
//       if (response.statusCode == 200) {
//         var decodedData = jsonDecode(response.body);
//         print("data: ${decodedData}");
//         if (decodedData != null) {
//           List<PhuKien> phuKienList = [];
//           if (decodedData['phuKien'] != null &&
//               decodedData['phuKien'] is List) {
//             phuKienList = (decodedData['phuKien'] as List<dynamic>)
//                 .map((item) => PhuKien.fromJson(item))
//                 .toList();
//           }
//           _scan = ScanModel(
//             key: decodedData["key"],
//             id: decodedData['id'],
//             soKhung: decodedData['soKhung'],
//             maSanPham: decodedData['maSanPham'],
//             tenSanPham: decodedData['tenSanPham'],
//             soMay: decodedData['soMay'],
//             maMau: decodedData['maMau'],
//             tenMau: decodedData['tenMau'],
//             tenKho: decodedData['tenKho'],
//             maViTri: decodedData['maViTri'],
//             tenViTri: decodedData['tenViTri'],
//             mauSon: decodedData['mauSon'],
//             ngayXuatKhoView: decodedData['ngayXuatKhoView'],
//             tenTaiXe: decodedData['tenTaiXe'],
//             ghiChu: decodedData['ghiChu'],
//             Kho_Id: decodedData['Kho_Id'],
//             BaiXe_Id: decodedData['BaiXe_Id'],
//             viTri_Id: decodedData['viTri_Id'],
//             // phuKien: (decodedData['phuKien'] as List<dynamic>)
//             //     .map((item) => PhuKien.fromJson(item))
//             //     .toList(),
//             phuKien: phuKienList,
//           );
//         }
//       } else {
//         await _get(context, qrcode);
//       }

//       _isLoading = false;
//       notifyListeners();
//     } catch (e) {
//       _hasError = true;

//       _errorCode = e.toString();
//       notifyListeners();
//     }
//   }

//   Future<void> _get(BuildContext context, String qrcode) async {
//     try {
//       final http.Response response = await requestHelper
//           .getData('GetDataXeThaPham/GetDuLieuXe?keyword=$qrcode');

//       if (response.statusCode == 200) {
//         var decodedData = jsonDecode(response.body);
//         print("data2: ${decodedData}");
//         if (decodedData != null) {
//           List<HuKien> huKienList = [];
//           if (decodedData['phuKien'] != null &&
//               decodedData['phuKien'] is List) {
//             huKienList = (decodedData['phuKien'] as List<dynamic>)
//                 .map((item) => HuKien.fromJson(item))
//                 .toList();
//           }
//           print("phu kien: ${decodedData['phuKien']}");
//           _data = DataModel(
//             id: decodedData['id'],
//             soKhung: decodedData['soKhung'],
//             maSanPham: decodedData['maSanPham'],
//             tenSanPham: decodedData['tenSanPham'],
//             soMay: decodedData['soMay'],
//             maMau: decodedData['maMau'],
//             tenMau: decodedData['tenMau'],
//             tenKho: decodedData['tenKho'],
//             maViTri: decodedData['maViTri'],
//             tenViTri: decodedData['tenViTri'],
//             mauSon: decodedData['mauSon'],
//             ngayXuatKhoView: decodedData['ngayXuatKhoView'],
//             tenTaiXe: decodedData['tenTaiXe'],
//             ghiChu: decodedData['ghiChu'],
//             Kho_Id: decodedData['Kho_Id'],
//             BaiXe_Id: decodedData['BaiXe_Id'],
//             viTri_Id: decodedData['viTri_Id'],
//             // phuKien: (decodedData['phuKien'] as List<dynamic>)
//             //     .map((item) => HuKien.fromJson(item))
//             //     .toList(),
//           );
//         } else {
//           _showErrorDialog(context, "Xe đã nhận rồi, vui lòng kiểm tra lại");
//         }
//       } else {
//         _showErrorDialog(context, response.body.replaceAll('"', ''));
//       }
//     } catch (e) {
//       _hasError = true;
//       _errorCode = e.toString();
//     }
//   }

//   void _showErrorDialog(BuildContext context, String errorMessage) {
//     QuickAlert.show(
//       context: context,
//       type: QuickAlertType.info,
//       title: '',
//       text: errorMessage,
//       confirmBtnText: 'Đồng ý',
//     );
//     _scan = null;
//     _isLoading = false;
//   }

//   Future clearData() async {
//     _scan = null;
//     notifyListeners();
//   }
// }

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Thilogi/models/scan.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:quickalert/quickalert.dart';

import '../models/getdata.dart';

class ScanBloc extends ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  ScanModel? _scan;
  ScanModel? get scan => _scan;
  DataModel? _data;
  DataModel? get data => _data;
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

  var headers = {
    'ApiKey': 'thilogi2024',
  };
  Future<void> get(BuildContext context, String qrcode) async {
    _data = null;
    _scan = null;
    _isLoading = true;
    try {
      final http.Response response = await requestHelper.getData('GetDataXeThaPham/GetDuLieuXe_New?keyword=$qrcode');

      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("data2: ${decodedData}");
        if (decodedData != null) {
          List<HuKien> huKienList = [];
          if (decodedData['phukien'] != null && decodedData['phukien'] is List) {
            huKienList = (decodedData['phukien'] as List<dynamic>).map((item) => HuKien.fromJson(item)).toList();
          }
          print("phu kien: ${decodedData['phukien']}");
          _data = DataModel(
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
            ngayXuatKhoView: decodedData['ngayXuatKhoView'],
            tenTaiXe: decodedData['tenTaiXe'],
            ghiChu: decodedData['ghiChu'],
            Kho_Id: decodedData['Kho_Id'],
            BaiXe_Id: decodedData['BaiXe_Id'],
            viTri_Id: decodedData['viTri_Id'],
            // phuKien: (decodedData['phuKien'] as List<dynamic>)
            //     .map((item) => HuKien.fromJson(item))
            //     .toList(),
            phukien: huKienList,
          );
        }
      } else {
        String errorMessage = response.body.replaceAll('"', '');
        notifyListeners();
        if (errorMessage.isEmpty) {
          errorMessage = "Số khung ${qrcode}  không có thông tin, vui lòng kiểm tra lại!";
        }
        QuickAlert.show(
          // ignore: use_build_context_synchronously
          context: context,
          type: QuickAlertType.info,
          title: '',
          text: errorMessage,
          confirmBtnText: 'Đồng ý',
        );
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Future<void> getData(BuildContext context, String qrcode) async {
    // _scan = null;
    // _data = null;
    // _isLoading = true;
    try {
      // final http.Response response = await requestHelper
      //     .getData('GetDataXeThaPham/GetDuLieuXe?SoKhung=$qrcode');

      final response = await http.get(
        Uri.parse("https://qtsxauto-wms.thacochulai.vn/api/KhoThanhPham/TraCuuXeThanhPham_Thilogi1?SoKhung=$qrcode"),
        headers: headers,
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("data: ${decodedData}");
        if (decodedData != null) {
          List<PhuKien> phuKienList = [];
          if (decodedData['phuKien'] != null && decodedData['phuKien'] is List) {
            phuKienList = (decodedData['phuKien'] as List<dynamic>).map((item) => PhuKien.fromJson(item)).toList();
          }
          _scan = ScanModel(
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
            ngayXuatKhoView: decodedData['ngayXuatKhoView'],
            tenTaiXe: decodedData['tenTaiXe'],
            ghiChu: decodedData['ghiChu'],
            Kho_Id: decodedData['Kho_Id'],
            BaiXe_Id: decodedData['BaiXe_Id'],
            viTri_Id: decodedData['viTri_Id'],
            // phuKien: (decodedData['phuKien'] as List<dynamic>)
            //     .map((item) => PhuKien.fromJson(item))
            //     .toList(),
            phuKien: phuKienList,
          );
        } else {
          _showErrorDialog(context, "Xe đã nhận rồi, vui lòng kiểm tra lại");
        }
      } else {
        // _showErrorDialog(context, response.body.replaceAll('"', ''));
        String errorMessage = response.body.replaceAll('"', '');
        notifyListeners();
        if (errorMessage.isEmpty) {
          errorMessage = "Số khung ${qrcode}  không có thông tin, vui lòng kiểm tra lại!";
        }
        QuickAlert.show(
          // ignore: use_build_context_synchronously
          context: context,
          type: QuickAlertType.info,
          title: '',
          text: errorMessage,
          confirmBtnText: 'Đồng ý',
        );
        // _showErrorDialog(context,
        //     "Số khung ${qrcode}  không có thông tin, vui lòng kiểm tra lại!");
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _hasError = true;

      _errorCode = e.toString();
      notifyListeners();
    }
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.info,
      title: '',
      text: errorMessage,
      confirmBtnText: 'Đồng ý',
    );
    _scan = null;
    _isLoading = false;
  }

  Future clearData() async {
    _scan = null;
    notifyListeners();
  }
}
