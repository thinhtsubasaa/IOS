class LSDongContModel {
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
  String? taiXe;
  String? gioNhan;
  String? ngay;

  LSDongContModel(
      {this.id,
      this.soCont,
      this.soSeal,
      this.soKhung,
      this.soMay,
      this.mauXe,
      this.yeuCau,
      this.noiGiao,
      this.bienSo,
      this.taiXe,
      this.loaiXe,
      this.ngay,
      this.gioNhan});
  factory LSDongContModel.fromJson(Map<String, dynamic> json) {
    return LSDongContModel(
      id: json["id"].toString(),
      soCont: json["soCont"],
      soSeal: json["soSeal"],
      soKhung: json["soKhung"],
      soMay: json["soMay"],
      mauXe: json["mauXe"],
      yeuCau: json["yeuCau"],
      noiGiao: json["noiGiao"],
      bienSo: json["bienSo"],
      taiXe: json["taiXe"],
      gioNhan: json["gioNhan"],
      loaiXe: json["loaiXe"],
      ngay: json["ngay"],
    );
  }
}
