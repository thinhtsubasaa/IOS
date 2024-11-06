import 'dart:async';

import 'package:Thilogi/models/tinhtrangdonhang.dart';
import 'package:Thilogi/models/tracking_chuyentiep.dart';
import 'package:Thilogi/models/tracking_xuatxe.dart';
import 'package:Thilogi/pages/tracking/custom_body_trackingxe.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/config/config.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutter_datawedge/models/scan_result.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:sizer/sizer.dart';

import '../../blocs/TrackingXe.dart';
import '../../models/lsgiaoxe.dart';
import '../../models/lsnhapbai.dart';
import '../../models/lsxequa.dart';
import '../../models/lsxuatxe.dart';
import '../../widgets/custom_title.dart';
import '../../widgets/loading.dart';

class TrackingXeVitriPage extends StatefulWidget {
  const TrackingXeVitriPage({super.key});

  @override
  State<TrackingXeVitriPage> createState() => _TrackingXeVitriPageState();
}

class _TrackingXeVitriPageState extends State<TrackingXeVitriPage> with SingleTickerProviderStateMixin, ChangeNotifier {
  TabController? _tabController;

  late TrackingBloc _bl;
  late FlutterDataWedge dataWedge;

  String? barcodeScanResult;
  String _qrData = '';
  final _qrDataController = TextEditingController();
  bool _loading = false;
  List<LSXeQuaModel>? _xequa;
  List<LSXeQuaModel>? get xequa => _xequa;
  List<LSNhapBaiModel>? _nhapbai;
  List<LSNhapBaiModel>? get nhapbai => _nhapbai;
  List<LSXuatXeModel>? _xuatxe;
  List<LSXuatXeModel>? get xuatxe => _xuatxe;
  List<LSGiaoXeModel>? _giaoxe;
  List<LSGiaoXeModel>? get giaoxe => _giaoxe;
  List<TrackingChuyenTiepModel>? _trackingchuyentiep;
  List<TrackingChuyenTiepModel>? get trackingchuyentiep => _trackingchuyentiep;
  List<TrackingXuatXeModel>? _trackingxuatxe;
  List<TrackingXuatXeModel>? get trackingxuatxe => _trackingxuatxe;
  TinhTrangDonHangModel? _tinhtrang;
  TinhTrangDonHangModel? get tinhtrang => _tinhtrang;
  late StreamSubscription<ScanResult> scanSubscription;
  Completer<GoogleMapController> _googleMapController = Completer();
  CameraPosition? _cameraPosition;
  Location? _location;
  LocationData? _currentLocation;
  Set<Marker> _markers = {};
  MapType _currentMapType = MapType.normal;
  String? previousKho;
  List<CombinedItem> combinedItems = [];
  @override
  void initState() {
    super.initState();
    _init();
    _bl = Provider.of<TrackingBloc>(context, listen: false);
    _tabController = TabController(vsync: this, length: 2);
    _tabController!.addListener(_handleTabChange);
    dataWedge = FlutterDataWedge(profileName: "Example Profile");
    scanSubscription = dataWedge.onScanResult.listen((ScanResult result) {
      setState(() {
        barcodeScanResult = result.data;
      });
      print(barcodeScanResult);
      _handleBarcodeScanResult(barcodeScanResult ?? "");
    });
  }

  _init() async {
    _loading = true;
    _location = Location();
    _currentLocation = await _location?.getLocation();
    LatLng initialPosition;
    if (_currentLocation != null) {
      initialPosition = LatLng(
        _currentLocation?.latitude ?? 0,
        _currentLocation?.longitude ?? 0,
      );

      _cameraPosition = CameraPosition(
        target: initialPosition,
        zoom: 15,
      );
      _loading = false;
      _moveToPosition(_cameraPosition!.target);
      _addMarker(_cameraPosition!.target);
    }
    // _initLocation();
    // Thêm marker cho vị trí ban đầu
  }

  void _toggleMapType() {
    setState(() {
      if (_currentMapType == MapType.normal) {
        _currentMapType = MapType.satellite;
      } else {
        _currentMapType = MapType.normal;
      }
    });
  }

