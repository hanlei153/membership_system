import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';

import '../sqflite/databaseHelper.dart';
import '../model/member.dart';

Future<void> exportMembers(String directoryPath) async {
  final dbHelper = DatabaseHelper();
  var excel = Excel.createExcel();
  Sheet sheet = excel['Sheet1'];

  try {
    // 1. 添加表头（优化列名顺序）
    _addHeaderRow(sheet);

    // 2. 获取数据
    final members = await dbHelper.getMembers();

    // 3. 批量添加数据行（减少循环内计算）
    for (var member in members) {
      _addMemberRow(sheet, member);
    }

    // 4. 保存文件（增加路径检查）
    final file = File('${directoryPath}/membersInfo.xlsx');
    await file.create(recursive: true); // 确保目录存在
    await file.writeAsBytes(excel.encode()!);

    print('导出成功: ${file.path}');
  } catch (e) {
    print('导出失败: $e');
    throw Exception('导出过程中出现错误'); // 抛出异常供上层处理
  }
}

// 提取表头生成方法
void _addHeaderRow(Sheet sheet) {
  sheet.appendRow([
    TextCellValue('姓名'),
    TextCellValue('电话'),
    TextCellValue('余额'),
    TextCellValue('赠送余额'),
    TextCellValue('积分'),
    TextCellValue('密码'),
    TextCellValue('创建时间'),
  ]);
}

// 提取数据行生成方法
void _addMemberRow(Sheet sheet, Member member) {
  final date =
      DateTime.fromMillisecondsSinceEpoch(member.timestamp * 1000).toLocal();

  sheet.appendRow([
    TextCellValue(member.name),
    TextCellValue(member.phone),
    TextCellValue(member.balance.toStringAsFixed(2)),
    TextCellValue(member.giftBalance.toStringAsFixed(2)),
    TextCellValue(member.points.toString()),
    TextCellValue(member.password),
    TextCellValue(_formatDateTime(date)),
  ]);
}

// 使用 DateFormat 优化日期格式化
String _formatDateTime(DateTime date) {
  return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
}

Future<void> importMembers(filePath) async {
  final dbHelper = DatabaseHelper();
  final file = File(filePath);

  try {
    if (await file.exists()) {
    var bytes = await file.readAsBytes();
    var excel = Excel.decodeBytes(bytes);
    for (var table in excel.tables.keys) {
      // 跳过第一行（表头），从第二行开始遍历
      bool isFirstRow = true;
      var sheet = excel.tables[table];
      for (var row in sheet!.rows) {
        if (isFirstRow) {
          isFirstRow = false; // 跳过第一行
          continue; // 跳过表头
        }
        final Map<String, dynamic> memberData = {
          'id': 0,
          'name': row[0]?.value.toString() ?? '',
          'phone': row[1]?.value.toString() ?? '',
          'balance': double.parse(row[2]?.value.toString() ?? '0.0'),
          'giftBalance': double.parse(row[3]?.value.toString() ?? '0.0'),
          'points': int.parse(row[4]?.value.toString() ?? '0'),
          'password': row[5]?.value.toString() ?? '',
          'timestamp': (DateTime.now().millisecondsSinceEpoch / 1000).round(),
        };
        await dbHelper.addMember(Member.fromMap(memberData));
      }
    }
  }
  } catch (e) {
    print(e);
  }
}
