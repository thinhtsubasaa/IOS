// import 'dart:convert';
// import 'package:Thilogi/models/lsxequa.dart';
// import 'package:Thilogi/models/tinhtrangdonhang.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:Thilogi/services/request_helper.dart';
// import 'package:quickalert/quickalert.dart';

// import '../models/lsgiaoxe.dart';
// import '../models/lsnhapbai.dart';
// import '../models/lsxuatxe.dart';

// class TrackingBloc extends ChangeNotifier {
//   static RequestHelper requestHelper = RequestHelper();

//   List<LSXeQuaModel>? _lsxequa;
//   List<LSXeQuaModel>? get lsxequa => _lsxequa;
//   List<LSNhapBaiModel>? _lsnhapbai;
//   List<LSNhapBaiModel>? get lsnhapbai => _lsnhapbai;
//   List<LSXuatXeModel>? _lsxuatxe;
//   List<LSXuatXeModel>? get lsxuatxe => _lsxuatxe;
//   List<LSGiaoXeModel>? _lsgiaoxe;
//   List<LSGiaoXeModel>? get lsgiaoxe => _lsgiaoxe;
//   TinhTrangDonHangModel? _tinhtrangdh;
//   TinhTrangDonHangModel? get tinhtrangdh => _tinhtrangdh;

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

//   Future<void> getTrackingXe(BuildContext context, String soKhung) async {
//     _isLoading = true;
//     _lsxequa = null;
//     _lsnhapbai = null;
//     _lsxuatxe = null;
//     _lsgiaoxe = null;
//     try {
//       final http.Response response = await requestHelper
//           .getData('KhoThanhPham/TraCuuXeThongTinXe?SoKhung=$soKhung');
//       if (response.statusCode == 200) {
//         var decodedData = jsonDecode(response.body);
//         print("data: ${decodedData}");
//         if (decodedData != null) {
//           var data = decodedData['data'];
//           var lsxequaData = decodedData['lichsuxequathilogi'];
//           var lsnNhapbaiData = decodedData['lichsuluanchuyen'];
//           var lsxuatxeData = decodedData['lichsuxuatxelist'];
//           var lsgiaoxeData = decodedData['lichsuGiaoxelist'];
//           var tinhtrang = decodedData['tinhtrangdonhang'];

//           try {
//             if (lsxequaData != null && lsxequaData.isNotEmpty) {
//               List<dynamic> lsXeQuaDataList = lsxequaData;

//               // Tạo danh sách để lưu trữ các thông tin xe qua
//               List<LSXeQuaModel> lsXeQuaList = [];

//               // Duyệt qua từng phần tử trong danh sách và thêm vào danh sách kết quả
//               lsXeQuaDataList.forEach((lsXeQuaData) {
//                 LSXeQuaModel xeQuaModel = LSXeQuaModel(
//                   id: lsXeQuaData['id'],
//                   ngayNhan: lsXeQuaData['ngayNhan'],
//                   nguoiNhan: lsXeQuaData['nguoiNhan'],
//                   noiNhan: lsXeQuaData['noiNhan'],
//                   toaDo: lsXeQuaData['toaDo'],
//                 );
//                 lsXeQuaList.add(xeQuaModel);
//               });

//               // Lưu danh sách thông tin xe qua vào biến _lsxequa
//               _lsxequa = lsXeQuaList;
//               print("Processed lsxequaData");
//             }
//           } catch (e) {
//             print("Error processing lsxequaData: $e");
//           }
//           try {
//             if (lsnNhapbaiData != null && lsnNhapbaiData.isNotEmpty) {
//               List<dynamic> lsNhapBaiDataList = lsnNhapbaiData;

