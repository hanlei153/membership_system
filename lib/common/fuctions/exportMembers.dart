import 'dart:convert';
import 'dart:io';

import '../sqflite/databaseHelper.dart';
import '../model/member.dart';

Future<void> exportMembers(directoryPath) async {
  final dbHelper = DatabaseHelper();
  final members = await dbHelper.getMembers();
  final jsonString = jsonEncode(members.map((m) => m.toMap()).toList());
  final file = File('$directoryPath/membersInfo.json');
  await file.writeAsString(jsonString);
}

Future<void> importMembers(filePath) async {
  final file = File('$filePath');

  if (await file.exists()) {
    final jsonString = await file.readAsString();
    final List<dynamic> jsonList = jsonDecode(jsonString);

    final dbHelper = DatabaseHelper();
    for (var map in jsonList) {
      await dbHelper.addMember(Member.fromMap(map));
    }
  }
}
