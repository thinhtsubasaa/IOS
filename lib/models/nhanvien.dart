class NhanVienModel {
  final String? tenNhanVien;
  final String? email;
  final String? id;
  final bool? mustChangePass;
  final String? token;
  final String? hinhAnh_Url;
  final String? maNhanVien;
  final String? tenPhongBan;
  bool? isVaoCong;

  NhanVienModel({
    this.tenNhanVien,
    this.email,
    this.id,
    this.mustChangePass,
    this.token,
    this.hinhAnh_Url,
    this.maNhanVien,
    this.isVaoCong,
    this.tenPhongBan,
  });
  factory NhanVienModel.fromJson(Map<String, dynamic> json) {
    return NhanVienModel(
      id: json["id"].toString(),
      email: json["email"],
      tenNhanVien: json["fullName"],
      token: json["token"],
      hinhAnh_Url: json["hinhAnh_Url"],
      maNhanVien: json["maNhanVien"],
      tenPhongBan: json["tenPhongBan"],
      isVaoCong: json["isVaoCong"],
    );
  }
}