//               // Tạo danh sách để lưu trữ các thông tin xe qua
//               List<LSNhapBaiModel> lsNhapBaiList = [];
//               lsNhapBaiDataList.forEach((lsNhapBaiData) {
//                 LSNhapBaiModel nhapBaiModel = LSNhapBaiModel(
//                   id: lsNhapBaiData['id'],
//                   kho: lsNhapBaiData['kho'],
//                   baiXe: lsNhapBaiData['baiXe'],
//                   thoiGianVao: lsNhapBaiData['thoiGianVao'],
//                   thoiGianRa: lsNhapBaiData['thoiGianRa'],
//                   soNgay: lsNhapBaiData['soNgay'].toString(),
//                   ngayVao: lsNhapBaiData['ngayVao'],
//                   ngayRa: lsNhapBaiData['ngayRa'],
//                   toaDo: lsNhapBaiData['toaDo'],
//                   nguoiNhapBai: lsNhapBaiData['nguoiNhapBai'],
//                   viTri: lsNhapBaiData['viTri'],
//                 );

//                 lsNhapBaiList.add(nhapBaiModel);
//               });

//               // Lưu danh sách thông tin xe qua vào biến _lsxequa
//               _lsnhapbai = lsNhapBaiList;
//               print("Processed lsnNhapbaiData");
//             }
//           } catch (e) {
//             print("Error processing lsnNhapbaiData: $e");
//           }
//           if (lsxuatxeData != null && lsxuatxeData.isNotEmpty) {
//             List<dynamic> lsXuatXeDataList = lsxuatxeData;

//             // Tạo danh sách để lưu trữ các thông tin xe qua
//             List<LSXuatXeModel> lsXuatXeList = [];
//             lsXuatXeDataList.forEach((lsXuatXeData) {
//               LSXuatXeModel xuatXeModel = LSXuatXeModel(
//                 id: lsXuatXeData['id'],
//                 ngay: lsXuatXeData['ngay'],
//                 thongTinChiTiet: lsXuatXeData['thongTinChiTiet'],
//                 thongtinvanchuyen: lsXuatXeData['thongtinvanchuyen'],
//                 thongtinMap: lsXuatXeData['thongtinMap'],
//                 toaDo: lsXuatXeData['toaDo'],
//                 nguoiPhuTrach: lsXuatXeData['nguoiPhuTrach'],
//               );
//               lsXuatXeList.add(xuatXeModel);
//             });

//             // Lưu danh sách thông tin xe qua vào biến _lsxequa
//             _lsxuatxe = lsXuatXeList;
//           }
//           if (lsgiaoxeData != null && lsgiaoxeData.isNotEmpty) {
//             List<dynamic> lsGiaoXeDataList = lsgiaoxeData;

//             // Tạo danh sách để lưu trữ các thông tin xe qua
//             List<LSGiaoXeModel> lsGiaoXeList = [];
//             lsGiaoXeDataList.forEach((lsGiaoXeData) {
//               LSGiaoXeModel giaoXeModel = LSGiaoXeModel(
//                 id: lsGiaoXeData['id'],
//                 noiGiao: lsGiaoXeData['noiGiao'],
//                 soTBGX: lsGiaoXeData['soTBGX'],
//                 ngay: lsGiaoXeData['ngay'],
//                 toaDo: lsGiaoXeData['toaDo'],
//                 nguoiPhuTrach: lsGiaoXeData['nguoiPhuTrach'],
//               );
//               lsGiaoXeList.add(giaoXeModel);
//             });

//             // Lưu danh sách thông tin xe qua vào biến _lsxequa
//             _lsgiaoxe = lsGiaoXeList;
//           }
//           if (tinhtrang != null && tinhtrang.isNotEmpty) {
//             TinhTrangDonHangModel tinhTrangModel = TinhTrangDonHangModel(
//               id: tinhtrang['id'],
//               isNhanXe: tinhtrang['isNhanXe'],
//               isNhapKho: tinhtrang['isNhapKho'],
//               isXuatKho: tinhtrang['isXuatKho'],
//               isDaGiao: tinhtrang['isDaGiao'],
//               toaDo: tinhtrang['toaDo'],
//             );

