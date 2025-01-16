import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:contextmenu/contextmenu.dart';

import '../../common/sqflite/databaseHelper.dart';
import '../../common/model/member.dart';
import '../../common/fuctions/exportMembers.dart';

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

  void _delMember(Member member) async {
    await dbHelper.delMember(member);
    _loadMembers();
  }

  void _modifyMember(Member member, name, phone) async {
    await dbHelper.modifyMember(member, name, phone);
    _loadMembers();
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
          .showSnackBar(const SnackBar(content: Text('请选择目录！')));
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
        const SnackBar(content: Text('未选择文件')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ElevatedButton(
                      child: const Text('开卡'),
                      onPressed: () {
                        _showAddMemberDialog();
                      },
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      child: const Text('导出会员'),
                      onPressed: () {
                        _exportMembers();
                      },
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      child: const Text('导入会员'),
                      onPressed: () {
                        _importMembers();
                      },
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 300,
                      height: 48,
                      padding: const EdgeInsets.all(8),
                      child: TextField(
                        style: const TextStyle(
                          fontSize: 13.0, // 设置字体大小
                        ),
                        controller: searchController,
                        decoration: const InputDecoration(
                          labelText: '用户名或手机号',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(30.0)),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _searchMembers(searchController.text);
                      },
                      child: const Text('搜索'),
                    ),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                return ContextMenuArea(
                  width: 100,
                  builder: (context) {
                    return [
                      ListTile(
                        title: const Text('编辑'),
                        onTap: () {
                          Navigator.of(context).pop();
                          _showModifyMemberDialog(member);
                        },
                      ),
                      ListTile(
                        title: const Text('删除'),
                        onTap: () {
                          Navigator.of(context).pop();
                          _showRemoveMemberDialog(member);
                        },
                      )
                    ];
                  },
                  child: Card(
                    elevation: 5, // 设置阴影效果
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // 设置卡片圆角
                    ),
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15), // 卡片的间距
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.all(10), // 内部的 padding
                      title: Text('${member.name} (${member.phone})'),
                      subtitle: Text(
                          '余额: ${member.balance}, 积分: ${member.points}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 充值按钮
                          ElevatedButton(
                            onPressed: () {
                              _memberRecharge(member);
                            },
                            child: const Text('充值'),
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 添加会员弹窗
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
                  const Text(
                    '添加新会员',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: '姓名'),
                  ),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: '电话'),
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
                        child: const Text('取消'),
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
                        child: const Text('添加'),
                      ),
                      
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  // 删除会员弹窗
  void _showRemoveMemberDialog(Member member) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              height: 300,
              width: 500,
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '销卡',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text('姓名：${member.name}'),
                  Text('余额：${member.balance}'),
                  Text('积分：${member.points}'),
                  Text('手机号：${member.phone}'),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('取消'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _delMember(member);
                        },
                        child: const Text('销卡'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  // 修改会员弹窗
  void _showModifyMemberDialog(Member member) {
    final TextEditingController modifyNameContrller = TextEditingController(text: member.name);
    final TextEditingController modifyPhoneContrller = TextEditingController(text: member.phone);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              height: 300,
              width: 500,
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '修改信息',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: modifyNameContrller,
                    decoration:
                        const InputDecoration(labelText: '姓名', hintText: '请输入姓名'),
                  ),
                  TextField(
                    controller: modifyPhoneContrller,
                    decoration: const InputDecoration(
                        labelText: '手机号', hintText: '请输入手机号'),
                  ),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('取消'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _modifyMember(member, modifyNameContrller.text, modifyPhoneContrller.text);
                        },
                        child: const Text('确定'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  // 会员充值弹窗
  void _memberRecharge(Member member) {
    final amountController = TextEditingController(); // 输入金额的控制器
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              height: 300,
              width: 500,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '充值',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // 显示当前余额和积分
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('当前余额: ${member.balance} 元'),
                      Text('当前积分: ${member.points} 分'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 输入充值或消费金额
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '金额'),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          final amount = double.tryParse(amountController.text);
                          if (amount != null && amount > 0) {
                            setState(() {
                              member.balance += amount; // 增加余额
                            });
                            dbHelper.updateMemberBalance(member);
                            _loadMembers();
                            Navigator.of(context).pop(); // 关闭弹出框
                          }
                        },
                        child: const Text('充值'),
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


// // 消费按钮
//                       ElevatedButton(
//                         onPressed: () async {
//                           final amount = double.tryParse(amountController.text);
//                           if (amount != null &&
//                               amount > 0 &&
//                               member.balance >= amount) {
//                             dbHelper.updateBalanceAndPoints(member, amount);
//                             Navigator.of(context).pop(); // 关闭底部弹出框
//                             await Future.delayed(
//                                 const Duration(milliseconds: 500));
//                             _loadMembers();
//                           } else {
//                             // 如果余额不足，可以弹出一个提示
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(content: Text('余额不足，无法消费！')),
//                             );
//                           }
//                         },
//                         child: Text('消费'),
//                       ),