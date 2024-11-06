class ViTriModel {
  String? id;
  String? tenViTri;
  String? tenBaiXe;

  ViTriModel({
    this.id,
    this.tenViTri,
    this.tenBaiXe,
  });
  factory ViTriModel.fromJson(Map<String, dynamic> json) {
    return ViTriModel(
      id: json["id"].toString(),
      tenViTri: json["tenViTri"],
      tenBaiXe: json["tenBaiXe"],
    );
  }
}
