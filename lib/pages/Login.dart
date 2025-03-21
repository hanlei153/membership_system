import 'mainframePage.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../common/fuctions/LogFilePrinter.dart';
import '../common/sqflite/databaseHelper.dart';
import '../common/model/user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController =
      TextEditingController(text: 'admin');
  final TextEditingController _passwordController =
      TextEditingController(text: '');
  var logger = Logger(
    printer: LogFilePrinter(),
    level: Level.verbose,
  );

  bool isLongPress = false;

  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
  }

  void _login() async {
    logger.i('调用登陆按钮！');
    try {
      String username = _usernameController.text;
      String password = _passwordController.text;

      User user = await dbHelper.searchUser(username);

      // 这里可以添加实际的登录逻辑，例如验证用户名和密码
      if (username == user.username && password == user.password) {
        logger.i('登陆成功！');
        // 登录成功，导航到主页面
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => MainFramePage(
                    title: '鲸储会员系统',
                    userInfo: user,
                  )),
        );
      } else {
        logger.e('用户名或密码错误！');
        // 登录失败，显示错误提示
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('用户名或密码错误')),
        );
      }
    } catch (e) {
      logger.e(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text('鲸储会员系统'),
            GestureDetector(
              onLongPressMoveUpdate: (details) async {
                if (!isLongPress) {
                  isLongPress = true;
                  // 重置密码
                  await dbHelper.resetPassword();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('管理员密码已重置为123456')),
                  );
                }
              },
              onLongPressEnd: (details) async {
                isLongPress = false;
              },
              child: const Text('  '),
            ),
          ],
        ),
      )),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: 350,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('账号：', style: TextStyle(fontSize: 18)),
                    Expanded(
                      child: TextField(
                        controller: _usernameController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('密码：', style: TextStyle(fontSize: 18)),
                    Expanded(
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        onSubmitted: (value) => _login(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _login,
                  child: const Text('登录'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
