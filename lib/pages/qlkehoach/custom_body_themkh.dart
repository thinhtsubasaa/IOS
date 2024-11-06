import 'dart:async';
import 'dart:convert';

import 'package:Thilogi/models/kehoach.dart';
import 'package:Thilogi/models/themdongcont.dart';

import 'package:flutter/material.dart';

import 'package:Thilogi/services/request_helper.dart';

import 'package:quickalert/quickalert.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:sizer/sizer.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator_platform_interface/src/enums/location_accuracy.dart' as GeoLocationAccuracy;

import '../../config/config.dart';

import '../../services/app_service.dart';
import '../../widgets/loading.dart';

class CustomBodyThemKH extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: BodyThemKHScreen());
  }
}

class BodyThemKHScreen extends StatefulWidget {
  const BodyThemKHScreen({Key? key}) : super(key: key);

  @override
  _BodyThemKHScreenState createState() => _BodyThemKHScreenState();
}

class _BodyThemKHScreenState extends State<BodyThemKHScreen> with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();
  String _qrData = '';
  String? SoContId;
  final _qrDataController = TextEditingController();
  String? soCont;
  String? TauId;
  String? viTri;
  final TextEditingController _maSoCont = TextEditingController();
  final TextEditingController _soCont = TextEditingController();
  bool _tinhTrang = false;

  List<ThemDongContModel>? _themdongcont;
  List<ThemDongContModel>? get themdongcont => _themdongcont;

  KeHoachModel? _data;
  bool _loading = false;
  String? NoiDi_Id;
  String? NoiDen_Id;
  String? DoiTac_Id;
  String? KVChuyenTiep_Id;
  String? VanChuyen_Id;
  String? TaiXe_Id;
  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _message;
  String? get message => _message;

  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  final TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _data = KeHoachModel();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  Future<void> postData(KeHoachModel addData) async {
    try {
      final http.Response response = await requestHelper.postData('KeHoachGiaoXe', addData.toJson());
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        notifyListeners();
        _btnController.success();
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Thành công',
          text: "Thêm thành công",
          confirmBtnText: 'Đồng ý',
        );
        _btnController.reset();
      } else {
        String errorMessage = response.body.replaceAll('"', '');
        notifyListeners();
        _btnController.error();
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Thất bại',
          text: errorMessage,
          confirmBtnText: 'Đồng ý',
        );
        _btnController.reset();
      }
    } catch (e) {
      _message = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  _onSave() {
    setState(() {
      _loading = true;
    });
    _data ??= KeHoachModel();
    _data?.id ??= Uuid().v4();
    _data?.soKhung = _maSoCont.text;
    _data?.noiDi_Id = NoiDi_Id;
    _data?.noiDen_Id = NoiDen_Id;
    _data?.doiTac_Id = DoiTac_Id;
    _data?.vanChuyen_Id = VanChuyen_Id;
    _data?.kvChuyenTieps_Id = KVChuyenTiep_Id;
    _data?.taiXe_Id = TaiXe_Id;

    // print("maSoCont: ${_data?.maSoCont}");
    // print("SoCont:${_data?.soCont}");

    AppService().checkInternet().then((hasInternet) {
      if (!hasInternet!) {
        // openSnackBar(context, 'no internet'.tr());
        QuickAlert.show(
          // ignore: use_build_context_synchronously
          context: context,
          type: QuickAlertType.error,
          title: 'Thất bại',
          text: 'Không có kết nối internet. Vui lòng kiểm tra lại',
          confirmBtnText: 'Đồng ý',
        );
      } else {
        postData(_data!).then((_) {
          setState(() {
            _maSoCont.text = '';
            _soCont.text = '';
            _data = null;
            _loading = false;
          });
        });
      }
    });
  }

  void _showConfirmationDialog(BuildContext context) {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        text: 'Bạn có muốn thêm mới không?',
        title: '',
        confirmBtnText: 'Đồng ý',
        cancelBtnText: 'Không',
        confirmBtnTextStyle: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
        cancelBtnTextStyle: const TextStyle(
          color: Colors.red,
          fontSize: 19.0,
          fontWeight: FontWeight.bold,
        ),
        onCancelBtnTap: () {
          Navigator.of(context).pop();
          _btnController.reset();
        },
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
          _onSave();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
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
                          // margin: EdgeInsets.only(top: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Thông Tin Xác Nhận',
                                style: TextStyle(
                                  fontFamily: 'Comfortaa',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Divider(height: 1, color: Color(0xFFA71C20)),
                              SizedBox(height: 5),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyInputWidget(
                                    title: 'Số khung',
                                    controller: _maSoCont,
                                    textStyle: const TextStyle(
                                      fontFamily: 'Comfortaa',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: AppConfig.textInput,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  MyInputWidget(
                                    title: 'Nơi đi',
                                    controller: _soCont,
                                    textStyle: const TextStyle(
                                      fontFamily: 'Comfortaa',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: AppConfig.textInput,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  MyInputWidget(
                                    title: 'Nơi đến',
                                    controller: _soCont,
                                    textStyle: const TextStyle(
                                      fontFamily: 'Comfortaa',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: AppConfig.textInput,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  MyInputWidget(
                                    title: 'KV Chuyển tiếp',
                                    controller: _soCont,
                                    textStyle: const TextStyle(
                                      fontFamily: 'Comfortaa',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: AppConfig.textInput,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  MyInputWidget(
                                    title: 'Đối tác',
                                    controller: _soCont,
                                    textStyle: const TextStyle(
                                      fontFamily: 'Comfortaa',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: AppConfig.textInput,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  MyInputWidget(
                                    title: 'PTVC',
                                    controller: _soCont,
                                    textStyle: const TextStyle(
                                      fontFamily: 'Comfortaa',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: AppConfig.textInput,
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
        ),
        Container(
          padding: const EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RoundedLoadingButton(
                child: Text('Lưu',
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      color: AppConfig.textButton,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    )),
                controller: _btnController,
                onPressed: _maSoCont.text != null ? () => _showConfirmationDialog(context) : null,
              ),
            ],
          ),
        ),
      ],
    ));
  }
}

class MyInputWidget extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final TextStyle textStyle;

  const MyInputWidget({
    Key? key,
    required this.title,
    required this.controller,
    required this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 7.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: const Color(0xFF818180),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30.w,
            decoration: const BoxDecoration(
              color: Color(0xFFF6C6C7),
              border: Border(
                right: BorderSide(
                  color: Color(0xFF818180),
                  width: 1,
                ),
              ),
            ),
            child: Center(
              child: Text(
                title,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppConfig.textInput,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.only(left: 15.sp),
              child: TextFormField(
                controller: controller,
                style: textStyle,
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
