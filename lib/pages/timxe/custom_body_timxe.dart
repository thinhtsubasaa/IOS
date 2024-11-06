import 'dart:async';
import 'package:Thilogi/blocs/timxe.dart';
import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/models/timxe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutter_datawedge/models/scan_result.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/loading.dart';

class CustomBodyTimXe extends StatelessWidget {
  final String? soKhung;
  CustomBodyTimXe({this.soKhung});
  @override
  Widget build(BuildContext context) {
    return Container(child: BodyTimXeScreen(soKhung: soKhung));
  }
}

class BodyTimXeScreen extends StatefulWidget {
  final String? soKhung;
  const BodyTimXeScreen({Key? key, this.soKhung}) : super(key: key);

  @override
  _BodyTimXeScreenState createState() => _BodyTimXeScreenState();
}

class _BodyTimXeScreenState extends State<BodyTimXeScreen> with TickerProviderStateMixin, ChangeNotifier {
  String _qrData = '';
  // final _qrDataController = TextEditingController();
  late TextEditingController _qrDataController;
  bool _loading = false;
  TimXeModel? _data;
  late TimXeBloc _bl;
  String barcodeScanResult = '';

  late FlutterDataWedge dataWedge;
  late StreamSubscription<ScanResult> scanSubscription;
  Completer<GoogleMapController> _googleMapController = Completer();
  CameraPosition? _cameraPosition;
  Location? _location;
  LocationData? _currentLocation;
  Set<Marker> _markers = {};
  MapType _currentMapType = MapType.normal;

  @override
  void initState() {
    super.initState();
    _init();
    _bl = Provider.of<TimXeBloc>(context, listen: false);
    _qrDataController = TextEditingController(text: widget.soKhung ?? '');
    if (widget.soKhung != null && widget.soKhung!.isNotEmpty) {
      _handleBarcodeScanResult(widget.soKhung!);
    }
    dataWedge = FlutterDataWedge(profileName: "Example Profile");
    scanSubscription = dataWedge.onScanResult.listen((ScanResult result) {
      setState(() {
        barcodeScanResult = result.data;
      });
      print(barcodeScanResult);
      _handleBarcodeScanResult(barcodeScanResult);
    });
  }

  @override
  void dispose() {
    _qrDataController.dispose();
    super.dispose();
  }

