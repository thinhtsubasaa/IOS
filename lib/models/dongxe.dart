class DongXeModel {
  String? id;
  String? maDongXe;
  String? tenDongXe;

  DongXeModel({
    this.id,
    this.maDongXe,
    this.tenDongXe,
  });
  factory DongXeModel.fromJson(Map<String, dynamic> json) {
    return DongXeModel(
      id: json["id"].toString(),
      maDongXe: json["maDongXe"],
      tenDongXe: json["tenDongXe"],
    );
  }
}
