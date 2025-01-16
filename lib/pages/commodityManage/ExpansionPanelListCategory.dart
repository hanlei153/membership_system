import 'dart:io';

import 'package:flutter/material.dart';
import 'package:membership_system/common/model/commodity.dart';
import 'package:contextmenu/contextmenu.dart';
import 'package:membership_system/pages/commodityManage/commodityManagePage.dart';

import '../../common/model/commodityCategory.dart';
import '../../common/sqflite/databaseHelper.dart';

List<CommodityCategorys> generateCategory(
    List<CommodityCategorys> commodityCategorys) {
  return List<CommodityCategorys>.generate(commodityCategorys.length,
      (int index) {
    return CommodityCategorys(
        id: commodityCategorys[index].toMap()["id"],
        name: commodityCategorys[index].toMap()["name"],
        isExpanded: false);
  });
}

class ExpansionPanelListCategory extends StatefulWidget {
  ExpansionPanelListCategory({super.key, required this.commodityCategorys});

  List<CommodityCategorys> commodityCategorys;

  @override
  State<ExpansionPanelListCategory> createState() =>
      _ExpansionPanelListCategoryState();
}

class _ExpansionPanelListCategoryState
    extends State<ExpansionPanelListCategory> {
  late List<CommodityCategorys> _data;
  Map<int, List<Commoditys>> commodityMap = {};
  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _data = generateCategory(widget.commodityCategorys);
  }

  void _searchCommodity(int commodityCategoryId) async {
    final commodities =
        await dbHelper.getCommodity(commodityCategoryId: commodityCategoryId);
    setState(() {
      commodityMap[commodityCategoryId] = commodities;
    });
  }

  void _delCommodityCategorys(int commodityCategoryId) async {
    await dbHelper.delCommodityCategorys(commodityCategoryId);
  }

  void _modifyCommodityCategorys(int commodityCategoryId, String name) async {
    await dbHelper.modityCommodityCategorys(commodityCategoryId, name);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: _buildPanel(),
      ),
    );
  }

  Widget _buildPanel() {
    return ExpansionPanelList(
      elevation: 1,
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _data[index].isExpanded = isExpanded;
          if (isExpanded) {
            _searchCommodity(_data[index].id ?? 0);
          }
        });
      },
      children: _data.map<ExpansionPanel>((CommodityCategorys item) {
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ContextMenuArea(
              width: 100,
              builder: (context) {
                return [
                  ListTile(
                    title: const Text('编辑'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _showModifyCategoryDialog(item);
                    },
                  ),
                  ListTile(
                    title: const Text('删除'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _showRemoveCategoryDialog(item.id ?? 0, item.name);
                      // _delCommodityCategorys(item.id ?? 0);
                    },
                  )
                ];
              },
              child: ListTile(
                title: Text(item.name),
              ),
            );
          },
          body: item.isExpanded
              ? GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5, // 设置每行显示的列数
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: commodityMap[item.id]?.length ?? 0,
                  itemBuilder: (context, index) {
                    final commodities = commodityMap[item.id];
                    return Card(
                      elevation: 5,
                      margin: const EdgeInsets.all(10),
                      child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    File(commodities![index].picUrl),
                                  )),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                commodities[index].name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 3),
                              // 商品价格
                              Text(
                                "\$${commodities[index].price.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          )),
                    );
                  },
                )
              : Container(),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }

  // 修改类目弹窗
  void _showModifyCategoryDialog(CommodityCategorys commodityCategorys) {
    final TextEditingController modifyNameContrller =
        TextEditingController(text: commodityCategorys.name);
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
                    '修改名称',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: modifyNameContrller,
                    decoration: const InputDecoration(
                        labelText: '名称', hintText: '请输入新名称'),
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
                          _modifyCommodityCategorys(commodityCategorys.id ?? 0,
                              modifyNameContrller.text);
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
// 删除类目弹窗
  void _showRemoveCategoryDialog(int commodityCategoryId, String name) {
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
                  Text(
                    '确定删除分类：$name 吗',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
}
