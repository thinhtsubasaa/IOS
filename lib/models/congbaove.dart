class CongBaoVeModel {
  String? id;
  String? tenCong;

  CongBaoVeModel({
    this.id,
    this.tenCong,
  });
  factory CongBaoVeModel.fromJson(Map<String, dynamic> json) {
    return CongBaoVeModel(
      id: json["id"].toString(),
      tenCong: json["tenCong"],
    );
  }
}
