class TinhTrangDonHangModel {
  String? id;
  bool? isNhanXe;
  bool? isNhapKho;
  bool? isXuatKho;
  bool? isDaGiao;
  String? toaDo;

  TinhTrangDonHangModel({
    this.id,
    this.isNhanXe,
    this.isNhapKho,
    this.isDaGiao,
    this.isXuatKho,
    this.toaDo,
  });

  factory TinhTrangDonHangModel.fromJson(Map<String, dynamic> json) {
    return TinhTrangDonHangModel(
      id: json["id"].toString(),
      isNhanXe: json["isNhanXe"],
      isNhapKho: json["isNhapKho"],
      isDaGiao: json["isDaGiao"],
      isXuatKho: json["isXuatKho"],
      toaDo: json["toaDo"],
    );
  }
}