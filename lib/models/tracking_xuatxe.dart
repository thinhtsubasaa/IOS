class TrackingXuatXeModel {
  String? id;
  String? ngay;
  String? thongtinvanchuyen;
  String? thongTinChiTiet;
  String? toaDo;
  String? thongtinMap;
  String? nguoiPhuTrach;

  TrackingXuatXeModel(
      {this.id,
      this.ngay,
      this.thongtinvanchuyen,
      this.thongTinChiTiet,
      this.toaDo,
      this.thongtinMap,
      this.nguoiPhuTrach});
  factory TrackingXuatXeModel.fromJson(Map<String, dynamic> json) {
    return TrackingXuatXeModel(
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
