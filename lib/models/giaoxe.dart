class GiaoXeModel {
  String? key;
  String? id;
  String? soKhung;
  String? maSanPham;
  String? tenSanPham;
  String? maMau;
  String? tenMau;
  String? maKho;
  String? tenKho;
  String? maViTri;
  String? tenViTri;
  String? mauSon;
  String? soMay;
  String? lat;
  String? long;
  String? toaDo;
  String? ngayNhapKhoView;
  String? tenTaiXe;
  String? ghiChu;
  String? kho_Id;
  String? bienSo_Id;
  String? taiXe_Id;
  String? nguoiNhan;
  String? tenDiaDiem;
  String? tenPhuongThucVanChuyen;
  String? noigiao;
  bool? dangDiChuyen;
  String? hinhAnh;
  List<FileDinhKems>? fileDinhKems;

  GiaoXeModel(
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
      this.bienSo_Id,
      this.kho_Id,
      this.taiXe_Id,
      this.nguoiNhan,
      this.fileDinhKems,
      this.tenDiaDiem,
      this.hinhAnh,
      this.tenPhuongThucVanChuyen,
      this.toaDo,
      this.noigiao,
      this.dangDiChuyen});

  factory GiaoXeModel.fromJson(Map<String, dynamic> json) {
    return GiaoXeModel(
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
      taiXe_Id: json["taiXe_Id"],
      kho_Id: json["kho_Id"],
      lat: json["lat"],
      long: json["long"],
      nguoiNhan: json["nguoiNhan"],
      tenDiaDiem: json["tenDiaDiem"],
      toaDo: json["toaDo"],
      tenPhuongThucVanChuyen: json["tenPhuongThucVanChuyen"],
      noigiao: json["noigiao"],
      dangDiChuyen: json["dangDiChuyen"],
      hinhAnh: json["hinhAnh"],
      fileDinhKems: (json['phuKien'] as List)
          .map((e) => FileDinhKems.fromJson(e))
          .toList(),
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
        "maKho": maKho,
        "kho_Id": kho_Id,
        "bienSo_Id": bienSo_Id,
        "taiXe_Id": taiXe_Id,
        "lat": lat,
        "long": long,
        "nguoiNhan": nguoiNhan,
        "tenPhuongThucVanChuyen": tenPhuongThucVanChuyen,
        "tenDiaDiem": tenDiaDiem,
        "toaDo": toaDo,
        "noigiao": noigiao,
        "hinhAnh": hinhAnh,
      };
}

class FileDinhKems {
  String? fileName;
  String? fileLink;
  String? fileData;
  String? name;
  String? url;

  FileDinhKems(
      {this.fileName, this.fileLink, this.fileData, this.name, this.url});

  @override
  String toString() {
    return 'GiaoXeModel(fileName: $fileName)';
  }

  factory FileDinhKems.fromJson(Map<String, dynamic> json) {
    return FileDinhKems(
        fileName: json['fileName'],
        fileLink: json['fileLink'],
        fileData: json['fileData'],
        name: json['name'],
        url: json['url']);
  }
}
