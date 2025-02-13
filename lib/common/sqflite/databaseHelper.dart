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
            points INTEGER,
            timestamp INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE Transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            MemberId INTEGER,
            memberName TEXT,
            type TEXT,
            amount REAL,
            timestamp INTEGER,
            note TEXT,
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

  // 首页数据展示查询
  Future<int> searchAddMember(int startDate, int endDate) async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COUNT(id) AS total FROM Member WHERE timestamp BETWEEN ? AND ?',
        [startDate, endDate]);
    return result[0]['total'] == null ? 0 : result[0]['total'] as int;
  }

  Future<int> searchEarning(int startDate, int endDate) async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT SUM(amount) AS total FROM Transactions WHERE timestamp BETWEEN ? AND ? AND type = ?',
        [startDate, endDate, '消费']);
    return result[0]['total'] == null
        ? 0
        : (result[0]['total'] as double).toInt();
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

  // 交易表
  Future<void> addTransactions(Transactions transactions) async {
    final db = await database;
    await db.insert('Transactions', transactions.toMap(includeId: false));
  }

  Future<List<Transactions>> getTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Transactions', orderBy: 'timestamp DESC');
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
    await db.insert(
        'CommodityCategorys', categoryCategory.toMap(includeId: false));
  }

  Future<void> delCommodityCategorys(
      CommodityCategorys commodityCategory) async {
    final db = await database;
    await db.delete('CommodityCategorys',
        where: 'id = ?', whereArgs: [commodityCategory.id]);
  }

  Future<void> modityCommodityCategorys(
      int categoryCategoryId, String name) async {
    final db = await database;
    await db.update('CommodityCategorys', {"name": name},
        where: 'id = ?', whereArgs: [categoryCategoryId]);
  }

  Future<List<CommodityCategorys>> getCommodityCategorys(
      {String name = ''}) async {
    final db = await database;
    List<Map<String, dynamic>> maps;
    if (name.isEmpty) {
      maps = await db.query('CommodityCategorys');
    } else {
      maps = await db
          .query('CommodityCategorys', where: 'name = ?', whereArgs: [name]);
    }
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
    await db.delete('Commoditys', where: "id = ?", whereArgs: [commodity.id]);
  }

  Future<void> modityCommoditys(Commoditys commodity) async {
    final db = await database;
    await db.update(
        'Commoditys', {"name": commodity.name, "price": commodity.price},
        where: 'id = ?', whereArgs: [commodity.id]);
  }

  Future<List<Commoditys>> getCommodity({int commodityCategoryId = 0}) async {
    final db = await database;
    List<Map<String, dynamic>> maps;
    if (commodityCategoryId == 0) {
      maps = await db.query('Commoditys');
    } else {
      maps = await db.query('Commoditys',
          where: 'CommodityCategoryId = ?', whereArgs: [commodityCategoryId]);
    }
    return List.generate(maps.length, (i) => Commoditys.fromMap(maps[i]));
  }

  // 消费
  Future<dynamic> updateBalanceAndPoints(Member member, double amount, String note) async {
    final db = await database;
    final newTransaction = Transactions(
      id: 0,
      memberId: member.id!,
      memberName: member.name,
      type: '消费',
      amount: amount,
      timestamp: (DateTime.now().millisecondsSinceEpoch / 1000).round(),
      note: note,
    );
    var balance = await db.query(
      'Member',
      columns: ['balance'],
      where: 'id =?',
      whereArgs: [member.id],
    );
    if ((balance[0]['balance'] as double) < amount) {
      return {"status": "fail", "message": "余额不足"};
    } else {
      await db.update(
          'Member',
          {
            'balance': member.balance - amount,
            'points': member.points + amount,
          },
          where: 'id =?',
          whereArgs: [member.id]);
      await addTransactions(newTransaction);
      return {"status": "success", "message": "消费成功"};
    }
  }
}
