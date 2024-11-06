class NhaMayModel {
  String? id;
  String? maNhaMay;
  String? tenNhaMay;

  NhaMayModel({
    this.id,
    this.maNhaMay,
    this.tenNhaMay,
  });
  factory NhaMayModel.fromJson(Map<String, dynamic> json) {
    return NhaMayModel(
      id: json["id"].toString(),
      maNhaMay: json["maNhaMay"],
      tenNhaMay: json["tenNhaMay"],
    );
  }
}
