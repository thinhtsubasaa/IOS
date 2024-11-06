class LSX_GiaoXeModel {
  String? id;
  String? soKhung;
  String? loaiXe;
  String? soMay;
  String? mauXe;
  String? yeuCau;
  String? noiGiao;
  String? bienSo;
  String? taiXe;
  String? gioNhan;
  String? donVi;
  String? ngay;
  String? nguoiPhuTrach;
  bool? isNew;
  String? liDoHuyXe;

  LSX_GiaoXeModel({this.id, this.soKhung, this.soMay, this.mauXe, this.noiGiao, this.bienSo, this.taiXe, this.loaiXe, this.gioNhan, this.ngay, this.donVi, this.nguoiPhuTrach, this.isNew, this.liDoHuyXe});
  factory LSX_GiaoXeModel.fromJson(Map<String, dynamic> json) {
    return LSX_GiaoXeModel(
        id: json["id"].toString(),
        soKhung: json["soKhung"],
        soMay: json["soMay"],
        mauXe: json["mauXe"],
        noiGiao: json["noiGiao"],
        gioNhan: json["gioNhan"],
        loaiXe: json["loaiXe"],
        donVi: json["donVi"],
        nguoiPhuTrach: json["nguoiPhuTrach"],
        isNew: json["isNew"],
        liDoHuyXe: json["liDoHuyXe"],
        ngay: json["ngay"]);
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'soKhung': soKhung,
        'soMay': soMay,
        'mauXe': mauXe,
        'noiGiao': noiGiao,
        'gioNhan': gioNhan,
        'loaiXe': loaiXe,
        'donVi': donVi,
        'nguoiPhuTrach': nguoiPhuTrach,
        'isNew': isNew,
        'ngay': ngay,
        'liDoHuyXe': liDoHuyXe
      };
}
