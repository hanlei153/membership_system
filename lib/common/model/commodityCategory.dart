class CommodityCategorys {
  final int? id;
  final String name;
  bool isExpanded;

  CommodityCategorys(
      {required this.id,
      required this.name,
      this.isExpanded = false,
      });

  Map<String, dynamic> toMap({bool includeId = true}) {
    final map = {
      'id': id,
      'name': name
    };
    // 如果 includeId 为 false，则删除 id 字段
    if (includeId == false) {
      map.remove('id');
    }
    return map;
  }

  static CommodityCategorys fromMap(Map<String, dynamic> map) {
    return CommodityCategorys(
      id: map['id'],
      name: map['name']
    );
  }
}
