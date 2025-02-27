class Commoditys {
  final int? id;
  final int? commodityCategoryId;
  final String name;
  final String picUrl;
  double price;

  Commoditys(
      {required this.id,
      required this.commodityCategoryId,
      required this.name,
      required this.picUrl,
      required this.price});

  Map<String, dynamic> toMap({bool includeId = true}) {
    final map = {
      'id': id,
      "commodityCategoryId": commodityCategoryId,
      'name': name,
      'picUrl': picUrl,
      'price': price
    };
    // 如果 includeId 为 false，则删除 id 字段
    if (includeId == false) {
      map.remove('id');
    }
    return map;
  }

  static Commoditys fromMap(Map<String, dynamic> map) {
    return Commoditys(
      id: map['id'],
      commodityCategoryId: map['commodityCategoryId'],
      name: map['name'],
      picUrl: map['picUrl'],
      price: map['price']
    );
  }
}
