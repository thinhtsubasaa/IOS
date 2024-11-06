class DS_DongContModel {
  String? key;
  String? id;
  String? soCont;
  String? soSeal;
  String? loaiXe;
  String? soKhung;
  String? viTri;
  String? tau;
  String? phuongThuc;

  DS_DongContModel({this.key, this.id, this.soCont, this.soSeal, this.loaiXe, this.soKhung, this.tau, this.viTri, this.phuongThuc});

  factory DS_DongContModel.fromJson(Map<String, dynamic> json) {
    return DS_DongContModel(
        key: json["key"], id: json["id"], soCont: json["soCont"], soSeal: json["soSeal"], viTri: json["viTri"], loaiXe: json["loaiXe"], tau: json["tau"], soKhung: json["soKhung"], phuongThuc: json["phuongThuc"]);
  }
  Map<String, dynamic> toJson() => {
        'key': key,
        'id': id,
        "soCont": soCont,
        "soSeal": soSeal,
        "viTri": viTri,
        "loaiXe": loaiXe,
        "soKhung": soKhung,
        "phuongThuc": phuongThuc,
      };
}
