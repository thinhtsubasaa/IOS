class DanhSachPhuongTienModel {
  String? id;
  String? tenPhuongTien;
  String? tenLoaiPhuongTien;
  String? bienSo;

  DanhSachPhuongTienModel({
    this.id,
    this.tenPhuongTien,
    this.tenLoaiPhuongTien,
    this.bienSo,
  });
  factory DanhSachPhuongTienModel.fromJson(Map<String, dynamic> json) {
    return DanhSachPhuongTienModel(
      id: json["id"].toString(),
      tenPhuongTien: json["tenPhuongTien"],
      tenLoaiPhuongTien: json["tenLoaiPhuongTien"],
      bienSo: json["bienSo"],
    );
  }
}
