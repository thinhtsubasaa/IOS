class ScanModel {
  String? key;
  String? id;
  String? soKhung;
  String? maSanPham;
  String? tenSanPham;
  String? maMau;
  String? tenMau;
  String? tenKho;
  String? maViTri;
  String? tenViTri;
  String? mauSon;
  String? soMay;
  String? ngayXuatKhoView;
  String? ngayNhapKhoView;
  String? tenTaiXe;
  String? ghiChu;
  String? Kho_Id;
  String? BaiXe_Id;
  String? viTri_Id;
  String? toaDo;

  List<PhuKien>? phuKien;

  ScanModel({
    this.key,
    this.id,
    this.maMau,
    this.mauSon,
    this.maViTri,
    this.tenViTri,
    this.Kho_Id,
    this.BaiXe_Id,
    this.viTri_Id,
    this.maSanPham,
    this.soKhung,
    this.tenSanPham,
    this.tenMau,
    this.tenKho,
    this.soMay,
    this.ngayXuatKhoView,
    this.ngayNhapKhoView,
    this.tenTaiXe,
    this.ghiChu,
    this.phuKien,
    this.toaDo,
  });

  factory ScanModel.fromJson(Map<String, dynamic> json) {
    return ScanModel(
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
      ngayXuatKhoView: json["ngayXuatKhoView"],
      ngayNhapKhoView: json["ngayNhapKhoView"],
      tenTaiXe: json["tenTaiXe"],
      ghiChu: json["ghiChu"],
      Kho_Id: json["Kho_Id"],
      BaiXe_Id: json["BaiXe_Id"],
      viTri_Id: json["viTri_Id"],
      toaDo: json["toaDo"],
      phuKien:
          (json['phuKien'] as List).map((e) => PhuKien.fromJson(e)).toList(),
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
        'toaDo': toaDo,
      };
}

class PhuKien {
  String? phuKien_Id;
  String? giaTri;
  String? tenPhuKien;

  PhuKien({
    this.phuKien_Id,
    this.giaTri,
    this.tenPhuKien,
  });
  @override
  String toString() {
    return 'ScanModel(phuKien_Id: $phuKien_Id, giaTri: $giaTri, tenPhuKien: $tenPhuKien)';
  }

  factory PhuKien.fromJson(Map<String, dynamic> json) {
    return PhuKien(
      phuKien_Id: json['phuKien_Id'],
      giaTri: json['giaTri'],
      tenPhuKien: json['tenPhuKien'],
    );
  }
}
