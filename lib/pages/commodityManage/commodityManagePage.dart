import 'package:flutter/material.dart';

import '../../common/sqflite/databaseHelper.dart';
import '../../common/model/commodity.dart';
import '../../common/model/commodityCategory.dart';

class CommodityManagePage extends StatefulWidget {
  @override
  _CommodityManagePageState createState() => _CommodityManagePageState();
}

class _CommodityManagePageState extends State<CommodityManagePage> {
  List<CommodityCategorys> commodityCategorys = [];
  List<Commoditys> commoditys = [];
  final dbHelper = DatabaseHelper();
  final TextEditingController searchController = TextEditingController();

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

  List<Map<String, dynamic>> categories = [
    {
      'title': 'Category 1',
      'items': ['Item 1.1', 'Item 1.2', 'Item 1.3'],
      'isExpanded': false,
    },
    {
      'title': 'Category 2',
      'items': ['Item 2.1', 'Item 2.2'],
      'isExpanded': false,
    },
    {
      'title': 'Category 3',
      'items': ['Item 3.1', 'Item 3.2', 'Item 3.3', 'Item 3.4'],
      'isExpanded': false,
    },
  ];

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
                          // _exportMembers();
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
        child: SingleChildScrollView(
          child: ExpansionPanelList(
            elevation: 1,
            expandedHeaderPadding: EdgeInsets.zero,
            expansionCallback: (int index, bool isExpanded) {
              setState(() {
                categories[index]['isExpanded'] = !isExpanded;
              });
            },
            children: categories.map<ExpansionPanel>((category) {
              return ExpansionPanel(
                headerBuilder: (context, isExpanded) {
                  return ListTile(
                    title: Text(category['title']),
                  );
                },
                body: Column(
                  children:
                      (category['items'] as List<String>).map<Widget>((item) {
                    return ListTile(
                      title: Text(item),
                      onTap: () {
                        print('Clicked: $item');
                      },
                    );
                  }).toList(),
                ),
                isExpanded: category['isExpanded'],
              );
            }).toList(),
          ),
        ),
      ),
    ]));
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
                            _addCommodityCategorys(name);
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
