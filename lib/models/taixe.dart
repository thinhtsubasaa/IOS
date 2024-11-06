class TaiXeModel {
  String? id;
  String? maTaiXe;
  String? tenTaiXe;
  String? hangBang;
  String? soDienThoai;

  TaiXeModel(
      {this.id, this.maTaiXe, this.tenTaiXe, this.hangBang, this.soDienThoai});
  factory TaiXeModel.fromJson(Map<String, dynamic> json) {
    return TaiXeModel(
      id: json["id"].toString(),
      maTaiXe: json["maTaiXe"],
      tenTaiXe: json["tenTaiXe"],
      hangBang: json["hangBang"],
      soDienThoai: json["soDienThoai"],
    );
  }
}
