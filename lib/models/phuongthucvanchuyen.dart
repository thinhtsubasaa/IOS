class PhuongThucVanChuyenModel {
  String? id;
  String? maPhuongThucVanChuyen;
  String? tenPhuongThucVanChuyen;

  PhuongThucVanChuyenModel({
    this.id,
    this.maPhuongThucVanChuyen,
    this.tenPhuongThucVanChuyen,
  });
  factory PhuongThucVanChuyenModel.fromJson(Map<String, dynamic> json) {
    return PhuongThucVanChuyenModel(
      id: json["id"].toString(),
      maPhuongThucVanChuyen: json["maPhuongThucVanChuyen"],
      tenPhuongThucVanChuyen: json["tenPhuongThucVanChuyen"],
    );
  }
}
