class DS_ChoXuatModel {
  String? key;
  String? id;
  String? tenViTri;
  String? loaiXe;
  String? soKhung;
  String? donVi;
  String? maMau;
  String? phuongThuc;
  bool? isKeHoach;

  DS_ChoXuatModel(
      {this.key,
      this.id,
      this.loaiXe,
      this.soKhung,
      this.tenViTri,
      this.donVi,
      this.maMau,
      this.phuongThuc,
      this.isKeHoach});

  factory DS_ChoXuatModel.fromJson(Map<String, dynamic> json) {
    return DS_ChoXuatModel(
      key: json["key"],
      id: json["id"],
      loaiXe: json["loaiXe"],
      soKhung: json["soKhung"],
      tenViTri: json["tenViTri"],
      donVi: json["donVi"],
      maMau: json["maMau"],
      phuongThuc: json["phuongThuc"],
      isKeHoach: json["isKeHoach"],
    );
  }
}
