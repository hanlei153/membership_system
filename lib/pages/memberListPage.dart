import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../common/sqflite/databaseHelper.dart';
import '../common/model/member.dart';
import '../common/fuctions/exportMembers.dart';

class MemberListPage extends StatefulWidget {
  @override
  _MemberListPageState createState() => _MemberListPageState();
}

class _MemberListPageState extends State<MemberListPage> {
  List<Member> members = [];
  final dbHelper = DatabaseHelper();
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final loadedMembers = await dbHelper.getMembers();
    setState(() {
      members = loadedMembers;
    });
  }

  Future<void> _searchMembers(String searchConditions) async {
    final loadedMembers = await dbHelper.searchMembers(searchConditions);
    setState(() {
      members = loadedMembers;
    });
  }

  void _addMember(String name, String phone) async {
    final newMember = Member(
      id: 0,
      name: name,
      phone: phone,
      balance: 0.0,
      points: 0,
    );
    await dbHelper.addMember(newMember);
    _loadMembers();
  }

  void _exportMembers() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      await exportMembers(selectedDirectory);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导出成功: $selectedDirectory/membersInfo.json')),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('请选择目录！')));
    }
  }

  void _importMembers() async {
    FilePickerResult? selectedFile = await FilePicker.platform.pickFiles();
    if (selectedFile != null) {
      await importMembers(selectedFile.files.single.path);
      _loadMembers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导入成功: ${selectedFile.files.single.path}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('未选择文件')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('再少年桌游馆会员系统'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: const Text('添加会员'),
              onTap: () {
                Navigator.of(context).pop();
                _showAddMemberDialog();
              },
            ),
            ListTile(
              title: const Text('导出会员信息'),
              onTap: () {
                Navigator.of(context).pop();
                _exportMembers();
              },
            ),
            ListTile(
              title: const Text('导入会员信息'),
              onTap: () {
                Navigator.of(context).pop();
                _importMembers();
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(labelText: '用户名或手机号'),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _searchMembers(searchController.text);
                },
                child: Text('搜索'),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                return GestureDetector(
                  onTap: () {
                    _updateMember(member);
                  },
                  child: ListTile(
                    title: Text('${member.name} (${member.phone})'),
                    subtitle:
                        Text('余额: ${member.balance}, 积分: ${member.points}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              height: 300,
              width: 500,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '添加新会员',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: '姓名'),
                  ),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(labelText: '电话'),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // 关闭底部弹出框
                        },
                        child: Text('取消'),
                      ),
                      TextButton(
                        onPressed: () {
                          final name = nameController.text;
                          final phone = phoneController.text;
                          if (name.isNotEmpty && phone.isNotEmpty) {
                            _addMember(name, phone); // 调用 _addMember 方法
                          }
                          Navigator.of(context).pop(); // 关闭底部弹出框
                        },
                        child: Text('添加'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  // 会员更新和充值消费操作
  void _updateMember(Member member) {
    final amountController = TextEditingController(); // 输入金额的控制器

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              height: 300,
              width: 500,
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '更新会员信息',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),

                  // 显示当前余额和积分
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('当前余额: ${member.balance} 元'),
                      Text('当前积分: ${member.points} 分'),
                    ],
                  ),

                  SizedBox(height: 16),

                  // 输入充值或消费金额
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: '金额'),
                  ),

                  SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 充值按钮
                      ElevatedButton(
                        onPressed: () {
                          final amount = double.tryParse(amountController.text);
                          if (amount != null && amount > 0) {
                            setState(() {
                              member.balance += amount; // 增加余额
                            });
                            dbHelper.updateMemberBalance(member);
                            _loadMembers();
                            Navigator.of(context).pop(); // 关闭底部弹出框
                          }
                        },
                        child: Text('充值'),
                      ),

                      // 消费按钮
                      ElevatedButton(
                        onPressed: () async {
                          final amount = double.tryParse(amountController.text);
                          if (amount != null &&
                              amount > 0 &&
                              member.balance >= amount) {
                            dbHelper.updateBalanceAndPoints(member, amount);
                            Navigator.of(context).pop(); // 关闭底部弹出框
                            await Future.delayed(
                                const Duration(milliseconds: 500));
                            _loadMembers();
                          } else {
                            // 如果余额不足，可以弹出一个提示
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('余额不足，无法消费！')),
                            );
                          }
                        },
                        child: Text('消费'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }
}
