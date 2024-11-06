class MenuRoleModel {
  String? id;
  String? tenMenu;
  String? url;
  // List<MenuRoleModel>? children;

  MenuRoleModel({
    this.id,
    this.tenMenu,
    this.url,
    // this.children,
  });

  factory MenuRoleModel.fromJson(Map<String, dynamic> json) {
    return MenuRoleModel(
      id: json["id"].toString(),
      tenMenu: json["tenMenu"],
      url: json["url"],
      // children: (json["children"] as List)
      //     .map((item) => MenuRoleModel.fromJson(item))
      //     .toList());
    );
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'tenMenu': tenMenu,
        'url': url,
      };
}
