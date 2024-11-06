class CheckSheetInfoModel {
  String? id;
  String? maCheckSheet;
  String? tenCheckSheet;
  String? fileUrl;
  double? width;
  double? height;

  CheckSheetInfoModel({
    this.id,
    this.maCheckSheet,
    this.tenCheckSheet,
    this.fileUrl,
    this.width,
    this.height,
  });
}

// lst_HangMucKiemTras
class CheckSheetModel {
  String? id;
  String? tenHangMucKiemTra;
  String? tenHangMucKiemTraEn;
  bool? isFileKetQua = false;
  bool? isNhapLoiHinhAnh = false;
  String? kieuDanhGiaId;
  bool? isThongSo = false;
  List<CheckSheetFileModel>? lstFiles = [];
  List<CheckSheetHinhAnhModel>? lstHinhAnhs = [];

  CheckSheetModel({
    this.id,
    this.tenHangMucKiemTra,
    this.tenHangMucKiemTraEn,
    this.isFileKetQua,
    this.isNhapLoiHinhAnh,
    this.kieuDanhGiaId,
    this.isThongSo,
    this.lstFiles,
    this.lstHinhAnhs,
  });
}

class CheckSheetFileModel {
  String? id;
  String? path;
  String? fileName;
  bool isRemoved = false;

  CheckSheetFileModel({
    this.id,
    this.path,
    this.fileName,
    required this.isRemoved,
  });
}

class CheckSheetHinhAnhModel {
  String? hangMucKiemTraId;
  String? hangMucKiemTraChiTietId;
  String? sanPhamKhuVucHinhAnhId;
  String? tenHinhAnh;
  String? urlHinhAnh;
  double? height;
  double? width;
  List<CheckSheetHinhAnhLoiModel> lstLois = [];

  CheckSheetHinhAnhModel({
    this.hangMucKiemTraId,
    this.hangMucKiemTraChiTietId,
    this.sanPhamKhuVucHinhAnhId,
    this.tenHinhAnh,
    this.urlHinhAnh,
    this.height,
    this.width,
    required this.lstLois,
  });
}

class CheckSheetHinhAnhLoiModel {
  String? id;
  int? stt;
  String? hangMucKiemTraId;
  String? sanPhamKhuVucHinhAnhId;
  double? toaDoX;
  double? toaDoY;
  double? r;
  String? loaiLoiId;
  String? maLoaiLoi;
  String? tenLoaiLoi;
  bool isSuaLoi = false;
  bool? isXacNhan = false;
  bool isRemoved = false;
  String? moTa;
  String? nguoiThucHienId;

  CheckSheetHinhAnhLoiModel({
    this.id,
    this.stt,
    this.hangMucKiemTraId,
    this.sanPhamKhuVucHinhAnhId,
    this.toaDoX,
    this.toaDoY,
    this.r,
    this.loaiLoiId,
    this.maLoaiLoi,
    this.tenLoaiLoi,
    required this.isSuaLoi,
    this.isXacNhan,
    required this.isRemoved,
    this.moTa,
    this.nguoiThucHienId,
  });
}
