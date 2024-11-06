class BaiXeModel {
  String? id;
  String? tenBaiXe;
  String? tenKhoXe;

  BaiXeModel({
    this.id,
    this.tenBaiXe,
    this.tenKhoXe,
  });
  factory BaiXeModel.fromJson(Map<String, dynamic> json) {
    return BaiXeModel(
      id: json["id"].toString(),
      tenBaiXe: json["tenBaiXe"],
      tenKhoXe: json["tenKhoXe"],
    );
  }
}
