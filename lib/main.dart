import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'pages/Login.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  // 捕获日志并写入文件
  final logFile = File('log.txt');
  runZonedGuarded(() async {
    runApp(MyApp());
  }, (error, stackTrace) async {
    final log = 'Error: $error\nStackTrace: $stackTrace\n';
    await logFile.writeAsString(log, mode: FileMode.append, flush: true);
  });

  // 捕获打印信息
  debugPrint = (String? message, {int? wrapWidth}) async {
    await logFile.writeAsString('$message\n',
        mode: FileMode.append, flush: true);
  };
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '会员系统',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(179, 58, 199, 255),
          // ···
          brightness: Brightness.light,
        ),
        textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 72,
        fontWeight: FontWeight.bold,
      ),
    ),
      ),
      home: const LoginPage(),
    );
  }
}
