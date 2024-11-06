class LSX_RutContModel {
  String? id;
  String? soKhung;
  String? loaiXe;
  String? soMay;
  String? mauXe;
  String? soCont;
  String? soSeal;
  String? nguoiRutCont;
  String? ngayRutCont;

  LSX_RutContModel({
    this.id,
    this.soKhung,
    this.soMay,
    this.mauXe,
    this.soCont,
    this.soSeal,
    this.ngayRutCont,
    this.loaiXe,
    this.nguoiRutCont,
  });
  factory LSX_RutContModel.fromJson(Map<String, dynamic> json) {
    return LSX_RutContModel(
      id: json["id"].toString(),
      soKhung: json["soKhung"],
      soMay: json["soMay"],
      mauXe: json["mauXe"],
      soCont: json["soCont"],
      soSeal: json["soSeal"],
      loaiXe: json["loaiXe"],
      nguoiRutCont: json["nguoiRutCont"],
      ngayRutCont: json["ngayRutCont"],
    );
  }
}
