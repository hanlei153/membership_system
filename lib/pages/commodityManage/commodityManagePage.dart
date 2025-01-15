import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common/sqflite/databaseHelper.dart';
import '../../common/model/commodity.dart';
import '../../common/model/commodityCategory.dart';
import 'ExpansionPanelListCategory.dart';

class CommodityManagePage extends StatefulWidget {
  @override
  _CommodityManagePageState createState() => _CommodityManagePageState();
}

class _CommodityManagePageState extends State<CommodityManagePage> {
  List<CommodityCategorys> commodityCategorys = [];
  bool commodityCategory = false;
  List<Commoditys> commoditys = [];
  final dbHelper = DatabaseHelper();
  final TextEditingController searchController = TextEditingController();
  String? _commodityCategorySelectedValue = 'Option 1';

  @override
  void initState() {
    super.initState();
    _loadCommodityCategorys();
  }

  void _addCommodityCategorys(String name) async {
    final newCommodityCategory = CommodityCategorys(id: 0, name: name);
    await dbHelper.addCommodityCategorys(newCommodityCategory);
    _loadCommodityCategorys();
  }

  void _delCommodityCategorys(CommodityCategorys commodityCategory) async {
    await dbHelper.delCommodityCategorys(commodityCategory);
  }

  void _loadCommodityCategorys() async {
    final loadedCommodityCategorys = await dbHelper.getCommodityCategorys();
    setState(() {
      commodityCategorys = loadedCommodityCategorys;
    });
  }

  void _searchCommodityCategorys(String name) async {
    final result = await dbHelper.getCommodityCategorys(name: name);
    setState(() {
      if (result.isEmpty) {
        commodityCategory = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                ElevatedButton(
                  child: const Text('新增类目'),
                  onPressed: () {
                    _showAddCommodityCategorys();
                  },
                ),
                const SizedBox(
                  width: 10,
                ),
                commodityCategorys.isNotEmpty
                    ? ElevatedButton(
                        child: const Text('新增商品'),
                        onPressed: () {
                          _showAddCommodity();
                        },
                      )
                    : const SizedBox.shrink()
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
                      labelText: '类目或商品名',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // _searchMembers(searchController.text);
                  },
                  child: const Text('搜索'),
                ),
              ],
            ),
          ],
        ),
      ),
      Expanded(
          child: commodityCategorys.isEmpty
              ? CircularProgressIndicator()
              : ExpansionPanelListCategory(
                  commodityCategorys: commodityCategorys))
    ]));
  }

  // 新增商品弹窗
  void _showAddCommodity() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              height: 450,
              width: 300,
              padding: const EdgeInsets.all(16.0),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text(
                  '新增商品',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 30,
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: '商品名称'),
                ),
                TextField(
                  controller: priceController,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d*$')), // 只允许输入数字
                  ],
                  decoration: const InputDecoration(labelText: '商品价格'),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      '商品类目：',
                      style: TextStyle(
                        fontSize: 16.0, // 设置字体大小
                      ),
                    ),
                    DropdownMenu<String>(
                      menuHeight: 200,
                      leadingIcon: Icon(null),
                      trailingIcon: Icon(null),
                      inputDecorationTheme: const InputDecorationTheme(
                        filled: false,
                        iconColor: Colors.transparent,
                      ),
                      onSelected: (String? newValue) {
                        setState(() {
                          _commodityCategorySelectedValue = newValue!;
                        });
                      },
                      dropdownMenuEntries: commodityCategorys.map(
                        (item) {
                          return DropdownMenuEntry(
                              value: item.name, label: item.name);
                        },
                      ).toList(),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '选择图片：',
                      style: TextStyle(
                        fontSize: 16.0, // 设置字体大小
                      ),
                    ),

                  ],
                ),
                const SizedBox(
                  height: 120,
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
                        // final name = nameController.text;
                        // if (name.isNotEmpty) {
                        //   _searchCommodityCategorys(name);
                        //   if (commodityCategory) {
                        //     _addCommodityCategorys(name);
                        //   } else {
                        //     ScaffoldMessenger.of(context).showSnackBar(
                        //       const SnackBar(
                        //         content: Text('类目已存在'),
                        //         duration: Duration(seconds: 2),
                        //       ),
                        //     );
                        //   }
                        // }
                        // Navigator.of(context).pop(); // 关闭底部弹出框
                      },
                      child: const Text('添加'),
                    ),
                  ],
                )
              ]),
            ),
          );
        });
  }

  // 新增类目弹窗
  void _showAddCommodityCategorys() {
    final nameController = TextEditingController();
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
                    '新增类目',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 60,
                  ),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                        labelText: '类目名称', hintText: '例如：饮料'),
                  ),
                  const SizedBox(
                    height: 60,
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
                          if (name.isNotEmpty) {
                            _searchCommodityCategorys(name);
                            if (commodityCategory) {
                              _addCommodityCategorys(name);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('类目已存在'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
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
}
