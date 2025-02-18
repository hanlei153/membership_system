class Transactions {
  final int? id;
  final int memberId;
  final String memberName;
  final String memberPhone;
  final String type;
  double amount;
  int isRefund;
  int timestamp;
  final String note;

  Transactions(
      {required this.id,
      required this.memberId,
      required this.memberName,
      required this.memberPhone,
      required this.type,
      required this.amount,
      required this.isRefund,
      required this.timestamp,
      required this.note});

  Map<String, dynamic> toMap({bool includeId = true}) {
    final map = {
      'id': id,
      'memberId': memberId,
      'memberName': memberName,
      'memberPhone': memberPhone,
      'type': type,
      'amount': amount,
      'isRefund': isRefund,
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
      memberPhone: map['memberPhone']?? '',
      type: map['type'],
      amount: map['amount'],
      isRefund: map['isRefund']?? 0,
      timestamp: map['timestamp'],
      note: map['note'] ?? ''
    );
  }
}