  void addItemToList(DateTime? dateTime, Widget customImage, String textLine) {
    combinedItems.add(CombinedItem(dateTime: dateTime, customImage: customImage, textLine: textLine));
  }

  _moveToPosition(LatLng latLng) async {
    _cameraPosition = CameraPosition(
      target: latLng,
      zoom: 15,
    );
    _updateMarkerPosition(latLng);
  }

  _addMarker(LatLng latLng) {
    final Marker marker = Marker(
      markerId: MarkerId('current_position'),
      position: latLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    if (mounted) {
      setState(() {
        _markers.add(marker);
      });
    }
  }

  _updateMarkerPosition(LatLng latLng) {
    if (mounted) {
      setState(() {
        _markers.clear();
        _addMarker(latLng);
      });
    }
  }

  Widget _buildMapToggle() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: FloatingActionButton(
          onPressed: _toggleMapType,
          materialTapTargetSize: MaterialTapTargetSize.padded,
          backgroundColor: Colors.red,
          child: const Icon(Icons.map),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return _getMap();
  }

  Widget _getMap() {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: _cameraPosition!,
          mapType: _currentMapType,
          onMapCreated: (GoogleMapController controller) {
            if (!_googleMapController.isCompleted) {
              _googleMapController.complete(controller);
            }
          },
          markers: _markers,
        ),
        _buildMapToggle(),
      ],
    );
  }

  LatLng convertToLatLng(String coordinates) {
    try {
      final parts = coordinates.split(',');
      if (parts.length == 2) {
        final latitude = double.parse(parts[0]);
        final longitude = double.parse(parts[1]);
        print(LatLng(latitude, longitude));
        return LatLng(latitude, longitude);
      } else {
        throw FormatException('Invalid coordinate format');
      }
    } catch (e) {
      throw FormatException('Error parsing coordinates: $e');
    }
  }

  void _handleTabChange() {
    if (_tabController!.indexIsChanging) {}
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Widget CardVin() {
    return Container(
      width: MediaQuery.of(context).size.width < 330 ? 100.w : 90.w,
      height: MediaQuery.of(context).size.height < 880 ? 8.h : 8.h,
      margin: const EdgeInsets.only(top: 3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF818180),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 20.w,
            height: 10.h,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5),
                bottomLeft: Radius.circular(5),
              ),
              color: AppConfig.primaryColor,
            ),
            child: const Center(
              child: Text(
                'Số khung\n(VIN)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                controller: _qrDataController,
                decoration: const InputDecoration(
                  hintText: 'Nhập hoặc quét mã VIN',
                ),
                onSubmitted: (value) {
                  _handleBarcodeScanResult(value);
                },
                style: const TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppConfig.primaryColor,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            color: Colors.black,
            onPressed: () async {
              String result = await FlutterBarcodeScanner.scanBarcode(
                '#A71C20',
                'Cancel',
                false,
                ScanMode.QR,
              );
              setState(() {
                barcodeScanResult = result;
                _qrDataController.text = result;
              });
              print(barcodeScanResult);
              _handleBarcodeScanResult(barcodeScanResult ?? "");
            },
          ),
        ],
      ),
    );
  }

  void _handleBarcodeScanResult(String barcodeScanResult) {
    print('ab:$barcodeScanResult');

    setState(() {
      _qrData = '';
      _qrDataController.text = barcodeScanResult;
      _xequa = null;
      _nhapbai = null;
      _xuatxe = null;
      _giaoxe = null;
      _trackingchuyentiep = null;
      _trackingxuatxe = null;
      Future.delayed(const Duration(seconds: 0), () {
        _qrData = barcodeScanResult;
        _qrDataController.text = barcodeScanResult;
        _onScan(barcodeScanResult);
      });
    });
  }

  String formatDateTime(String dateTimeString) {
    // Parse chuỗi ngày tháng thành đối tượng DateTime
    DateTime dateTime = DateTime.parse(dateTimeString);
    // Định dạng lại đối tượng DateTime thành chuỗi với định dạng mong muốn
    String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    return formattedDate;
  }

  _onScan(value) {
    setState(() {
      _loading = true;
    });
    _bl.getTrackingXe(context, value).then((_) {
      setState(() {
        _qrData = value;
        if (_bl.lsxequa == null && _bl.lsnhapbai == null && _bl.lsxuatxe == null && _bl.lsgiaoxe == null && _bl.trackingchuyentiep == null && _bl.trackingxuatxe == null) {
          // QuickAlert.show(
          //   // ignore: use_build_context_synchronously
          //   context: context,
          //   type: QuickAlertType.info,
          //   title: '',
          //   text: 'Không có dữ liệu',
          //   confirmBtnText: 'Đồng ý',
          // );
          _moveToPosition(LatLng(0, 0));
          _loading = false;
          barcodeScanResult = null;
          _qrData = '';
          _qrDataController.text = '';
        } else {
          _loading = false;
          _xequa = _bl.lsxequa;
          _nhapbai = _bl.lsnhapbai;
          _xuatxe = _bl.lsxuatxe;
          _giaoxe = _bl.lsgiaoxe;
          _trackingchuyentiep = _bl.trackingchuyentiep;
          _trackingxuatxe = _bl.trackingxuatxe;
          _tinhtrang = _bl.tinhtrangdh;
          if (_tinhtrang?.toaDo == null) {
            QuickAlert.show(
              // ignore: use_build_context_synchronously
              context: context,
              type: QuickAlertType.info,
              title: '',
              text: 'Xe chưa có vị trí tọa độ trên bản đồ',
              confirmBtnText: 'Đồng ý',
            );
            _moveToPosition(LatLng(0, 0));
          }
          _moveToPosition(convertToLatLng(_tinhtrang?.toaDo ?? ""));
          print('1:$_xequa');
          print('2:$_nhapbai');
          print('3:$_xuatxe');
          print('4:$_giaoxe');
          print('5:$_trackingchuyentiep');
          print('6:$_trackingxuatxe');
          print('7:$_tinhtrang');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _xuatxe?.sort((a, b) => DateTime.parse(b.ngay ?? "").compareTo(DateTime.parse(a.ngay ?? "")));
    _trackingxuatxe?.sort((a, b) => DateTime.parse(b.ngay ?? "").compareTo(DateTime.parse(a.ngay ?? "")));
    _nhapbai?.sort((a, b) => DateTime.parse(b.ngayVao ?? "").compareTo(DateTime.parse(a.ngayVao ?? "")));
    _trackingchuyentiep?.sort((a, b) => DateTime.parse(b.ngayVao ?? "").compareTo(DateTime.parse(a.ngayVao ?? "")));
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              AppConfig.QLKhoImagePath,
              width: 70.w,
            ),
            // Container(
            //   child: Text(
            //     'TCT VẬN TẢI ĐƯỜNG BỘ THILOGI',
            //     textAlign: TextAlign.center,
            //     style: TextStyle(
            //       fontFamily: 'Roboto',
            //       fontSize: 14.sp,
            //       fontWeight: FontWeight.w700,
            //       color: Color(0xFFBC2925),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: MediaQuery.of(context).size.height < 600 ? 23.h : 18.h),
                  padding: EdgeInsets.only(left: 10, right: 10),
                  width: 100.w,
                  decoration: const BoxDecoration(
                      // image: DecorationImage(
                      //   image: AssetImage(AppConfig.backgroundImagePath),
                      //   fit: BoxFit.cover,
                      // ),
                      ),
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: _tabController,
                    children: [
                      SingleChildScrollView(
                        child: Container(
                          width: 100.w,
                          alignment: Alignment.bottomCenter,
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height < 600 ? MediaQuery.of(context).size.height * 1.65 : MediaQuery.of(context).size.height * 0.95,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                            border: Border.all(
                              color: Color(0xFFCCCCCC),
                              width: 1,
                            ),
                            color: Colors.white,
                          ),
                          child: Stack(
                            children: [
                              // Phần Text 1
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: 15.w,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    ),
                                    color: Color(0xFFF6C6C7),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 0, bottom: 0),
                                    child: Image.asset(
                                      'assets/images/road.png',
                                      height: MediaQuery.of(context).size.height < 600 ? MediaQuery.of(context).size.height * 1.62 : MediaQuery.of(context).size.height * 0.92,
                                    ),
                                  ),
                                ),
                              ),
                              // Your BodyTrackingXe widget goes here
                              Positioned(
                                left: 0,
                                top: 0,
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      if (_giaoxe != null)
                                        Column(
                                          children: _giaoxe!.map((item) {
                                            return buildRowItem(
                                              customImage: CustomImage1(),
                                              textLine:
                                                  (item.ngay != null ? formatDateTime(item.ngay ?? "") : "") + '\n' + (item.noiGiao ?? "") + '\n' + 'Số TBGX: ' + (item.soTBGX ?? "") + '\n' + (item.nguoiPhuTrach ?? ""),
                                            );
                                          }).toList(),
                                        ),
                                      // if (_xuatxe != null)
                                      //   Column(
                                      //     children: _xuatxe!.map((item) {
                                      //       return buildRowItem(
                                      //         customImage: CustomImage2(),
                                      //         textLine: (item.ngay != null
                                      //                 ? formatDateTime(
                                      //                     item.ngay ?? "")
                                      //                 : "") +
                                      //             '\n' +
                                      //             (item.thongTinChiTiet !=
                                      //                     null
                                      //                 ? ('${(item.thongTinChiTiet ?? "")}')
                                      //                 : "") +
                                      //             '\n' +
                                      //             (item.thongtinvanchuyen !=
                                      //                     null
                                      //                 ? ('${(item.thongtinvanchuyen ?? "")}')
                                      //                 : "") +
                                      //             '\n' +
                                      //             (item.nguoiPhuTrach ?? ""),
                                      //       );
                                      //     }).toList(),
                                      //   ),
                                      if (_trackingxuatxe != null)
                                        Column(
                                          children: _trackingxuatxe!.map((item) {
                                            List<String> textLines = [];

                                            // Kiểm tra và thêm chuỗi không rỗng
                                            if (item.ngay != null && item.ngay!.isNotEmpty) {
                                              textLines.add(formatDateTime(item.ngay ?? ""));
                                            }
                                            if (item.thongTinChiTiet != null && item.thongTinChiTiet!.isNotEmpty) {
                                              textLines.add(item.thongTinChiTiet ?? "");
                                            }
                                            if (item.thongtinvanchuyen != null && item.thongtinvanchuyen!.isNotEmpty) {
                                              textLines.add(item.thongtinvanchuyen ?? "");
                                            }
                                            if (item.nguoiPhuTrach != null && item.nguoiPhuTrach!.isNotEmpty) {
                                              textLines.add(item.nguoiPhuTrach ?? "");
                                            }

                                            // Nối các chuỗi với ký tự xuống dòng
                                            String textLine = textLines.join('\n');

                                            return buildRowItem(
                                              customImage: CustomImage2(),
                                              textLine: textLine,
                                            );
                                          }).toList(),
                                        ),
                                      if (_trackingchuyentiep != null)
                                        Column(
                                          children: _trackingchuyentiep!.map((item) {
                                            bool isNewKho = item.kho != previousKho;
                                            previousKho = item.kho;
                                            return buildRowItem(
                                                customImage: isNewKho ? CustomImage3() : SizedBox(width: 120),
                                                // customImage: CustomImage3(),
                                                textLine: (item.thoiGianVao != null ? (item.thoiGianVao ?? "") : "") +
                                                    '\n' +
                                                    (item.kho ?? "") +
                                                    ' - ' +
                                                    (item.baiXe ?? "") +
                                                    " - Vị trí: " +
                                                    (item.viTri ?? "") +
                                                    '\n' +
                                                    (item.nguoiNhapBai ?? ""));
                                          }).toList(),
                                        ),
                                      if (_xuatxe != null)
                                        Column(
                                          children: _xuatxe!.map((item) {
                                            List<String> textLines = [];

                                            // Kiểm tra và thêm chuỗi không rỗng
                                            if (item.ngay != null && item.ngay!.isNotEmpty) {
                                              textLines.add(formatDateTime(item.ngay ?? ""));
                                            }
                                            if (item.thongTinChiTiet != null && item.thongTinChiTiet!.isNotEmpty) {
                                              textLines.add(item.thongTinChiTiet ?? "");
                                            }
                                            if (item.thongtinvanchuyen != null && item.thongtinvanchuyen!.isNotEmpty) {
                                              textLines.add(item.thongtinvanchuyen ?? "");
                                            }
                                            if (item.nguoiPhuTrach != null && item.nguoiPhuTrach!.isNotEmpty) {
                                              textLines.add(item.nguoiPhuTrach ?? "");
                                            }

                                            // Nối các chuỗi với ký tự xuống dòng
                                            String textLine = textLines.join('\n');

                                            return buildRowItem(
                                              customImage: !item.thongtinvanchuyen!.contains("Cont") ? CustomImage2() : CustomImage6(),
                                              textLine: textLine,
                                            );
                                          }).toList(),
                                        ),
                                      if (_nhapbai != null)
                                        Column(
                                          children: _nhapbai!.map((item) {
                                            bool isNewKho = item.kho != previousKho;
                                            previousKho = item.kho;
                                            return buildRowItem(
                                                customImage: isNewKho ? CustomImage5() : SizedBox(width: 100),
                                                // customImage: CustomImage3(),
                                                textLine: (item.thoiGianVao != null ? (item.thoiGianVao ?? "") : "") +
                                                    '\n' +
                                                    (item.kho ?? "") +
                                                    ' - ' +
                                                    (item.baiXe ?? "") +
                                                    " - Vị trí: " +
                                                    (item.viTri ?? "") +
                                                    '\n' +
                                                    (item.nguoiNhapBai ?? ""));
                                          }).toList(),
                                        ),
                                      if (_xequa != null)
                                        Column(
                                          children: _xequa!.map((item) {
                                            List<String> textLines = [];

                                            // Kiểm tra và thêm chuỗi không rỗng
                                            if (item.ngayNhan != null && item.ngayNhan!.isNotEmpty) {
                                              textLines.add(formatDateTime(item.ngayNhan ?? ""));
                                            }
                                            if (item.noiNhan != null && item.noiNhan!.isNotEmpty) {
                                              textLines.add(item.noiNhan ?? "");
                                            }
                                            if (item.nguoiNhan != null && item.nguoiNhan!.isNotEmpty) {
                                              textLines.add(item.nguoiNhan ?? "");
                                            }
                                            String textLine = textLines.join('\n');

                                            return buildRowItem(
                                              customImage: CustomImage4(),
                                              textLine: textLine,
                                            );
                                          }).toList(),
                                        ),

                                      // buildDivider(),
                                      // buildDivider(),
                                      if (_xequa == null && _nhapbai == null && _xuatxe == null && _giaoxe == null)
                                        Container(
                                          padding: EdgeInsets.only(left: 30.w),
                                          child: Text(
                                            'Không có dữ liệu',
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      _loading
                          ? LoadingWidget(context)
                          : Container(
                              width: 90.w,
                              height: 45.h,
                              child: _buildBody(),
                            ),

                      // BodyTrackingXe(),
                    ],
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 11,
                padding: EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppConfig.bottom,
                ),
                child: Center(
                  child: customTitle(
                    'TRACKING XE THÀNH PHẨM',
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                // mainAxisSize: MainAxisSize.min,
                children: [
                  CardVin(),
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Trạng thái vận chuyển'),
                      Tab(text: 'Vị trí trên bản đồ'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CombinedItem {
  final DateTime? dateTime;
  final Widget customImage;
  final String textLine;

  CombinedItem({
    required this.dateTime,
    required this.customImage,
    required this.textLine,
  });
}
