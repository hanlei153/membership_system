import 'dart:io';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:contextmenu/contextmenu.dart';
import 'package:file_picker/file_picker.dart';
import 'package:membership_system/pages/Login.dart';

import 'package:membership_system/pages/commodityManage/commodityManagePage.dart';
import 'package:membership_system/pages/membersManage/memberListPage.dart';
import 'package:membership_system/pages/dataDisplay/dataDisplay.dart';
import 'package:membership_system/pages/home/homePage.dart';
import 'package:membership_system/common/model/user.dart';
import 'package:membership_system/common/sqflite/databaseHelper.dart';
import '../common/fuctions/LogFilePrinter.dart';


class MainFramePage extends StatefulWidget {
  const MainFramePage({super.key, required this.title, required this.userInfo});

  final String title;
  final User userInfo;

  @override
  State<MainFramePage> createState() => _MainFramePageState();
}

class _MainFramePageState extends State<MainFramePage> {
  final dbHelper = DatabaseHelper();
  var logger = Logger(printer: LogFilePrinter());
  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(fontSize: 14);
  double? iconSize = 20;
  double iconPadding = 10;
  final List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    MemberListPage(),
    CommodityManagePage(),
    DataDisplayPage(),
  ];

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      logger.d('导航：${_widgetOptions[_selectedIndex]}页');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Row(
        children: <Widget>[
          // 左侧导航栏
          NavigationRail(
            selectedIndex: _selectedIndex,
            elevation: 5,
            onDestinationSelected: _onItemTapped,
            labelType: NavigationRailLabelType.all,
            leading: ContextMenuArea(
              width: 150,
              builder: (context) => [
                ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('个人信息'),
                    onTap: () {
                      Navigator.pop(context);
                      _showPersonalInfo();
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('修改头像'),
                  onTap: () {
                    Navigator.pop(context);
                    // 处理头像修改逻辑
                    _selectAvatarFile();
                    // 更新数据库中的头像信息
                    dbHelper.modifyUserAvatar(widget.userInfo);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('修改密码'),
                  onTap: () {
                    Navigator.pop(context);
                    // 处理密码修改逻辑
                    _modifyPassword();
                  }
                ),
                ListTile(
                    leading: const Icon(Icons.exit_to_app),
                    title: const Text('退出'),
                    onTap: () {
                      Navigator.pop(context);
                      // 处理退出逻辑
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    })
              ],
              child: Column(
                children: [
                  CircleAvatar(
                      radius: 20,
                      backgroundImage: widget.userInfo.avatarUrl.isNotEmpty
                          ? FileImage(File(widget.userInfo.avatarUrl))
                          : const AssetImage('assets/images/avatar.png')),
                  const SizedBox(height: 5),
                  Text(widget.userInfo.username),
                ],
              ),
            ),
            destinations: [
              NavigationRailDestination(
                padding: EdgeInsets.only(top: iconPadding),
                icon: Icon(Icons.home, size: iconSize),
                label: const Text('首页', style: optionStyle),
              ),
              NavigationRailDestination(
                padding: EdgeInsets.only(top: iconPadding),
                icon: Icon(Icons.group, size: iconSize),
                label: const Text('会员管理', style: optionStyle),
              ),
              NavigationRailDestination(
                padding: EdgeInsets.only(top: iconPadding),
                icon: Icon(Icons.shopping_cart, size: iconSize),
                label: const Text('商品管理', style: optionStyle),
              ),
              NavigationRailDestination(
                padding: EdgeInsets.only(top: iconPadding),
                icon: Icon(Icons.receipt, size: iconSize),
                label: const Text('消费记录', style: optionStyle),
              ),
            ],
          ),
          // 右侧显示的页面
          Expanded(
            child: _widgetOptions[_selectedIndex],
          ),
        ],
      ),
    );
  }

  // 个人信息介绍
  void _showPersonalInfo() {
    const textStyle = TextStyle(fontSize: 16);
    Widget buildRow(String label, String value, TextStyle style) {
      return Row(
        children: [
          Text(label, style: style.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Expanded(child: Text(value, style: style,overflow: TextOverflow.ellipsis,)),
        ],
      );
    }
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            height: 300,
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '个人信息',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildRow('用户名：', widget.userInfo.username, textStyle),
                    const SizedBox(height: 10),
                    buildRow('名字：', widget.userInfo.name, textStyle),
                    const SizedBox(height: 10),
                    buildRow('手机号：', widget.userInfo.phone, textStyle),
                    const SizedBox(height: 10),
                    buildRow('邮箱：', widget.userInfo.email, textStyle),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // 修改密码
  void _modifyPassword() {
    final TextEditingController oldPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();
    // 弹出对话框，让用户输入旧密码和新密码
    showDialog(
      context: context,
      builder: (context) {
       return Dialog(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          height: 400,
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '修改密码',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: oldPasswordController,
                decoration: const InputDecoration(
                  labelText: '旧密码',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: '新密码',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: '确认新密码',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // 处理取消按钮点击事件
                      Navigator.pop(context);
                    },
                    child: const Text('取消'),
                  ),  
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      // 验证旧密码是否正确
                      if (oldPasswordController.text != widget.userInfo.password) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('旧密码错误'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else {
                        // 验证新密码和确认密码是否一致
                        if (newPasswordController.text!= confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('新密码和确认密码不一致'),
                              duration: Duration(seconds: 2),
                            ),
                          );  
                        } else {
                          if (newPasswordController.text == widget.userInfo.password) {
                            ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('新密码和旧密码相同'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          } else {
                           // 修改密码
                          widget.userInfo.password = newPasswordController.text;
                          dbHelper.modifyUserPassword(widget.userInfo);
                          Navigator.pop(context); 
                          }
                        }
                      }
                    },
                    child: const Text('确定'),
                  ),
                ]  
              )
            ] 
          ) 
        )
       ); 
      }  
    );
  }

  // 修改头像
  void _selectAvatarFile() async {
    try {
      // 弹出文件选择器
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'webp', 'bmp'],
      );

      if (result != null && result.files.single.path != null) {
        // 获取应用的文档目录
        final String appDocDir = Platform.resolvedExecutable;
        // 在文档目录中创建一个子目录
        final Directory targetDir = Directory(
            '${appDocDir.replaceAll('membership_system.exe', '')}.membership_system\\images');
        if (!targetDir.existsSync()) {
          targetDir.createSync(recursive: true);
        }

        // 构建目标文件路径
        final String fileName = result.files.single.name; // 保留原始文件名
        final String targetFilePath = '${targetDir.path}\\$fileName';

        // 将选择的文件复制到目标目录
        File sourceFile = File(result.files.single.path!);
        await sourceFile.copy(targetFilePath);

        setState(() {
          widget.userInfo.avatarUrl = targetFilePath;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('未选择文件'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}
