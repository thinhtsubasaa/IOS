class XuatKhoModel {
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
  String? tenDiaDiem;
  String? tenPhuongThucVanChuyen;
  String? tenLoaiPhuongTien;
  String? tenPhuongTien;
  String? noidi;
  String? noiden;
  String? benVanChuyen;
  String? soXe;
  String? maSoNhanVien;
  bool? dangDiChuyen;
  String? nguoiPhuTrach;
  String? hinhAnh;

  XuatKhoModel(
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
      this.tenDiaDiem,
      this.tenPhuongThucVanChuyen,
      this.tenLoaiPhuongTien,
      this.tenPhuongTien,
      this.toaDo,
      this.benVanChuyen,
      this.soXe,
      this.maSoNhanVien,
      this.noidi,
      this.noiden,
      this.dangDiChuyen,
      this.hinhAnh,
      this.nguoiPhuTrach});

  factory XuatKhoModel.fromJson(Map<String, dynamic> json) {
    return XuatKhoModel(
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
      bienSo_Id: json["bienSo_Id"],
      kho_Id: json["kho_Id"],
      tenDiaDiem: json["tenDiaDiem"],
      tenPhuongThucVanChuyen: json["tenPhuongThucVanChuyen"],
      tenLoaiPhuongTien: json["tenLoaiPhuongTien"],
      tenPhuongTien: json["tenPhuongTien"],
      toaDo: json["viTri"],
      noidi: json["noidi"],
      noiden: json["noiden"],
      benVanChuyen: json["benVanChuyen"],
      soXe: json["soXe"],
      maSoNhanVien: json["maSoNhanVien"],
      dangDiChuyen: json["dangDiChuyen"],
      nguoiPhuTrach: json["nguoiPhuTrach"],
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
        "maKho": maKho,
        "kho_Id": kho_Id,
        "bienSo_Id": bienSo_Id,
        "taiXe_Id": taiXe_Id,
        "tenDiaDiem": tenDiaDiem,
        "tenPhuongThucVanChuyen": tenPhuongThucVanChuyen,
        "tenLoaiPhuongTien": tenLoaiPhuongTien,
        "tenPhuongTien": tenPhuongTien,
        "viTri": toaDo,
        "noidi": noidi,
        "noiden": noiden,
        "benVanChuyen": benVanChuyen,
        "soXe": soXe,
        "maSoNhanVien": maSoNhanVien,
        "nguoiPhuTrach": nguoiPhuTrach,
        "hinhAnh": hinhAnh,
      };
}
