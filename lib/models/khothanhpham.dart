class KhoThanhPhamModel {
  String? key;
  String? id;
  String? soKhung;
  String? maSanPham;
  String? tenSanPham;
  String? maMau;
  String? tenMau;
  String? tenKho;
  String? maViTri;
  String? lat;
  String? long;
  String? tenViTri;
  String? mauSon;
  String? soMay;
  String? ngayNhapKhoView;
  String? tenTaiXe;
  String? ghiChu;
  String? Kho_Id;
  String? BaiXe_Id;
  String? viTri_Id;
  String? nguoiNhan;
  String? ngayNhan;
  String? toaDo;
  String? hinhAnh;

  KhoThanhPhamModel(
      {this.key,
      this.id,
      this.maMau,
      this.mauSon,
      this.maViTri,
      this.tenViTri,
      this.lat,
      this.long,
      this.Kho_Id,
      this.BaiXe_Id,
      this.viTri_Id,
      this.maSanPham,
      this.soKhung,
      this.tenSanPham,
      this.tenMau,
      this.tenKho,
      this.soMay,
      this.ngayNhapKhoView,
      this.tenTaiXe,
      this.ghiChu,
      this.nguoiNhan,
      this.hinhAnh,
      this.ngayNhan,
      this.toaDo});

  factory KhoThanhPhamModel.fromJson(Map<String, dynamic> json) {
    return KhoThanhPhamModel(
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
      Kho_Id: json["Kho_Id"],
      BaiXe_Id: json["BaiXe_Id"],
      viTri_Id: json["viTri_Id"],
      lat: json["lat"],
      long: json["long"],
      ngayNhan: json["ngayNhan"],
      nguoiNhan: json["nguoiNhan"],
      toaDo: json["toaDo"],
      hinhAnh: json["hinhAnh"],
    );
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
        'Kho_Id': Kho_Id,
        'BaiXe_Id': BaiXe_Id,
        'viTri_Id': viTri_Id,
        'lat': lat,
        'long': long,
        'toaDo': toaDo,
        'hinhAnh': hinhAnh,
      };
}
