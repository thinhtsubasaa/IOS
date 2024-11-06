class VungMienModel {
  String? id;
  String? maVungMien;
  String? tenVungMien;
  String? parent_Id;

  VungMienModel({
    this.id,
    this.maVungMien,
    this.tenVungMien,
    this.parent_Id,
  });
  factory VungMienModel.fromJson(Map<String, dynamic> json) {
    return VungMienModel(
      id: json["id"].toString(),
      maVungMien: json["maVungMien"],
      tenVungMien: json["tenVungMien"],
      parent_Id: json["parent_Id"],
    );
  }
}
