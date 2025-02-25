import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:contextmenu/contextmenu.dart';
import 'package:flutter/services.dart';

import '../../common/sqflite/databaseHelper.dart';
import '../../common/model/member.dart';
import '../../common/fuctions/importExportMembers.dart';
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

  void _modifyMember(Member member, name, phone, password) async {
    await dbHelper.modifyMember(member, name, phone, password);
    _loadMembers();
  }

  void _addMember(String name, String phone, String password) async {
    final newMember = Member(
        id: 0,
        name: name,
        phone: phone,
        balance: 0.0,
        giftBalance: 0.0,
        points: 0,
        password: password,
        timestamp: (DateTime.now().millisecondsSinceEpoch / 1000).round());
    await dbHelper.addMember(newMember);
    _loadMembers();
  }

  void _exportMembers() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      await exportMembers(selectedDirectory);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导出成功: $selectedDirectory/membersInfo.xlsx')),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('请选择目录！')));
    }
  }

  void _importMembers() async {
    FilePickerResult? selectedFile = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['xlsx', 'xls']);
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
                      subtitle: Text(
                          '余额: ${member.balance.toStringAsFixed(2)}, 赠送余额：${member.giftBalance.toStringAsFixed(2)}, 积分: ${member.points}'),
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
          const SizedBox(
            height: 10,
          ),
          Text('总会员数: ${members.length}', style: const TextStyle(fontSize: 12, color: Colors.grey),),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }

  // 添加会员弹窗
  void _showAddMemberDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final memberPasswordController = TextEditingController();
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
                  TextField(
                    inputFormatters: [ElevenDigitsInputFormatter()],
                    controller: memberPasswordController,
                    decoration: const InputDecoration(labelText: '密码'),
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
                          final password = memberPasswordController.text;
                          if (name.isNotEmpty &&
                              phone.isNotEmpty &&
                              password.isNotEmpty) {
                            _addMember(
                                name, phone, password); // 调用 _addMember 方法
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
    final TextEditingController modifyPasswordContrller =
        TextEditingController(text: member.password);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              height: 330,
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
                  TextField(
                    inputFormatters: [ElevenDigitsInputFormatter()],
                    controller: modifyPasswordContrller,
                    decoration: const InputDecoration(
                        labelText: '密码', hintText: '请输入密码'),
                  ),
                  const SizedBox(height: 40),
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
                          _modifyMember(
                              member,
                              modifyNameContrller.text,
                              modifyPhoneContrller.text,
                              modifyPasswordContrller.text);
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
    final giftAmountController =
        TextEditingController(text: '0.0'); // 输入赠送金额的控制器
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
                      Text('赠送金额：${member.giftBalance} 元'),
                      Text('当前积分: ${member.points} 分'),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // 输入充值或消费金额
                  TextField(
                    inputFormatters: [SingleDotInputFormatter()],
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '金额'),
                  ),
                  TextField(
                    inputFormatters: [SingleDotInputFormatter()],
                    controller: giftAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '赠送金额'),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final amount = double.tryParse(amountController.text);
                          final giftAmount =
                              double.tryParse(giftAmountController.text);
                          if (amount != null && amount > 0) {
                            setState(() {
                              member.balance += amount; // 增加余额
                              member.giftBalance += giftAmount!; // 增加赠送金额
                            });
                            await dbHelper.updateMemberBalance(member, amount);
                            final newTransaction = Transactions(
                              id: 0,
                              memberId: member.id!,
                              memberName: member.name,
                              memberPhone: member.phone,
                              type: '充值',
                              amount: amount,
                              giftAmount: giftAmount!,
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
    bool _isButtonEnabled = true;
    final amountController = TextEditingController(); // 输入金额的控制器
    final passwordContrller = TextEditingController();

    Future<void> _consumptionButton() async {
      if (!_isButtonEnabled) return; // 防止重复进入
      setState(() {
        _isButtonEnabled = false; // 点击后禁用
      });

      try {
        if (amountController.text.isNotEmpty ||
            commoditySelectedValuePrice != 0) {
          if (passwordContrller.text == member.password &&
              passwordContrller.text.isNotEmpty) {
            var amount = amountController.text.isNotEmpty
                ? commoditySelectedValuePrice +
                    (double.tryParse(amountController.text) ?? 0)
                : commoditySelectedValuePrice;

            var result = await dbHelper.updateBalanceAndPoints(
              member,
              amount,
              commoditySelectedValue,
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result["message"])),
            );

            if (result["status"] != "fail") {
              final newTransaction = Transactions(
                id: 0,
                memberId: member.id!,
                memberName: member.name,
                memberPhone: member.phone,
                type: '消费',
                amount: result['balance'],
                giftAmount: result['giftBalance'],
                isRefund: 0,
                timestamp:
                    (DateTime.now().millisecondsSinceEpoch / 1000).round(),
                note: commoditySelectedValue.isEmpty
                    ? '消费'
                    : commoditySelectedValue,
              );
              await dbHelper.addTransactions(newTransaction);
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('密码错误')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('请输入金额或选择商品')),
          );
        }

        setState(() {
          commoditySelectedValuePrice = 0;
          commoditySelectedValue = '';
        });
        _loadMembers();
        Navigator.of(context).pop();
      } catch (e) {
        print('错误: $e'); // 捕获异常，避免崩溃
      } finally {
        // 延迟0.5秒后恢复按钮
        await Future.delayed(Duration(milliseconds: 500));
        if (mounted) {
          // 检查组件是否仍在树中
          setState(() {
            _isButtonEnabled = true;
          });
        }
      }
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              height: 350,
              width: 500,
              padding: const EdgeInsets.all(30),
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
                      Text('赠送金额：${member.giftBalance} 元'),
                      Text('当前积分: ${member.points} 分'),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Text(
                        '输入金额：',
                        style: TextStyle(fontSize: 15),
                      ),
                      Container(
                        width: 130,
                        child: TextField(
                          inputFormatters: [SingleDotInputFormatter()],
                          controller: amountController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text(
                        '选择商品：',
                        style: TextStyle(fontSize: 15),
                      ),
                      DropdownMenu<String>(
                        menuHeight: 200,
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
                  Row(
                    children: [
                      const Text(
                        '用户密码：',
                        style: TextStyle(fontSize: 15),
                      ),
                      Container(
                        width: 130,
                        child: TextField(
                          inputFormatters: [SingleDotInputFormatter()],
                          controller: passwordContrller,
                          keyboardType: TextInputType.number,
                        ),
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
                        onPressed: _isButtonEnabled ? _consumptionButton : null,
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
