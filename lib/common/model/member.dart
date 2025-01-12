class Member {
  final int id;
  final String name;
  final String phone;
  double balance;
  int points;

  Member(
      {required this.id,
      required this.name,
      required this.phone,
      required this.balance,
      required this.points});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'balance': balance,
      'points': points,
    };
  }

  static Member fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      balance: map['balance'],
      points: map['points'],
    );
  }
}
