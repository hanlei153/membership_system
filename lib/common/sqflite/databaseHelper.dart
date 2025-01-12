import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../model/member.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'membership.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE Member (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            phone TEXT,
            balance REAL,
            points INTEGER
          )
        ''');
      },
    );
  }

  Future<void> addMember(Member member) async {
    final db = await database;
    await db.insert('Member', member.toMap());
  }

  Future<List<Member>> getMembers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Member');
    return List.generate(maps.length, (i) => Member.fromMap(maps[i]));
  }

  Future<List<Member>> searchMembers(String searchConditions) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Member',
        where: 'name LIKE ? OR phone LIKE ?',
        whereArgs: ['%$searchConditions%', '%$searchConditions%']);
    return List.generate(maps.length, (i) => Member.fromMap(maps[i]));
  }

  // 充值
  Future<void> updateMemberBalance(Member member) async {
    final db = await database;
    await db.update('Member', member.toMap(),
        where: 'id = ?', whereArgs: [member.id]);
  }

  Future<void> updateBalanceAndPoints(Member member, double amount) async {
    final dbHelper = DatabaseHelper();
    // 从数据库中获取所有会员
    final members = await dbHelper.getMembers();
    // 找到与传入的会员id匹配的会员
    final dbMember = members.firstWhere((m) => m.id == member.id);
    // 更新余额和积分
    final newBalance = dbMember.balance - amount;
    final newPoints = dbMember.points + (amount ~/ 10); // 每消费10元积1分
    // 创建更新后的会员对象
    final updatedMember = Member(
      id: dbMember.id, // 使用从数据库获取的会员id
      name: dbMember.name,
      phone: dbMember.phone,
      balance: newBalance,
      points: newPoints,
    );
    // 更新数据库中的会员信息
    await dbHelper.updateMemberBalance(updatedMember);
  }
}
