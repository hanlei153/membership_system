import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:contextmenu/contextmenu.dart';
import 'package:flutter/services.dart';

import '../../common/sqflite/databaseHelper.dart';
import '../../common/model/member.dart';
import '../../common/fuctions/exportMembers.dart';
import '../../common/fuctions/InputFormatter.dart';
import '../../common/model/commodity.dart';
import '../../common/model/transaction.dart';

class MemberListPage extends StatefulWidget {
  @override
  _MemberListPageState createState() => _MemberListPageState();
}

class _MemberListPageState extends State<MemberListPage> {
  List<Member> members = [];
  final dbHelper = DatabaseHelper();
  final searchController = TextEditingController();
  String commoditySelectedValue = '';
  double commoditySelectedValuePrice = 0;

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
        timestamp: (DateTime.now().millisecondsSinceEpoch / 1000).round());
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
                        title: const Text('销卡'),
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
                      contentPadding: const EdgeInsets.all(10), // 内部的 padding
                      title: Text('${member.name} (${member.phone})'),
                      subtitle:
                          Text('余额: ${member.balance}, 积分: ${member.points}'),
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
                          // 消费按钮
                          ElevatedButton(
                            onPressed: () async {
                              final List<Commoditys> commoditys =
                                  await dbHelper.getCommodity();
                              _memberConsume(member, commoditys);
                            },
                            child: Text('消费'),
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
                    inputFormatters: [ElevenDigitsInputFormatter()],
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
    final TextEditingController modifyNameContrller =
        TextEditingController(text: member.name);
    final TextEditingController modifyPhoneContrller =
        TextEditingController(text: member.phone);
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
                    decoration: const InputDecoration(
                        labelText: '姓名', hintText: '请输入姓名'),
                  ),
                  TextField(
                    inputFormatters: [ElevenDigitsInputFormatter()],
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
                          _modifyMember(member, modifyNameContrller.text,
                              modifyPhoneContrller.text);
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
                  const SizedBox(height: 50),
                  // 输入充值或消费金额
                  TextField(
                    inputFormatters: [SingleDotInputFormatter()],
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '金额'),
                  ),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final amount = double.tryParse(amountController.text);
                          if (amount != null && amount > 0) {
                            setState(() {
                              member.balance += amount; // 增加余额
                            });
                            await dbHelper.updateMemberBalance(member, amount);
                            final newTransaction = Transactions(
                              id: 0,
                              memberId: member.id!,
                              memberName: member.name,
                              memberPhone: member.phone,
                              type: '充值',
                              amount: amount,
                              isRefund: 0,
                              timestamp:
                                  (DateTime.now().millisecondsSinceEpoch / 1000)
                                      .round(),
                              note: '充值',
                            );
                            await dbHelper.addTransactions(newTransaction);
                            _loadMembers();
                            Navigator.of(context).pop(); // 关闭弹出框
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('充值完成')),
                            );
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

  // 会员消费弹窗
  void _memberConsume(Member member, List<Commoditys> commoditys) {
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      '消费',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
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
                  const SizedBox(height: 30),
                  // 输入充值或消费金额
                  const Text(
                    '输入金额或选择商品：',
                    style: TextStyle(fontSize: 15),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 200,
                        child: TextField(
                          inputFormatters: [SingleDotInputFormatter()],
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: '金额'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('或'),
                      const SizedBox(width: 10),
                      DropdownMenu<String>(
                        menuHeight: 200,
                        leadingIcon: Icon(null),
                        trailingIcon: Icon(null),
                        inputDecorationTheme: const InputDecorationTheme(
                          filled: false,
                          iconColor: Colors.transparent,
                        ),
                        onSelected: (String? selectedValue) {
                          setState(() {
                            if (selectedValue != null) {
                              // 假设字符串格式为 "id|name"
                              final parts = selectedValue.split('|');
                              if (parts.length == 2) {
                                commoditySelectedValuePrice =
                                    double.parse(parts[0]);
                                commoditySelectedValue = parts[1];
                              }
                            }
                          });
                        },
                        dropdownMenuEntries: commoditys.map(
                          (item) {
                            return DropdownMenuEntry(
                                value: '${item.price}|${item.name}',
                                label: item.name);
                          },
                        ).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
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
                        onPressed: () async {
                          // 更新余额操作
                          var result = await dbHelper.updateBalanceAndPoints(
                            member,
                            amountController.text.isNotEmpty
                                ? commoditySelectedValuePrice +
                                    double.tryParse(amountController.text)!
                                : commoditySelectedValuePrice,
                            commoditySelectedValue,
                          );

                          // 显示结果
                          if (result["status"] == "fail") {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result["message"])),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result["message"])),
                            );
                            // 添加交易记录操作
                            final newTransaction = Transactions(
                              id: 0,
                              memberId: member.id!,
                              memberName: member.name,
                              memberPhone: member.phone,
                              type: '消费',
                              amount: amountController.text.isNotEmpty
                                  ? commoditySelectedValuePrice +
                                      double.tryParse(amountController.text)!
                                  : commoditySelectedValuePrice,
                              isRefund: 0,
                              timestamp:
                                  (DateTime.now().millisecondsSinceEpoch / 1000)
                                      .round(),
                              note: commoditySelectedValue.isEmpty
                                  ? '消费'
                                  : commoditySelectedValue,
                            );
                            await dbHelper.addTransactions(newTransaction);
                          }
                          setState(() {
                            commoditySelectedValuePrice = 0;
                            commoditySelectedValue = '';
                          });
                          _loadMembers();
                          Navigator.of(context).pop();
                        },
                        child: const Text('确定'),
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }
}
