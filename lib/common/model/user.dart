class User {
  int? id;
  String username;
  String password;
  String name;
  String phone;
  String email;
  String avatarUrl;
  int timestamp;

  // 构造函数
  User({
    this.id,
    required this.username,
    required this.password,
    required this.name,
    required this.phone,
    required this.email,
    this.avatarUrl = '',
    required this.timestamp,
  });

  // 将 User 对象转换为 Map
  Map<String, dynamic> toMap({bool includeId = true}) {
    var map = {
      'username': username,
      'password': password,
      'name': name,
      'phone': phone,
      'email': email,
      'avatarUrl': avatarUrl,
      'timestamp': timestamp,
    };
    if (includeId == false) {
      map.remove('id');
    }
    return map;
  }

  // 从 Map 中创建 User 对象
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      username: map['username'] as String,
      password: map['password'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String,
      avatarUrl: map['avatarUrl'] as String,
      timestamp: map['timestamp'] as int,
    );
  }
}