  void _scanVIN() async {
    String result = await FlutterBarcodeScanner.scanBarcode(
      '#A71C20',
      'Cancel',
      false,
      ScanMode.QR,
    );
    setState(() {
      _qrData = result;
      _qrDataController.text = result;
    });
    print(result);
    _handleBarcodeScanResult(result);
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

  Widget CardVin() {
    return Container(
      width: MediaQuery.of(context).size.width < 330 ? 100.w : 90.w,
      height: MediaQuery.of(context).size.height < 880 ? 8.h : 8.h,
      margin: const EdgeInsets.only(top: 10),
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
            height: 11.h,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
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
                decoration: InputDecoration(
                  hintText: 'Nhập hoặc quét mã VIN',
                ),
                onSubmitted: (value) {
                  _handleBarcodeScanResult(value);
                },
                style: TextStyle(
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

              _handleBarcodeScanResult(barcodeScanResult);
            },
          ),
        ],
      ),
    );
  }

  void _handleBarcodeScanResult(String barcodeScanResult) {
    print("abc: ${barcodeScanResult}");
    if (_qrDataController != null) {
      setState(() {
        _qrData = '';
        _qrDataController.text = '';
        _data = null;
        Future.delayed(const Duration(seconds: 0), () {
          _qrData = barcodeScanResult;
          _qrDataController.text = barcodeScanResult;
          _onScan(barcodeScanResult);
        });
      });
    }
  }

  _onScan(value) {
    setState(() {
      _loading = true;
    });
    _bl.getData(context, value).then((_) {
      setState(() {
        _qrData = value;

        if (_bl.timxe == null) {
          _qrData = '';
          _qrDataController.text = '';
          _loading = false;
          _moveToPosition(LatLng(0, 0));
        } else {
          _loading = false;
          _data = _bl.timxe;
          if (_data?.toaDo == null) {
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
          _moveToPosition(convertToLatLng(_data?.toaDo ?? ""));
        }
      });
    });
  }

  void _showDetailDialog(BuildContext context) {
    final TimXeBloc timXeBloc = Provider.of<TimXeBloc>(context, listen: false);
    timXeBloc.timxe!.dieuChuyen!.sort((a, b) => b.gioNhan!.compareTo(a.gioNhan!));

    // Sắp xếp nhapKho theo thời gian gioNhan mới nhất đầu tiên
    timXeBloc.timxe!.nhapKho!.sort((a, b) => b.gioNhan!.compareTo(a.gioNhan!));
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Đặt màu nền
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // Đặt border radius
          ),
          contentPadding: EdgeInsets.fromLTRB(0, 0, 0.0, 0.0),
          title: const Center(
            child: Text(
              'LỊCH SỬ LƯU BÃI ',
              style: TextStyle(
                fontFamily: 'Comfortaa', // Font family
                fontSize: 16, // Kích thước chữ
                fontWeight: FontWeight.w600, // Độ đậm của chữ
                color: Color(0xFFBC2925), // Màu sắc chữ// Màu sắc chữ
              ),
            ),
          ),
          content: Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (timXeBloc.timxe != null)
                    Column(
                      children: [
                        ...timXeBloc.timxe!.dieuChuyen!.map((dieuChuyen) {
                          return ListTile(
                            title: Text(
                              '. ${dieuChuyen.gioNhan ?? ''}',
                              style: TextStyle(
                                fontFamily: 'Comfortaa', // Font family
                                fontSize: 13, // Kích thước chữ
                                fontWeight: FontWeight.w600, // Độ đậm của chữ
                                color: Color(0xFF0469B9), // Màu sắc chữ// Màu sắc chữ
                              ),
                            ),
                            subtitle: Text(
                              '${dieuChuyen.noiDen ?? ''} \n${dieuChuyen.nguoiNhapBai ?? ''}',
                              style: TextStyle(
                                fontFamily: 'Comfortaa', // Font family
                                fontSize: 13, // Kích thước chữ
                                fontWeight: FontWeight.w500, // Độ đậm của chữ
                                color: Colors.black, // Màu sắc chữ// Màu sắc chữ
                              ),
                            ),
                          );
                        }).toList(),
                        ...timXeBloc.timxe!.nhapKho!.map((nhapKho) {
                          return ListTile(
                            title: Text(
                              '. ${nhapKho.gioNhan ?? ''}',
                              style: TextStyle(
                                fontFamily: 'Comfortaa', // Font family
                                fontSize: 13, // Kích thước chữ
                                fontWeight: FontWeight.w600, // Độ đậm của chữ
                                color: Color(0xFF0469B9), // Màu sắc chữ// Màu sắc chữ
                              ),
                            ),
                            subtitle: Text(
                              '${nhapKho.noiDen ?? ''} \n${nhapKho.nguoiNhapBai ?? ''}',
                              style: TextStyle(
                                  fontFamily: 'Comfortaa', // Font family
                                  fontSize: 13, // Kích thước chữ
                                  fontWeight: FontWeight.w500, // Độ đậm của chữ
                                  color: Colors.black // Màu sắc chữ// Màu sắc chữ
                                  ),
                            ),
                          );
                        }).toList(),
                      ],
                    )
                ],
              ),
            ),
          ),
          actions: [
            Center(
              child: Container(
                width: 30.w, // Đảm bảo nút chiếm hết chiều rộng của dialog
                // Đặt margin cho nút
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0), // Đặt border radius cho nút
                  border: Border.all(
                    color: Colors.blue, // Đặt màu viền
                    width: 2.0, // Đặt độ dày của viền
                  ),
                  color: Colors.blue, // Đặt màu nền
                ),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Đóng',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Comfortaa', // Font family
                      fontSize: 15, // Kích thước chữ
                      fontWeight: FontWeight.w500,
                    ), // Đặt màu chữ
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          CardVin(),
          const SizedBox(height: 5),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                alignment: Alignment.bottomCenter,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _loading
                        ? LoadingWidget(context)
                        : Container(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Thông Tin Lưu bãi',
                                      style: TextStyle(
                                        fontFamily: 'Comfortaa',
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.visibility),
                                      onPressed: () {
                                        // Hành động khi nhấn vào icon
                                        _showDetailDialog(context);
                                        // Điều hướng đến trang lịch sử hoặc thực hiện hành động khác
                                      },
                                    ),
                                  ],
                                ),
                                // const Text(
                                //   'Thông Tin Tìm Kiếm',
                                //   style: TextStyle(
                                //     fontFamily: 'Comfortaa',
                                //     fontSize: 20,
                                //     fontWeight: FontWeight.w700,
                                //   ),
                                // ),
                                const Divider(height: 1, color: Color(0xFFA71C20)),
                                Container(
                                  margin: EdgeInsets.only(right: 10),
                                  child: Column(
                                    children: [
                                      CustomItem(
                                        title: 'Số khung: ',
                                        value: _data?.soKhung,
                                      ),
                                      const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                      CustomItem(
                                        title: 'Phương thức: ',
                                        value: _data?.phuongThuc,
                                      ),
                                      const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                      CustomItem(
                                        title: 'Đơn vị vận chuyển: ',
                                        value: _data?.donVi,
                                      ),
                                      const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                      CustomItem(
                                        title: 'Màu xe: ',
                                        value: _data?.tenMau,
                                      ),
                                      const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                      CustomItem(
                                        title: 'Loại xe: ',
                                        value: _data?.tenSanPham,
                                      ),
                                      const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                      CustomItem(
                                        title: 'Kho Xe: ',
                                        value: _data?.tenKho,
                                      ),
                                      const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                      Item(
                                        title: 'Bãi Xe: ',
                                        value: _data?.tenBaiXe,
                                      ),
                                      const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                      Item(
                                        title: 'Vị Trí Xe: ',
                                        value: _data?.tenViTri,
                                      ),
                                      const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                      Item(
                                        title: 'Người phụ trách: ',
                                        value: _data?.nguoiPhuTrach,
                                      ),
                                      const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                      Item(
                                        title: 'Tọa độ: ',
                                        value: _data?.toaDo,
                                      ),
                                      const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                      Container(
                                        width: 90.w,
                                        height: 45.h,
                                        child: _buildBody(),
                                      ),
                                      const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomItem extends StatelessWidget {
  final String title;
  final String? value;

  const CustomItem({
    Key? key,
    required this.title,
    this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6.h,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF818180),
              ),
            ),
          ),
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.67),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                value ?? "",
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontFamily: 'Coda Caption',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppConfig.primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Item extends StatelessWidget {
  final String title;
  final String? value;

  const Item({
    Key? key,
    required this.title,
    this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6.h,
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Center(
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF818180),
              ),
            ),
            SelectableText(
              value ?? "",
              style: const TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppConfig.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
