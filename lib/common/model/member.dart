class Member {
  final int? id;
  final String name;
  final String phone;
  double balance;
  double giftBalance;
  int points;
  String password;
  int timestamp;

  Member(
      {required this.id,
      required this.name,
      required this.phone,
      required this.balance,
      required this.giftBalance,
      required this.points,
      required this.password,
      required this.timestamp});

  Map<String, dynamic> toMap({bool includeId = true}) {
    final map = {
      'id': id,
      'name': name,
      'phone': phone,
      'balance': balance,
      'giftBalance': giftBalance,
      'points': points,
      'password': password,
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
      giftBalance: map['giftBalance'],
      points: map['points'],
      password: map['password'],
      timestamp: map['timestamp']
    );
  }
}
