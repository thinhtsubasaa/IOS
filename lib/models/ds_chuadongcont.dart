class DSX_ChuaDongContModel {
  String? id;
  String? soCont;
  String? soSeal;
  String? tau;
  String? loaiXe;
  String? soKhung;
  String? soMay;
  String? mauXe;
  String? ngayTao;
  String? noiDen;
  String? viTri;

  DSX_ChuaDongContModel({
    this.id,
    this.soCont,
    this.soSeal,
    this.tau,
    this.loaiXe,
    this.soKhung,
    this.soMay,
    this.mauXe,
    this.ngayTao,
    this.noiDen,
    this.viTri,
  });

  factory DSX_ChuaDongContModel.fromJson(Map<String, dynamic> json) {
    return DSX_ChuaDongContModel(
      id: json["id"],
      soCont: json["soCont"],
      soSeal: json["soSeal"],
      loaiXe: json["loaiXe"],
      soKhung: json["soKhung"],
      soMay: json["soMay"],
      mauXe: json["mauXe"],
      ngayTao: json["ngayTao"],
      noiDen: json["noiDen"],
      viTri: json["viTri"],
    );
  }
}
