class KeHoachGiaoXeModel {
  String? id;
  String? soKhung;
  String? maSanPham;
  String? tenSanPham;
  String? maMau;
  String? tenMau;
  String? mauSon;
  String? soMay;
  String? lat;
  String? long;
  String? ngayNhapKhoView;
  String? tenTaiXe;
  String? ghiChu;
  String? kho_Id;
  String? Diadiem_Id;
  String? phuongThucVanChuyen_Id;
  String? bienSo_Id;
  String? taiXe_Id;
  String? tenDiaDiem;
  String? tenPhuongThucVanChuyen;
  String? benVanChuyen;
  String? soXe;
  String? maSoNhanVien;

  KeHoachGiaoXeModel(
      {this.id,
      this.maMau,
      this.mauSon,
      this.maSanPham,
      this.lat,
      this.long,
      this.soKhung,
      this.tenSanPham,
      this.tenMau,
      this.soMay,
      this.ngayNhapKhoView,
      this.tenTaiXe,
      this.ghiChu,
      this.Diadiem_Id,
      this.bienSo_Id,
      this.kho_Id,
      this.phuongThucVanChuyen_Id,
      this.taiXe_Id,
      this.tenDiaDiem,
      this.tenPhuongThucVanChuyen,
      this.benVanChuyen,
      this.soXe,
      this.maSoNhanVien});

  factory KeHoachGiaoXeModel.fromJson(Map<String, dynamic> json) {
    return KeHoachGiaoXeModel(
      id: json["id"],
      soKhung: json["soKhung"],
      maSanPham: json["maSanPham"],
      tenSanPham: json["tenSanPham"],
      soMay: json["soMay"],
      maMau: json["maMau"],
      tenMau: json["tenMau"],
      mauSon: json["mauSon"],
      ngayNhapKhoView: json["ngayNhapKhoView"],
      tenTaiXe: json["tenTaiXe"],
      ghiChu: json["ghiChu"],
      taiXe_Id: json["taiXe_Id"],
      bienSo_Id: json["bienSo_Id"],
      phuongThucVanChuyen_Id: json["phuongThucVanChuyen_Id"],
      Diadiem_Id: json["Diadiem_Id"],
      kho_Id: json["kho_Id"],
      lat: json["lat"],
      long: json["long"],
      tenDiaDiem: json["tenDiaDiem"],
      tenPhuongThucVanChuyen: json["tenPhuongThucVanChuyen"],
      benVanChuyen: json["benVanChuyen"],
      soXe: json["soXe"],
      maSoNhanVien: json["maSoNhanVien"],
    );
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'soKhung': soKhung,
        'maSanPham': maSanPham,
        'tenSanPham': tenSanPham,
        'soMay': soMay,
        'maMau': maMau,
        'tenMau': tenMau,
        'mauSon': mauSon,
        'ngayNhapKhoView': ngayNhapKhoView,
        "kho_Id": kho_Id,
        "Diadiem_Id": Diadiem_Id,
        "phuongThucVanChuyen_Id": phuongThucVanChuyen_Id,
        "bienSo_Id": bienSo_Id,
        "taiXe_Id": taiXe_Id,
        "lat": lat,
        "long": long,
        "tenDiaDiem": tenDiaDiem,
        "tenPhuongThucVanChuyen": tenPhuongThucVanChuyen,
        "benVanChuyen": benVanChuyen,
        "soXe": soXe,
        "maSoNhanVien": maSoNhanVien,
      };
}
