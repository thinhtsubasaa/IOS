class DoiTacModel {
  String? id;
  String? maDoiTac;
  String? tenDoiTac;

  DoiTacModel({
    this.id,
    this.maDoiTac,
    this.tenDoiTac,
  });
  factory DoiTacModel.fromJson(Map<String, dynamic> json) {
    return DoiTacModel(
      id: json["id"].toString(),
      maDoiTac: json["maDoiTac"],
      tenDoiTac: json["tenDoiTac"],
    );
  }
}
