import 'dart:convert';
import 'package:Thilogi/models/menurole.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Thilogi/services/request_helper.dart';

class MenuRoleBloc extends ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  List<MenuRoleModel>? _menurole;
  List<MenuRoleModel>? get menurole => _menurole;

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

  String? rule;
  String? url;

  Future<void> getData(
      BuildContext context, DonVi_Id, String PhanMem_Id) async {
    _isLoading = true;

    _menurole = null;

    try {
      final http.Response response = await requestHelper
          .getData('Menu/By_User1?DonVi_Id=$DonVi_Id&PhanMem_Id=$PhanMem_Id');
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        print("dataRole:${decodedData}");

        if (decodedData != null) {
          _menurole = (decodedData as List).map((p) {
            return MenuRoleModel.fromJson(p);
          }).toList();
          print(_menurole);
        }

        notifyListeners();
      } else {
        _menurole = null;
        _isLoading = false;
      }
    } catch (e) {
      _hasError = true;
      _isLoading = false;
      _message = e.toString();
      _errorCode = e.toString();
      notifyListeners();
    }
  }
}
