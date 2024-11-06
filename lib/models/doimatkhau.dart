class DoiMatKhauModel {
  String? password;
  String? newPassword;
  String? confirmNewPassword;

  DoiMatKhauModel({
    this.password,
    this.newPassword,
    this.confirmNewPassword,
  });
  factory DoiMatKhauModel.fromJson(Map<String, dynamic> json) {
    return DoiMatKhauModel(
      password: json["password"],
      newPassword: json["newPassword"],
      confirmNewPassword: json["confirmNewPassword"],
    );
  }
  Map<String, dynamic> toJson() => {
        'password': password,
        'newPassword': newPassword,
        'confirmNewPassword': confirmNewPassword
      };
}
