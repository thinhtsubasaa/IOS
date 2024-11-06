class DSX_DongContModel {
  String? key;
  String? id;
  String? lat;
  String? long;
  String? soContId;
  String? soCont;
  String? soSeal;
  String? viTri;
  String? loaiXe;

  bool? tinhTrang;

  DSX_DongContModel(
      {this.key,
      this.id,
      this.lat,
      this.long,
      this.soCont,
      this.soSeal,
      this.tinhTrang,
      this.soContId,
      this.loaiXe,
      this.viTri});

  factory DSX_DongContModel.fromJson(Map<String, dynamic> json) {
    return DSX_DongContModel(
      key: json["key"],
      id: json["id"],
      soCont: json["soCont"],
      soSeal: json["soSeal"],
      lat: json["lat"],
      long: json["long"],
      viTri: json["viTri"],
      soContId: json["soContId"],
      tinhTrang: json["tinhTrang"],
      loaiXe: json["loaiXe"],
    );
  }
  Map<String, dynamic> toJson() => {
        'key': key,
        'id': id,
        "soCont": soCont,
        "soSeal": soSeal,
        "lat": lat,
        "long": long,
        "viTri": viTri,
        "tinhTrang": tinhTrang,
        "soContId": soContId,
      };
}
