class LSXuatXeModel {
  String? id;
  String? ngay;
  String? thongtinvanchuyen;
  String? thongTinChiTiet;
  String? toaDo;
  String? thongtinMap;
  String? nguoiPhuTrach;

  LSXuatXeModel(
      {this.id,
      this.ngay,
      this.thongtinvanchuyen,
      this.thongTinChiTiet,
      this.toaDo,
      this.thongtinMap,
      this.nguoiPhuTrach});
  factory LSXuatXeModel.fromJson(Map<String, dynamic> json) {
    return LSXuatXeModel(
      id: json["id"].toString(),
      ngay: json["ngay"],
      thongtinvanchuyen: json["thongtinvanchuyen"],
      thongTinChiTiet: json["thongTinChiTiet"],
      toaDo: json["toaDo"],
      thongtinMap: json["thongtinMap"],
      nguoiPhuTrach: json["nguoiPhuTrach"],
    );
  }
}
