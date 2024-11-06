class RutContModel {
  String? key;
  String? id;
  String? soCont;
  String? soSeal;
  String? viTri;
  String? loaiXe;
  String? dongCont_Id;

  RutContModel(
      {this.key,
      this.id,
      this.soCont,
      this.soSeal,
      this.loaiXe,
      this.viTri,
      this.dongCont_Id});

  factory RutContModel.fromJson(Map<String, dynamic> json) {
    return RutContModel(
      key: json["key"],
      id: json["id"],
      soCont: json["soCont"],
      soSeal: json["soSeal"],
      viTri: json["viTri"],
      loaiXe: json["loaiXe"],
      dongCont_Id: json["dongCont_Id"],
    );
  }
}
