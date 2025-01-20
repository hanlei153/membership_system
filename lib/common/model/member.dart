class Member {
  final int? id;
  final String name;
  final String phone;
  double balance;
  int points;
  int timestamp;

  Member(
      {required this.id,
      required this.name,
      required this.phone,
      required this.balance,
      required this.points,
      required this.timestamp});

  Map<String, dynamic> toMap({bool includeId = true}) {
    final map = {
      'id': id,
      'name': name,
      'phone': phone,
      'balance': balance,
      'points': points,
      'timestamp': timestamp
    };
    // 如果 includeId 为 false，则删除 id 字段
    if (includeId == false) {
      map.remove('id');
    }
    return map;
  }

  static Member fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      balance: map['balance'],
      points: map['points'],
      timestamp: map['timestamp']
    );
  }
}
