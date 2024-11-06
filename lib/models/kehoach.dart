import 'package:uuid/uuid.dart';

class KeHoachModel {
  String? id;

  String? soKhung;
  String? noiDi_Id;
  String? noiDen_Id;
  String? vanChuyen_Id;
  String? doiTac_Id;
  String? kvChuyenTieps_Id;
  String? taiXe_Id;

  KeHoachModel({this.id, this.soKhung, this.noiDi_Id, this.noiDen_Id, this.vanChuyen_Id, this.doiTac_Id, this.kvChuyenTieps_Id, this.taiXe_Id});

  factory KeHoachModel.fromJson(Map<String, dynamic> json) {
    return KeHoachModel(
        id: json["id"],
        soKhung: json["soKhung"],
        noiDi_Id: json["noiDi_Id"],
        noiDen_Id: json["noiDen_Id"],
        vanChuyen_Id: json["vanChuyen_Id"],
        doiTac_Id: json["doiTac_Id"],
        kvChuyenTieps_Id: json["kvChuyenTieps_Id"],
        taiXe_Id: json["taiXe_Id"]);
  }
  Map<String, dynamic> toJson() =>
      {'id': id ?? Uuid().v4(), 'soKhung': soKhung, 'noiDi_Id': noiDi_Id, 'noiDen_Id': noiDen_Id, 'vanChuyen_Id': vanChuyen_Id, 'doiTac_Id': doiTac_Id, 'kvChuyenTieps_Id': kvChuyenTieps_Id, 'taiXe_Id': taiXe_Id};
}
