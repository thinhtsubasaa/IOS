class LSVanChuyenModel {
  String? id;
  String? ngay;
  String? loaiXe;
  String? soKhung;
  String? thongTinVanChuyen;
  String? thongTinChiTiet;
  String? nguoiVanChuyen;
  String? donVi;
  String? gioNhan;
  String? mauXe;
  bool? isCheck;

  LSVanChuyenModel({this.id, this.ngay, this.loaiXe, this.soKhung, this.thongTinVanChuyen, this.mauXe, this.thongTinChiTiet, this.nguoiVanChuyen, this.donVi, this.gioNhan, this.isCheck});
  factory LSVanChuyenModel.fromJson(Map<String, dynamic> json) {
    return LSVanChuyenModel(
      id: json["id"].toString(),
      ngay: json["ngay"],
      loaiXe: json["loaiXe"],
      soKhung: json["soKhung"],
      thongTinChiTiet: json["thongTinChiTiet"],
      thongTinVanChuyen: json["thongTinVanChuyen"],
      nguoiVanChuyen: json["nguoiVanChuyen"],
      donVi: json["donVi"],
      gioNhan: json["gioNhan"],
      isCheck: json["isCheck"],
      mauXe: json["mauXe"],
    );
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'ngay': ngay,
        'loaiXe': loaiXe,
        'soKhung': soKhung,
        'thongTinChiTiet': thongTinChiTiet,
        'thongTinVanChuyen': thongTinVanChuyen,
        'nguoiVanChuyen': nguoiVanChuyen,
        'donVi': donVi,
        'gioNhan': gioNhan,
        'isCheck': isCheck,
        'mauXe': mauXe
      };
}
