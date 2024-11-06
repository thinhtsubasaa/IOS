class LSXeQuaModel {
  String? id;
  String? ngayNhan;
  String? noiNhan;
  String? nguoiNhan;
  String? toaDo;

  LSXeQuaModel(
      {this.id, this.ngayNhan, this.nguoiNhan, this.noiNhan, this.toaDo});
  factory LSXeQuaModel.fromJson(Map<String, dynamic> json) {
    return LSXeQuaModel(
      id: json["id"].toString(),
      ngayNhan: json["ngayNhan"],
      nguoiNhan: json["nguoiNhan"],
      noiNhan: json["noiNhan"],
      toaDo: json["toaDo"],
    );
  }
}
