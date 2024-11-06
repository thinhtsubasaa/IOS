class LSXDongContModel {
  String? id;
  String? soCont;
  String? soSeal;
  String? soKhung;
  String? loaiXe;
  String? soMay;
  String? mauXe;
  String? yeuCau;
  String? noiGiao;
  String? bienSo;
  String? gioNhan;

  LSXDongContModel(
      {this.id,
      this.soCont,
      this.soSeal,
      this.soKhung,
      this.soMay,
      this.mauXe,
      this.yeuCau,
      this.noiGiao,
      this.bienSo,
      this.loaiXe,
      this.gioNhan});
  factory LSXDongContModel.fromJson(Map<String, dynamic> json) {
    return LSXDongContModel(
      id: json["id"].toString(),
      soCont: json["soCont"],
      soSeal: json["soSeal"],
      soKhung: json["soKhung"],
      soMay: json["soMay"],
      mauXe: json["mauXe"],
      yeuCau: json["yeuCau"],
      noiGiao: json["noiGiao"],
      bienSo: json["bienSo"],
      gioNhan: json["gioNhan"],
      loaiXe: json["loaiXe"],
    );
  }
}
