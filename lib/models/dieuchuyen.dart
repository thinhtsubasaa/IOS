class DieuChuyenModel {
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
  String? viTri;
  String? ngayNhapKhoView;
  String? tenTaiXe;
  String? ghiChu;
  String? khoDen_Id;
  String? baiXe_Id;
  String? viTri_Id;
  String? taiXe_Id;
  String? toaDo;
  String? hinhAnh;
  String? thoiGianBatDau;
  String? thoiGianKetThuc;
  String? nguoiPhuTrach;
  String? donVi;
  String? phuongThuc;
  bool? dangDiChuyen;

  DieuChuyenModel(
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
      this.baiXe_Id,
      this.viTri_Id,
      this.khoDen_Id,
      this.taiXe_Id,
      this.viTri,
      this.toaDo,
      this.thoiGianBatDau,
      this.thoiGianKetThuc,
      this.dangDiChuyen,
      this.nguoiPhuTrach,
      this.donVi,
      this.phuongThuc,
      this.hinhAnh});

  factory DieuChuyenModel.fromJson(Map<String, dynamic> json) {
    return DieuChuyenModel(
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
        khoDen_Id: json["khoDen_Id"],
        baiXe_Id: json["baiXe_Id"],
        viTri_Id: json["viTri_Id"],
        tenBaiXe: json["tenBaiXe"],
        taiXe_Id: json["taiXe_Id"],
        lat: json["lat"],
        long: json["long"],
        viTri: json["viTri"],
        toaDo: json["toaDo"],
        thoiGianBatDau: json["thoiGianBatDau"],
        thoiGianKetThuc: json["thoiGianKetThuc"],
        dangDiChuyen: json["dangDiChuyen"],
        nguoiPhuTrach: json["nguoiPhuTrach"],
        hinhAnh: json["hinhAnh"],
        phuongThuc: json["phuongThuc"],
        donVi: json["donVi"]);
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
        "khoDen_Id": khoDen_Id,
        "baiXe_Id": baiXe_Id,
        "viTri_Id": viTri_Id,
        "taiXe_Id": taiXe_Id,
        "tenBaiXe": tenBaiXe,
        "lat": lat,
        "long": long,
        "viTri": viTri,
        "toaDo": toaDo,
        "hinhAnh": hinhAnh,
        "donVi": donVi,
        "phuongThuc": phuongThuc,
      };
}
