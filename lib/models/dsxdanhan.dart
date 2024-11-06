class DS_DaNhanModel {
  String? id;
  String? loaiXe;
  String? soKhung;
  String? mauXe;
  String? nhaMay;
  String? nguoiNhan;
  String? gioNhan;
  String? ngay;

  DS_DaNhanModel(
      {this.id,
      this.loaiXe,
      this.soKhung,
      this.mauXe,
      this.nhaMay,
      this.gioNhan,
      this.ngay,
      this.nguoiNhan});

  factory DS_DaNhanModel.fromJson(Map<String, dynamic> json) {
    return DS_DaNhanModel(
      id: json["id"],
      loaiXe: json["loaiXe"],
      soKhung: json["soKhung"],
      mauXe: json["mauXe"],
      nguoiNhan: json["nguoiNhan"],
      nhaMay: json["nhaMay"],
      gioNhan: json["gioNhan"],
      ngay: json["ngay"],
    );
  }
}
