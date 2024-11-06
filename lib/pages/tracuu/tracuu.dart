import 'dart:async';

import 'package:Thilogi/blocs/scan_nhanvien_bloc.dart';
import 'package:Thilogi/models/nhanvien.dart';
import 'package:Thilogi/widgets/divider.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/config/config.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutter_datawedge/models/scan_result.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:sizer/sizer.dart';
import '../../blocs/user_bloc.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_title.dart';
import '../../widgets/loading.dart';

class TraCuuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: customAppBar(context),
      body: Column(
        children: [
          CustomCard(),
          Expanded(
            child: Container(
              width: 100.w,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              child: CustomBodyAccount(),
            ),
          ),
          BottomContent(),
        ],
      ),
    );
  }
}

class CustomBodyAccount extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: BodyAccountScreen());
  }
}

class BodyAccountScreen extends StatefulWidget {
  const BodyAccountScreen({Key? key}) : super(key: key);

  @override
  _BodyAccountScreenState createState() => _BodyAccountScreenState();
}

class _BodyAccountScreenState extends State<BodyAccountScreen> with SingleTickerProviderStateMixin {
  late Scan_NhanVienBloc ub;
  late UserBloc? _us;
  String _qrData = '';
  final _qrDataController = TextEditingController();
  bool _loading = false;
  NhanVienModel? _data;
  String? barcodeScanResult = '';

  String? _message;
  String? get message => _message;
  late FlutterDataWedge dataWedge;
  late StreamSubscription<ScanResult> scanSubscription;

  @override
  void initState() {
    super.initState();
    ub = Provider.of<Scan_NhanVienBloc>(context, listen: false);
    _us = Provider.of<UserBloc>(context, listen: false);
    dataWedge = FlutterDataWedge(profileName: "Example Profile");
    scanSubscription = dataWedge.onScanResult.listen((ScanResult result) {
      setState(() {
        barcodeScanResult = result.data;
      });
      print(barcodeScanResult);
      _handleBarcodeScanResult(barcodeScanResult ?? "");
    });
  }

  @override
  void dispose() {
    super.dispose();
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
            child: Center(
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
              _handleBarcodeScanResult(barcodeScanResult ?? "");
            },
          ),
        ],
      ),
    );
  }

  void _handleBarcodeScanResult(String barcodeScanResult) {
    print("abc: ${barcodeScanResult}");

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

  _onScan(value) {
    setState(() {
      _loading = true;
    });
    ub.getData(context, value).then((_) {
      setState(() {
        _qrData = value;
        if (ub.nhanvien == null) {
          barcodeScanResult = null;
          _qrData = '';
          _qrDataController.text = '';
        } else {
          _loading = false;
          _data = ub.nhanvien;
          if (_data?.isVaoCong == true) {
            String errorMessage = "Không được vào cổng";
            QuickAlert.show(
              // ignore: use_build_context_synchronously
              context: context,
              type: QuickAlertType.info,
              title: '',
              text: errorMessage,
              confirmBtnText: 'Đồng ý',
            );
          }
        }
      });
    }).then((_) {
      setState(() {
        // barcodeScanResult = null;
        // _qrData = '';
        // _qrDataController.text = '';
        _loading = false;
      });
    });
    ;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(children: [
          CardVin(),
          const SizedBox(height: 5),
          Center(
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
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              const Text(
                                'Thông Tin Nhân Viên',
                                style: TextStyle(
                                  fontFamily: 'Comfortaa',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Divider(height: 1, color: Color(0xFFA71C20)),
                              const SizedBox(height: 10),
                              Column(
                                children: [
                                  ListTile(
                                    contentPadding: EdgeInsets.all(0),
                                    title: Container(
                                      width: 200,
                                      height: 200,
                                      child: _data?.hinhAnh_Url != null
                                          ? Image.network(
                                              _data?.hinhAnh_Url ?? "",
                                              fit: BoxFit.contain,
                                            )
                                          : Image.network(
                                              AppConfig.defaultImage,
                                              fit: BoxFit.contain,
                                            ),
                                    ),
                                  ),
                                  const DividerWidget(),
                                  ListTile(
                                    contentPadding: const EdgeInsets.all(0),
                                    leading: const CircleAvatar(
                                      backgroundColor: Colors.blueAccent,
                                      radius: 18,
                                      child: Icon(
                                        Feather.user_check,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                    title: Text(
                                      _data?.tenNhanVien ?? "",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  const DividerWidget(),
                                  ListTile(
                                    contentPadding: const EdgeInsets.all(0),
                                    leading: const CircleAvatar(
                                      backgroundColor: Colors.blueAccent,
                                      radius: 18,
                                      child: Icon(
                                        Feather.user_plus,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                    title: Text(
                                      _data?.maNhanVien ?? "",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  const DividerWidget(),
                                  ListTile(
                                    contentPadding: const EdgeInsets.all(0),
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.indigoAccent[100],
                                      radius: 18,
                                      child: const Icon(
                                        Feather.mail,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                    title: Text(
                                      _data?.tenPhongBan ?? "",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class BottomContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 11,
      padding: EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: AppConfig.bottom,
      ),
      child: Center(
        child: customTitle(
          'THÔNG TIN THẺ NHÂN VIÊN',
        ),
      ),
    );
  }
}