//             // Lưu thông tin đơn hàng vào biến _tinhtrangdh
//             _tinhtrangdh = tinhTrangModel;
//           }
//         }
//       } else {
//         String errorMessage = response.body.replaceAll('"', '');
//         notifyListeners();
//         if (errorMessage.isEmpty) {
//           errorMessage = "Không có dữ liệu";
//         }
//         QuickAlert.show(
//           // ignore: use_build_context_synchronously
//           context: context,
//           type: QuickAlertType.info,
//           title: '',
//           text: errorMessage,
//           confirmBtnText: 'Đồng ý',
//         );
//         _lsxequa = null;
//         _lsnhapbai = null;
//         _lsxuatxe = null;
//         _lsgiaoxe = null;
//         _isLoading = false;
//       }

//       notifyListeners();
//     } catch (e) {
//       _hasError = true;
//       _errorCode = e.toString();
//       notifyListeners();
//     }
//   }
// }

import 'dart:convert';
import 'package:Thilogi/models/lsxequa.dart';
import 'package:Thilogi/models/tinhtrangdonhang.dart';
import 'package:Thilogi/models/tracking_chuyentiep.dart';
import 'package:Thilogi/models/tracking_xuatxe.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Thilogi/services/request_helper.dart';
import 'package:quickalert/quickalert.dart';

import '../models/lsgiaoxe.dart';
import '../models/lsnhapbai.dart';
import '../models/lsxuatxe.dart';

