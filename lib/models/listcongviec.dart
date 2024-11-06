class CongViecModel {
  String? id;
  String? loaiXe;
  String? soKhung;
  String? mauXe;
  String? khoDi;
  String? baiXeDi;
  String? viTriDi;
  String? ngayDiChuyen;
  String? noiDi;
  String? noiDen;
  String? ngayVanChuyen;

  CongViecModel({
    this.id,
    this.loaiXe,
    this.soKhung,
    this.mauXe,
    this.khoDi,
    this.baiXeDi,
    this.viTriDi,
    this.ngayDiChuyen,
    this.noiDi,
    this.noiDen,
    this.ngayVanChuyen,
  });
  factory CongViecModel.fromJson(Map<String, dynamic> json) {
    return CongViecModel(
      id: json["id"].toString(),
      loaiXe: json["loaiXe"],
      soKhung: json["soKhung"],
      mauXe: json["mauXe"],
      khoDi: json["khoDi"],
      baiXeDi: json["baiXeDi"],
      viTriDi: json["viTriDi"],
      ngayDiChuyen: json["ngayDiChuyen"],
      noiDi: json["noiDi"],
      noiDen: json["noiDen"],
      ngayVanChuyen: json["ngayVanChuyen"],
    );
  }
}
