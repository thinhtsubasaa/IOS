class HuySealModel {
  String? key;
  String? id;
  String? lat;
  String? long;
  String? soCont;
  String? soSeal;
  String? toaDo;
  String? soKhung;
  String? tau;
  String? hinhAnh;

  HuySealModel({this.key, this.id, this.lat, this.long, this.soCont, this.soSeal, this.toaDo, this.soKhung, this.tau, this.hinhAnh});

  factory HuySealModel.fromJson(Map<String, dynamic> json) {
    return HuySealModel(
        key: json["key"], id: json["id"], soCont: json["soCont"], soSeal: json["soSeal"], lat: json["lat"], long: json["long"], hinhAnh: json["hinhAnh"], toaDo: json["toaDo"], tau: json["tau"], soKhung: json["soKhung"]);
  }
  Map<String, dynamic> toJson() => {
        'key': key,
        'id': id,
        "soCont": soCont,
        "soSeal": soSeal,
        "lat": lat,
        "long": long,
        "toaDo": toaDo,
        "soKhung": soKhung,
        "tau": tau,
        "hinhAnh": hinhAnh,
      };
}
