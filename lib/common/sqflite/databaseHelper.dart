import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../model/user.dart';
import '../model/member.dart';
import '../model/transaction.dart';
import '../model/commodity.dart';
import '../model/commodityCategory.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  int currentTime = (DateTime.now().millisecondsSinceEpoch / 1000).round();

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

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'membership.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE User (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT,
            password TEXT,
            name TEXT,
            phone TEXT,
            email TEXT,
            avatarUrl TEXT,
            timestamp INTEGER
          )
        ''');
        await db.insert('User', {
          'id': 1,
          'username': 'admin',
          'password': '123456',
          'name': '管理员',
          'phone': '110',
          'email': '110@qq.com',
          'avatarUrl': '',
          'timestamp': currentTime
        });
        await db.execute('''
          CREATE TABLE Member (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            phone TEXT,
            balance REAL,
            giftBalance REAL,
            points INTEGER,
            password TEXT,
            timestamp INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE Transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            memberId INTEGER,
            memberName TEXT,
            memberPhone TEXT,
            type TEXT,
            amount REAL,
            giftAmount REAL,
            isRefund INTEGER,
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
        'SELECT SUM(amount) AS total FROM Transactions WHERE timestamp BETWEEN ? AND ? AND type = ? AND isRefund =?',
        [startDate, endDate, '消费', 0]);
    return result[0]['total'] == null
        ? 0
        : (result[0]['total'] as double).toInt();
  }

  // 用户表
  Future<void> addUser(User user) async {
    final db = await database;
    await db.insert('User', user.toMap(includeId: false));
  }

  Future<void> delUser(User user) async {
    final db = await database;
    await db.delete('User', where: 'id =?', whereArgs: [user.id]);
  }

  Future<void> modifyUserAvatar(User user) async {
    final db = await database;
    await db.update('User', {"avatarUrl": user.avatarUrl},
        where: 'id =?', whereArgs: [user.id]);
  }

  Future<void> modifyUserPassword(User user) async {
    final db = await database;
    await db.update('User', {"password": user.password},
        where: 'id =?', whereArgs: [user.id]);
  }

  Future<User> searchUser(String username) async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('User', where: 'username =?', whereArgs: [username]);
    return User.fromMap(maps[0]);
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

  Future<void> modifyMember(Member member, name, phone, password) async {
    final db = await database;
    Map<String, dynamic> messageMap = {};
    if (name != '') {
      messageMap['name'] = name;
    }
    if (phone != '') {
      messageMap['phone'] = phone;
    }
    if (password != '') {
      messageMap['password'] = password;
    }
    await db
        .update('Member', messageMap, where: 'id = ?', whereArgs: [member.id]);
  }

  Future<Member> getMember(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('Member', where: 'id =?', whereArgs: [id]);
    return Member.fromMap(maps[0]);
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

  // 交易表
  Future<void> addTransactions(Transactions transactions) async {
    final db = await database;
    await db.insert('Transactions', transactions.toMap(includeId: false));
  }

  Future<List<Transactions>> searchTranscations(String searchConditions) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Transactions',
        where: 'memberName LIKE ? OR memberPhone LIKE ?',
        whereArgs: ['%$searchConditions%', '%$searchConditions%']);
    return List.generate(maps.length, (i) => Transactions.fromMap(maps[i]));
  }

  // 退款
  Future<void> updateTransaction(int transactionId, int isRefund) async {
    final db = await database;
    await db.update('Transactions', {"isRefund": isRefund},
        where: 'id = ?', whereArgs: [transactionId]);
  }

  Future<void> refundBalancePoints(
      int memberId, double amount, double giftAmount) async {
    final db = await database;
    Member member = await getMember(memberId);
    await db.update(
        'Member',
        {
          'balance': member.balance + amount,
          'points': (member.points - amount).round(),
          'giftBalance': member.giftBalance + giftAmount
        },
        where: 'id =?',
        whereArgs: [memberId]);
  }

  Future<List<Transactions>> getTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('Transactions', orderBy: 'timestamp DESC');
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

  Future<void> delCommoditys() async {
    final db = await database;
    await db.delete('Commoditys');
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

  // 充值
  Future<void> updateMemberBalance(Member member, double amount) async {
    final db = await database;
    await db.update('Member', member.toMap(),
        where: 'id = ?', whereArgs: [member.id]);
  }

  // 消费
  Future<dynamic> updateBalanceAndPoints(
      Member member, double amount, String note) async {
    final db = await database;
    var balance = member.balance;
    var giftBalance = member.giftBalance;
    var totalAmount = amount;
    if (giftBalance > amount) {
      giftBalance -= amount;
      await db.update(
          'Member', {'balance': balance, 'giftBalance': giftBalance},
          where: 'id =?', whereArgs: [member.id]);
      return {
        "status": "success",
        "message": "消费成功",
        'balance': 0.0,
        'giftBalance': amount
      };
    } else {
      amount -= giftBalance;
      if (balance < amount) {
        return {"status": "fail", "message": "余额不足"};
      } else {
        balance -= amount;
        giftBalance = 0.0;
        await db.update(
            'Member',
            {
              'balance': balance,
              'giftBalance': giftBalance,
              'points':
                  (member.points + (totalAmount - member.giftBalance)).round()
            },
            where: 'id =?',
            whereArgs: [member.id]);
        return {
          "status": "success",
          "message": "消费成功",
          'balance': totalAmount - member.giftBalance,
          'giftBalance': member.giftBalance
        };
      }
    }
  }
}
