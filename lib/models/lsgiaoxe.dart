class LSGiaoXeModel {
  String? id;
  String? ngay;
  String? noiGiao;
  String? soTBGX;
  String? toaDo;
  String? nguoiPhuTrach;

  LSGiaoXeModel(
      {this.id,
      this.ngay,
      this.noiGiao,
      this.soTBGX,
      this.toaDo,
      this.nguoiPhuTrach});
  factory LSGiaoXeModel.fromJson(Map<String, dynamic> json) {
    return LSGiaoXeModel(
      id: json["id"].toString(),
      ngay: json["ngay"],
      noiGiao: json["noiGiao"],
      soTBGX: json["soTBGX"],
      toaDo: json["toaDo"],
      nguoiPhuTrach: json["nguoiPhuTrach"],
    );
  }
}
