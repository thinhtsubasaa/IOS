class NoiDenModel {
  String? id;
  String? noiDen;
  String? bienSo;

  NoiDenModel({this.id, this.noiDen, this.bienSo});
  factory NoiDenModel.fromJson(Map<String, dynamic> json) {
    return NoiDenModel(id: json["id"].toString(), noiDen: json["noiDen"], bienSo: json["bienSo"]);
  }
}
