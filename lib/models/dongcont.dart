class DongContModel {
  String? key;
  String? id;
  String? soKhung;
  String? maSanPham;
  String? tenSanPham;
  String? maMau;
  String? tenMau;
  String? maKho;
  String? tenKho;
  String? tenBaiXe;
  String? maViTri;
  String? tenViTri;
  String? mauSon;
  String? soMay;
  String? lat;
  String? long;
  String? ngayNhapKhoView;
  String? tenTaiXe;
  String? ghiChu;
  String? soCont;
  String? soSeal;
  String? khuVuc;
  String? toaDo;
  String? hinhAnh;
  String? tau;

  DongContModel(
      {this.key,
      this.id,
      this.maMau,
      this.mauSon,
      this.maViTri,
      this.tenViTri,
      this.maSanPham,
      this.lat,
      this.long,
      this.soKhung,
      this.tenSanPham,
      this.tenMau,
      this.tenKho,
      this.soMay,
      this.ngayNhapKhoView,
      this.tenTaiXe,
      this.ghiChu,
      this.maKho,
      this.tenBaiXe,
      this.soCont,
      this.soSeal,
      this.toaDo,
      this.khuVuc,
      this.tau,
      this.hinhAnh});

  factory DongContModel.fromJson(Map<String, dynamic> json) {
    return DongContModel(
        key: json["key"],
        id: json["id"],
        soKhung: json["soKhung"],
        maSanPham: json["maSanPham"],
        tenSanPham: json["tenSanPham"],
        soMay: json["soMay"],
        maMau: json["maMau"],
        tenMau: json["tenMau"],
        tenKho: json["tenKho"],
        maViTri: json["maViTri"],
        tenViTri: json["tenViTr"],
        mauSon: json["mauSon"],
        ngayNhapKhoView: json["ngayNhapKhoView"],
        tenTaiXe: json["tenTaiXe"],
        ghiChu: json["ghiChu"],
        maKho: json["maKho"],
        soCont: json["soCont"],
        soSeal: json["soSeal"],
        tenBaiXe: json["tenBaiXe"],
        lat: json["lat"],
        long: json["long"],
        toaDo: json["toaDo"],
        hinhAnh: json["hinhAnh"],
        tau: json["tau"],
        khuVuc: json["khuVuc"]);
  }
  Map<String, dynamic> toJson() => {
        'key': key,
        'id': id,
        'soKhung': soKhung,
        'maSanPham': maSanPham,
        'tenSanPham': tenSanPham,
        'soMay': soMay,
        'maMau': maMau,
        'tenMau': tenMau,
        'tenKho': tenKho,
        'maViTri': maViTri,
        'tenViTri': tenViTri,
        'mauSon': mauSon,
        'ngayNhapKhoView': ngayNhapKhoView,
        "maKho": maKho,
        "soCont": soCont,
        "soSeal": soSeal,
        "tenBaiXe": tenBaiXe,
        "lat": lat,
        "long": long,
        "toaDo": toaDo,
        "khuVuc": khuVuc,
        "hinhAnh": hinhAnh,
        "tau": tau,
      };
}
