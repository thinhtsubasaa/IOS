class LoaiPhuongTienModel {
  String? id;
  String? maLoaiPhuongTien;
  String? tenLoaiPhuongTien;

  LoaiPhuongTienModel({
    this.id,
    this.maLoaiPhuongTien,
    this.tenLoaiPhuongTien,
  });
  factory LoaiPhuongTienModel.fromJson(Map<String, dynamic> json) {
    return LoaiPhuongTienModel(
      id: json["id"].toString(),
      maLoaiPhuongTien: json["maLoaiPhuongTien"],
      tenLoaiPhuongTien: json["tenLoaiPhuongTien"],
    );
  }
}
