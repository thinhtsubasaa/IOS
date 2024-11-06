class CheckModel {
  String? id;
  String? fullName;
  String? maNhanVien;
  String? maPin;
  String? tenCong;

  CheckModel({this.id, this.fullName, this.maNhanVien, this.maPin, this.tenCong});
  factory CheckModel.fromJson(Map<String, dynamic> json) {
    return CheckModel(
      id: json["id"].toString(),
      fullName: json["fullName"],
      maNhanVien: json["maNhanVien"],
      maPin: json["maPin"],
      tenCong: json["tenCong"],
    );
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'maNhanVien': maNhanVien,
        'maPin': maPin,
        'tenCong': tenCong,
      };
}
