import 'package:uuid/uuid.dart';

class ThemDongContModel {
  String? id;

  String? maSoCont;
  String? soCont;
  String? soSeal;
  bool? tinhTrang;

  ThemDongContModel(
      {this.id, this.soCont, this.soSeal, this.maSoCont, this.tinhTrang});

  factory ThemDongContModel.fromJson(Map<String, dynamic> json) {
    return ThemDongContModel(
      id: json["id"],
      maSoCont: json["maSoCont"],
      soCont: json["soCont"],
      soSeal: json["soSeal"],
      tinhTrang: json["tinhTrang"],
    );
  }
  Map<String, dynamic> toJson() => {
        'id': id ?? Uuid().v4(),
        'maSoCont': maSoCont,
        'soCont': soCont,
        'tinhTrang': tinhTrang
      };
}
