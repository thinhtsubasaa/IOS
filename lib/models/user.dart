class UserModel {
  final String? fullName;
  final String? email;
  final String? id;
  final bool? mustChangePass;
  final String? accessRole;
  final String? token;
  final String? refreshToken;
  final String? hinhAnhUrl;
  final String? qrCode;
  final String? maNhanVien;
  final String? tenPhongBan;
  final String? congBaoVe;

  UserModel({
    this.fullName,
    this.email,
    this.id,
    this.mustChangePass,
    this.token,
    this.refreshToken,
    this.hinhAnhUrl,
    this.accessRole,
    this.qrCode,
    this.maNhanVien,
    this.tenPhongBan,
    this.congBaoVe,
  });
}
