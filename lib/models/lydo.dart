class LyDoModel {
  String? id;
  String? lyDo;

  LyDoModel({this.id, this.lyDo});
  factory LyDoModel.fromJson(Map<String, dynamic> json) {
    return LyDoModel(id: json["id"].toString(), lyDo: json["lyDo"]);
  }
}
