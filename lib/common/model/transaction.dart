class Transactions {
  final int? id;
  final int memberId;
  final String type;
  double amount;
  int timestamp;

  Transactions(
      {required this.id,
      required this.memberId,
      required this.type,
      required this.amount,
      required this.timestamp});

  Map<String, dynamic> toMap({bool includeId = true}) {
    final map = {
      'id': id,
      'memberId': memberId,
      'type': type,
      'amount': amount,
      'timestamp': timestamp,
    };
    // 如果 includeId 为 false，则删除 id 字段
    if (includeId == false) {
      map.remove('id');
    }
    return map;
  }

  static Transactions fromMap(Map<String, dynamic> map) {
    return Transactions(
      id: map['id'],
      memberId: map['memberId'],
      type: map['type'],
      amount: map['amount'],
      timestamp: map['timestamp'],
    );
  }
}
