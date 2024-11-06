class LSX_NhapChuyenBaiModel {
  String? id;
  String? loaiXe;
  String? soKhung;
  String? mauXe;
  String? nguoiNhapBai;
  String? noiDi;
  String? noiDen;
  String? gioNhan;
  String? ngay;
  LSX_NhapChuyenBaiModel(
      {this.id,
      this.loaiXe,
      this.soKhung,
      this.mauXe,
      this.gioNhan,
      this.noiDi,
      this.noiDen,
      this.ngay,
      this.nguoiNhapBai});

  factory LSX_NhapChuyenBaiModel.fromJson(Map<String, dynamic> json) {
    return LSX_NhapChuyenBaiModel(
      id: json["id"],
      loaiXe: json["loaiXe"],
      soKhung: json["soKhung"],
      mauXe: json["mauXe"],
      nguoiNhapBai: json["nguoiNhapBai"],
      noiDi: json["noiDi"],
      noiDen: json["noiDen"],
      ngay: json["ngay"],
      gioNhan: json["gioNhan"],
    );
  }
}
