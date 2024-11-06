class LSX_ChuyenBaiModel {
  String? id;
  String? loaiXe;
  String? soKhung;
  String? mauXe;
  String? nguoiDieuChuyen;
  String? noiDi;
  String? noiDen;
  String? gioNhan;
  LSX_ChuyenBaiModel(
      {this.id,
      this.loaiXe,
      this.soKhung,
      this.mauXe,
      this.gioNhan,
      this.noiDi,
      this.noiDen,
      this.nguoiDieuChuyen});

  factory LSX_ChuyenBaiModel.fromJson(Map<String, dynamic> json) {
    return LSX_ChuyenBaiModel(
      id: json["id"],
      loaiXe: json["loaiXe"],
      soKhung: json["soKhung"],
      mauXe: json["mauXe"],
      nguoiDieuChuyen: json["nguoiNhapBai"],
      noiDi: json["noiDi"],
      noiDen: json["noiDen"],
      gioNhan: json["gioNhan"],
    );
  }
}
