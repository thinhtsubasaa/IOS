class BienSoModel {
  String? id;
  String? noiDen;
  String? bienSo;

  BienSoModel({this.id, this.noiDen, this.bienSo});
  factory BienSoModel.fromJson(Map<String, dynamic> json) {
    return BienSoModel(id: json["id"].toString(), noiDen: json["noiDen"], bienSo: json["bienSo"]);
  }
}
