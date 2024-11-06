class TimXeModel {
  String? key;
  String? id;
  String? soKhung;
  String? tenKho;
  String? tenBaiXe;
  String? tenViTri;
  String? toaDo;
  String? tenMau;
  String? tenSanPham;
  String? nguoiPhuTrach;
  String? donVi;
  List<DieuChuyen>? dieuChuyen;
  List<NhapKho>? nhapKho;

  TimXeModel({
    this.key,
    this.id,
    this.tenViTri,
    this.soKhung,
    this.tenKho,
    this.tenBaiXe,
    this.toaDo,
    this.nguoiPhuTrach,
    this.tenMau,
    this.tenSanPham,
    this.donVi,
    this.dieuChuyen,
    this.nhapKho,
  });

  factory TimXeModel.fromJson(Map<String, dynamic> json) {
    return TimXeModel(
      key: json["key"],
      id: json["id"],
      soKhung: json["soKhung"],
      tenKho: json["tenKho"],
      tenViTri: json["tenViTr"],
      tenBaiXe: json["tenBaiXe"],
      toaDo: json["toaDo"],
      tenMau: json["tenMau"],
      donVi: json["donVi"],
      tenSanPham: json["tenSanPham"],
      nguoiPhuTrach: json["nguoiPhuTrach"],
      dieuChuyen: (json['dieuChuyen'] as List<dynamic>?)
          ?.map((item) => DieuChuyen.fromJson(item))
          .toList(),
      nhapKho: (json['nhapKho'] as List<dynamic>?)
          ?.map((item) => NhapKho.fromJson(item))
          .toList(),
    );
  }
  Map<String, dynamic> toJson() => {
        'key': key,
        'id': id,
        'soKhung': soKhung,
        'tenKho': tenKho,
        'tenBaiXe': tenBaiXe,
        'tenViTri': tenViTri,
        'toaDo': toaDo,
        'nguoiPhuTrach': nguoiPhuTrach,
        'dieuChuyen': dieuChuyen?.map((item) => item.toJson()).toList(),
        'nhapKho': nhapKho?.map((item) => item.toJson()).toList(),
      };
}

class DieuChuyen {
  String? id;
  String? loaiXe;
  String? soKhung;
  String? noiDi;
  String? noiDen;
  String? nguoiNhapBai;
  String? gioNhan;

  DieuChuyen({
    this.id,
    this.loaiXe,
    this.soKhung,
    this.noiDi,
    this.noiDen,
    this.nguoiNhapBai,
    this.gioNhan,
  });

  factory DieuChuyen.fromJson(Map<String, dynamic> json) {
    return DieuChuyen(
      id: json['id'],
      loaiXe: json['loaiXe'],
      soKhung: json['soKhung'],
      noiDi: json['noiDi'],
      noiDen: json['noiDen'],
      nguoiNhapBai: json['nguoiNhapBai'],
      gioNhan: json['gioNhan'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'loaiXe': loaiXe,
        'soKhung': soKhung,
        'noiDi': noiDi,
        'noiDen': noiDen,
        'nguoiNhapBai': nguoiNhapBai,
        'gioNhan': gioNhan,
      };
}

class NhapKho {
  String? id;
  String? loaiXe;
  String? soKhung;
  String? noiDen;
  String? nguoiNhapBai;
  String? gioNhan;

  NhapKho({
    this.id,
    this.loaiXe,
    this.soKhung,
    this.noiDen,
    this.nguoiNhapBai,
    this.gioNhan,
  });

  factory NhapKho.fromJson(Map<String, dynamic> json) {
    return NhapKho(
      id: json['id'],
      loaiXe: json['loaiXe'],
      soKhung: json['soKhung'],
      noiDen: json['noiDen'],
      nguoiNhapBai: json['nguoiNhapBai'],
      gioNhan: json['gioNhan'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'loaiXe': loaiXe,
        'soKhung': soKhung,
        'noiDen': noiDen,
        'nguoiNhapBai': nguoiNhapBai,
        'gioNhan': gioNhan,
      };
}
