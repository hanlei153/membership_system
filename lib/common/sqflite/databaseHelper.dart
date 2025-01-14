import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../model/member.dart';
import '../model/transaction.dart';
import '../model/commodity.dart';
import '../model/commodityCategory.dart';

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

  // 打印表
  Future<void> printTables() async {
    final db = await database;
    final tables =
        await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
    print('Existing tables: $tables');
  }

  // 删除数据库文件
  Future<void> clearDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'membership.db');
    await deleteDatabase(path);
    print('Database cleared');
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
        await db.execute('''
          CREATE TABLE Transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            MemberId INTEGER,
            type TEXT,
            amount REAL,
            timestamp INTEGER,
            FOREIGN KEY (memberId) REFERENCES Member (id)
          )
        ''');
        await db.execute('''
          CREATE TABLE CommodityCategorys (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE Commoditys (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            CommodityCategoryId INTEGER,
            name TEXT,
            picUrl TEXT,
            price REAL,
            FOREIGN KEY (CommodityCategoryId) REFERENCES CommodityCategorys (id)
          )
        ''');
      },
    );
  }

  // 会员表
  Future<void> addMember(Member member) async {
    final db = await database;
    await db.insert('Member', member.toMap(includeId: false));
  }

  Future<void> delMember(Member member) async {
    final db = await database;
    await db.delete('Member', where: 'id = ?', whereArgs: [member.id]);
  }

  Future<void> modifyMember(Member member, name, phone) async {
    final db = await database;
    await db.update('Member', {"name": name, "phone": phone},
        where: 'id = ?', whereArgs: [member.id]);
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

  // 交易表
  Future<void> addTransactions(Transactions transactions) async {
    final db = await database;
    await db.insert('Transaction', transactions.toMap(includeId: false));
  }

  Future<List<Transactions>> getTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Transactions');
    return List.generate(maps.length, (i) => Transactions.fromMap(maps[i]));
  }

  Future<List<Transactions>> getMonthTransactions(int startTime, int endTime,
      {int? memberId}) async {
    String whereClause = 'timestamp BETWEEN ? AND ?';
    List<dynamic> whereArgs = [startTime, endTime];
    if (memberId != null) {
      whereClause += ' AND memberId ?';
      whereArgs.add(memberId);
    }
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Transactions',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => Transactions.fromMap(maps[i]));
  }

  // 商品表类目
  Future<void> addCommodityCategorys(
      CommodityCategorys categoryCategory) async {
    final db = await database;
    await db.insert('CommodityCategorys', categoryCategory.toMap(includeId: false));
  }

  Future<void> delCommodityCategorys(
      CommodityCategorys categoryCategory) async {
    final db = await database;
    await db.delete('CommodityCategorys',
        where: 'id = ?', whereArgs: [categoryCategory.id]);
  }

  Future<List<CommodityCategorys>> getCommodityCategorys() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('CommodityCategorys');
    return List.generate(
        maps.length, (i) => CommodityCategorys.fromMap(maps[i]));
  }

  // 商品表
  Future<void> addCommodity(Commoditys commodity) async {
    final db = await database;
    await db.insert('Commoditys', commodity.toMap(includeId: false));
  }

  Future<void> delCommodity(Commoditys commodity) async {
    final db = await database;
    await db.insert('Commoditys', commodity.toMap(includeId: false));
  }
}
