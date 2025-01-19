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

  Future<bool> _searchCommoditys(int commodityCategoryId) async {
    final commodites =
        await dbHelper.getCommodity(commodityCategoryId: commodityCategoryId);
    if (commodites.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  void _delCommodityCategorys(CommodityCategorys commodityCategorys) async {
    await dbHelper.delCommodityCategorys(commodityCategorys);
  }

  void _modifyCommodityCategorys(int commodityCategoryId, String name) async {
    await dbHelper.modityCommodityCategorys(commodityCategoryId, name);
  }

  void _modifyCommodity(Commoditys commodity) async {
    await dbHelper.modityCommoditys(commodity);
  }

  void _delCommodity(Commoditys commodity) async {
    await dbHelper.delCommodity(commodity);
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
                    title: const Text('删除'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _showRemoveCategoryDialog(item);
                    },
                  ),
                  ListTile(
                    title: const Text('编辑'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _showModifyCategoryDialog(item);
                    },
                  ),
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
                    return ContextMenuArea(
                      width: 100,
                      builder: (context) {
                        return [
                          ListTile(
                            title: const Text('删除'),
                            onTap: () {
                              Navigator.of(context).pop();
                              _showRemoveCommodityDialog(commodities[index]);
                            },
                          ),
                          ListTile(
                            title: const Text('编辑'),
                            onTap: () {
                              Navigator.of(context).pop();
                              _showModifyCommodityDialog(commodities[index]);
                            },
                          ),
                        ];
                      },
                      child: Card(
                        elevation: 5,
                        margin: const EdgeInsets.all(10),
                        child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      File(commodities![index].picUrl),
                                      fit: BoxFit.fill,
                                    )),
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  "${commodities[index].name}\n${commodities[index].price.toStringAsFixed(2)} 元",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )),
                      ),
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
              height: 260,
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
  void _showRemoveCategoryDialog(CommodityCategorys commodityCategorys) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              height: 260,
              width: 500,
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '删除',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '确定删除分类：${commodityCategorys.name} 吗',
                    // style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 80),
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
                          bool isEmpty = await _searchCommoditys(
                              commodityCategorys.id ?? 0);
                          if (isEmpty) {
                            _delCommodityCategorys(commodityCategorys);
                            Navigator.of(context).pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '当前 ${commodityCategorys.name} 类目下还有商品未删除，请先删除商品。'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
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

  // 删除商品弹窗
  void _showRemoveCommodityDialog(Commoditys commodity) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              height: 260,
              width: 500,
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '删除',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '确定删除商品：${commodity.name} 吗',
                    // style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 80),
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
                          _delCommodity(commodity);
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

  // 修改商品弹窗
  void _showModifyCommodityDialog(Commoditys commodity) {
    final TextEditingController modifyNameContrller =
        TextEditingController(text: commodity.name);
    final TextEditingController modifyPriceContrller =
        TextEditingController(text: commodity.price.toString());
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
                    '修改商品信息',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: modifyNameContrller,
                    decoration: const InputDecoration(
                        labelText: '名称', hintText: '请输入新名称'),
                  ),
                  TextField(
                    controller: modifyPriceContrller,
                    decoration: const InputDecoration(
                        labelText: '价格', hintText: '请输入新价格'),
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
                          final newInfo = Commoditys(
                            id: commodity.id,
                            commodityCategoryId: commodity.commodityCategoryId,
                            name: modifyNameContrller.text,
                            price: double.parse(modifyPriceContrller.text),
                            picUrl: commodity.picUrl,
                          );
                          _modifyCommodity(newInfo);
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
