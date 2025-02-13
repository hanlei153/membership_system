class Transactions {
  final int? id;
  final int memberId;
  final String memberName;
  final String type;
  double amount;
  int timestamp;
  final String note;

  Transactions(
      {required this.id,
      required this.memberId,
      required this.memberName,
      required this.type,
      required this.amount,
      required this.timestamp,
      required this.note});

  Map<String, dynamic> toMap({bool includeId = true}) {
    final map = {
      'id': id,
      'memberId': memberId,
      'memberName': memberName,
      'type': type,
      'amount': amount,
      'timestamp': timestamp,
      'note': note
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
      memberId: map['memberId'] ?? 0,
      memberName: map['memberName']?? '',
      type: map['type'],
      amount: map['amount'],
      timestamp: map['timestamp'],
      note: map['note'] ?? ''
    );
  }
}
