import 'dart:io';
import 'dart:async';
import 'package:window_size/window_size.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'pages/Login.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  // 确保 Flutter 绑定初始化，以便访问窗口相关功能
  WidgetsFlutterBinding.ensureInitialized();
  // 检查当前平台是否为桌面平台
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // 设置窗口大小和位置
    setWindowFrame(Rect.fromLTWH(0, 0, 1200, 700));
  }
  runApp(MyApp());
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