class TrackingBloc extends ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  List<LSXeQuaModel>? _lsxequa;
  List<LSXeQuaModel>? get lsxequa => _lsxequa;
  List<LSNhapBaiModel>? _lsnhapbai;
  List<LSNhapBaiModel>? get lsnhapbai => _lsnhapbai;
  List<LSXuatXeModel>? _lsxuatxe;
  List<LSXuatXeModel>? get lsxuatxe => _lsxuatxe;
  List<LSGiaoXeModel>? _lsgiaoxe;
  List<LSGiaoXeModel>? get lsgiaoxe => _lsgiaoxe;
  List<TrackingChuyenTiepModel>? _trackingchuyentiep;
  List<TrackingChuyenTiepModel>? get trackingchuyentiep => _trackingchuyentiep;
  List<TrackingXuatXeModel>? _trackingxuatxe;
  List<TrackingXuatXeModel>? get trackingxuatxe => _trackingxuatxe;
  TinhTrangDonHangModel? _tinhtrangdh;
  TinhTrangDonHangModel? get tinhtrangdh => _tinhtrangdh;

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

  Future<void> getTrackingXe(BuildContext context, String soKhung) async {
    _isLoading = true;
    _lsxequa = null;
    _lsnhapbai = null;
    _lsxuatxe = null;
    _lsgiaoxe = null;
    _trackingchuyentiep = null;
    _trackingxuatxe = null;
    try {
      final http.Response response = await requestHelper
          .getData('KhoThanhPham/TraCuuXeThongTinXe?SoKhung=$soKhung');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("data: ${decodedData}");
        if (decodedData != null) {
          var data = decodedData['data'];
          var lsxequaData = decodedData['lichsuxequathilogi'];
          var lsnNhapbaiData = decodedData['lichsuluanchuyen'];
          var lsxuatxeData = decodedData['lichsuxuatxelist'];
          var lsgiaoxeData = decodedData['lichsuGiaoxelist'];
          var trackingchuyentiepData = decodedData['lichsuchuyentiep'];
          var trackingxuatxeData = decodedData['lichsuxuatxechuyentieplist'];
          var tinhtrang = decodedData['tinhtrangdonhang'];

          try {
            if (lsxequaData != null && lsxequaData.isNotEmpty) {
              List<dynamic> lsXeQuaDataList = lsxequaData;

              // Tạo danh sách để lưu trữ các thông tin xe qua
              List<LSXeQuaModel> lsXeQuaList = [];

              // Duyệt qua từng phần tử trong danh sách và thêm vào danh sách kết quả
              lsXeQuaDataList.forEach((lsXeQuaData) {
                LSXeQuaModel xeQuaModel = LSXeQuaModel(
                  id: lsXeQuaData['id'],
                  ngayNhan: lsXeQuaData['ngayNhan'],
                  nguoiNhan: lsXeQuaData['nguoiNhan'],
                  noiNhan: lsXeQuaData['noiNhan'],
                  toaDo: lsXeQuaData['toaDo'],
                );
                lsXeQuaList.add(xeQuaModel);
              });

              // Lưu danh sách thông tin xe qua vào biến _lsxequa
              _lsxequa = lsXeQuaList;
              print("Processed lsxequaData");
            }
          } catch (e) {
            print("Error processing lsxequaData: $e");
          }
          try {
            if (lsnNhapbaiData != null && lsnNhapbaiData.isNotEmpty) {
              List<dynamic> lsNhapBaiDataList = lsnNhapbaiData;

              // Tạo danh sách để lưu trữ các thông tin xe qua
              List<LSNhapBaiModel> lsNhapBaiList = [];
              lsNhapBaiDataList.forEach((lsNhapBaiData) {
                LSNhapBaiModel nhapBaiModel = LSNhapBaiModel(
                  id: lsNhapBaiData['id'],
                  kho: lsNhapBaiData['kho'],
                  baiXe: lsNhapBaiData['baiXe'],
                  thoiGianVao: lsNhapBaiData['thoiGianVao'],
                  thoiGianRa: lsNhapBaiData['thoiGianRa'],
                  soNgay: lsNhapBaiData['soNgay'].toString(),
                  ngayVao: lsNhapBaiData['ngayVao'],
                  ngayRa: lsNhapBaiData['ngayRa'],
                  toaDo: lsNhapBaiData['toaDo'],
                  nguoiNhapBai: lsNhapBaiData['nguoiNhapBai'],
                  viTri: lsNhapBaiData['viTri'],
                );

                lsNhapBaiList.add(nhapBaiModel);
              });

              // Lưu danh sách thông tin xe qua vào biến _lsxequa
              _lsnhapbai = lsNhapBaiList;
              print("Processed lsnNhapbaiData");
            }
          } catch (e) {
            print("Error processing lsnNhapbaiData: $e");
          }
          try {
            if (trackingchuyentiepData != null &&
                trackingchuyentiepData.isNotEmpty) {
              List<dynamic> trackingChuyenTiepDataList = trackingchuyentiepData;

              // Tạo danh sách để lưu trữ các thông tin xe qua
              List<TrackingChuyenTiepModel> trackingChuyenTiepList = [];
              trackingChuyenTiepDataList.forEach((trackingChuyenTiepData) {
                TrackingChuyenTiepModel chuyenTiepModel =
                    TrackingChuyenTiepModel(
                  id: trackingChuyenTiepData['id'],
                  kho: trackingChuyenTiepData['kho'],
                  baiXe: trackingChuyenTiepData['baiXe'],
                  thoiGianVao: trackingChuyenTiepData['thoiGianVao'],
                  thoiGianRa: trackingChuyenTiepData['thoiGianRa'],
                  soNgay: trackingChuyenTiepData['soNgay'].toString(),
                  ngayVao: trackingChuyenTiepData['ngayVao'],
                  ngayRa: trackingChuyenTiepData['ngayRa'],
                  toaDo: trackingChuyenTiepData['toaDo'],
                  nguoiNhapBai: trackingChuyenTiepData['nguoiNhapBai'],
                  viTri: trackingChuyenTiepData['viTri'],
                );

                trackingChuyenTiepList.add(chuyenTiepModel);
              });

              // Lưu danh sách thông tin xe qua vào biến _lsxequa
              _trackingchuyentiep = trackingChuyenTiepList;
              print("Processed  trackingChuyenTiepList");
            }
          } catch (e) {
            print("Error processing  trackingChuyenTiepList: $e");
          }
          if (lsxuatxeData != null && lsxuatxeData.isNotEmpty) {
            List<dynamic> lsXuatXeDataList = lsxuatxeData;

            // Tạo danh sách để lưu trữ các thông tin xe qua
            List<LSXuatXeModel> lsXuatXeList = [];
            lsXuatXeDataList.forEach((lsXuatXeData) {
              LSXuatXeModel xuatXeModel = LSXuatXeModel(
                id: lsXuatXeData['id'],
                ngay: lsXuatXeData['ngay'],
                thongTinChiTiet: lsXuatXeData['thongTinChiTiet'],
                thongtinvanchuyen: lsXuatXeData['thongtinvanchuyen'],
                thongtinMap: lsXuatXeData['thongtinMap'],
                toaDo: lsXuatXeData['toaDo'],
                nguoiPhuTrach: lsXuatXeData['nguoiPhuTrach'],
              );
              lsXuatXeList.add(xuatXeModel);
            });
            // Lưu danh sách thông tin xe qua vào biến _lsxequa
            _lsxuatxe = lsXuatXeList;
          }
          if (trackingxuatxeData != null && trackingxuatxeData.isNotEmpty) {
            List<dynamic> trackingXuatXeDataList = trackingxuatxeData;

            // Tạo danh sách để lưu trữ các thông tin xe qua
            List<TrackingXuatXeModel> trackingXuatXeList = [];
            trackingXuatXeDataList.forEach((trackingXuatXeData) {
              TrackingXuatXeModel trackingXuatXeModel = TrackingXuatXeModel(
                id: trackingXuatXeData['id'],
                ngay: trackingXuatXeData['ngay'],
                thongTinChiTiet: trackingXuatXeData['thongTinChiTiet'],
                thongtinvanchuyen: trackingXuatXeData['thongtinvanchuyen'],
                thongtinMap: trackingXuatXeData['thongtinMap'],
                toaDo: trackingXuatXeData['toaDo'],
                nguoiPhuTrach: trackingXuatXeData['nguoiPhuTrach'],
              );
              trackingXuatXeList.add(trackingXuatXeModel);
            });
            // Lưu danh sách thông tin xe qua vào biến _lsxequa
            _trackingxuatxe = trackingXuatXeList;
          }
          if (lsgiaoxeData != null && lsgiaoxeData.isNotEmpty) {
            List<dynamic> lsGiaoXeDataList = lsgiaoxeData;

            // Tạo danh sách để lưu trữ các thông tin xe qua
            List<LSGiaoXeModel> lsGiaoXeList = [];
            lsGiaoXeDataList.forEach((lsGiaoXeData) {
              LSGiaoXeModel giaoXeModel = LSGiaoXeModel(
                id: lsGiaoXeData['id'],
                noiGiao: lsGiaoXeData['noiGiao'],
                soTBGX: lsGiaoXeData['soTBGX'],
                ngay: lsGiaoXeData['ngay'],
                toaDo: lsGiaoXeData['toaDo'],
                nguoiPhuTrach: lsGiaoXeData['nguoiPhuTrach'],
              );
              lsGiaoXeList.add(giaoXeModel);
            });

            // Lưu danh sách thông tin xe qua vào biến _lsxequa
            _lsgiaoxe = lsGiaoXeList;
          }
          if (tinhtrang != null && tinhtrang.isNotEmpty) {
            TinhTrangDonHangModel tinhTrangModel = TinhTrangDonHangModel(
              id: tinhtrang['id'],
              isNhanXe: tinhtrang['isNhanXe'],
              isNhapKho: tinhtrang['isNhapKho'],
              isXuatKho: tinhtrang['isXuatKho'],
              isDaGiao: tinhtrang['isDaGiao'],
              toaDo: tinhtrang['toaDo'],
            );

            // Lưu thông tin đơn hàng vào biến _tinhtrangdh
            _tinhtrangdh = tinhTrangModel;
          }
        }
      } else {
        String errorMessage = response.body.replaceAll('"', '');
        notifyListeners();
        if (errorMessage.isEmpty) {
          errorMessage = "Không có dữ liệu";
        }
        QuickAlert.show(
          // ignore: use_build_context_synchronously
          context: context,
          type: QuickAlertType.info,
          title: '',
          text: errorMessage,
          confirmBtnText: 'Đồng ý',
        );
        _lsxequa = null;
        _lsnhapbai = null;
        _lsxuatxe = null;
        _lsgiaoxe = null;
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
