import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

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
  final dbHelper = DatabaseHelper();
  final TextEditingController searchController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCommodityCategorys();
  }

  void _addCommodityCategorys(String name) async {
    setState(() {
      isLoading = true; // 开始加载，显示加载状态
    });
    final newCommodityCategory = CommodityCategorys(id: 0, name: name);
    await dbHelper.addCommodityCategorys(newCommodityCategory);
    await _loadCommodityCategorys();
    setState(() {
      isLoading = false; // 加载完成，刷新 UI
    });
  }

  Future<void> _loadCommodityCategorys() async {
    final loadedCommodityCategorys = await dbHelper.getCommodityCategorys();
    setState(() {
      commodityCategorys = loadedCommodityCategorys;
    });
  }

  Future<bool> _searchCommodityCategorys(String name) async {
    final result = await dbHelper.getCommodityCategorys(name: name);
    return result.isEmpty;
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
            const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [],
            ),
          ],
        ),
      ),
      isLoading
          ? Center(child: CircularProgressIndicator())
          : Expanded(
              child: commodityCategorys.isEmpty
                  ? const Center(child: Text('暂无类目'))
                  : ExpansionPanelListCategory(
                      commodityCategorys: commodityCategorys))
    ]));
  }

  // 新增商品弹窗
  void _showAddCommodity() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return _AddCommodityDialog(
            commodityCategorys: commodityCategorys,
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
                    decoration: const InputDecoration(labelText: '类目名称'),
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
                        onPressed: () async {
                          final name = nameController.text;
                          if (name.isNotEmpty) {
                            commodityCategory =
                                await _searchCommodityCategorys(name);
                            if (commodityCategory) {
                              _addCommodityCategorys(name);
                              setState(() {
                                commodityCategory = false;
                              });
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

// 新增商品
class _AddCommodityDialog extends StatefulWidget {
  _AddCommodityDialog({required this.commodityCategorys});
  late final List<CommodityCategorys> commodityCategorys;
  @override
  State<_AddCommodityDialog> createState() => _AddCommodityDialogState();
}

class _AddCommodityDialogState extends State<_AddCommodityDialog> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final dbHelper = DatabaseHelper();
  String? selectedImageFile;
  String? targetImageFile;
  String? commodityCategorySelectedValue;
  int commodityCategorySelectedValueID = 0;

  void _addCommodity(int commodityCategoryId, String commodityName,
      double commodityPrice, String targetDir) async {
    final newCommodity = Commoditys(
        id: 0,
        commodityCategoryId: commodityCategoryId,
        name: commodityName,
        picUrl: targetDir,
        price: commodityPrice);
    await dbHelper.addCommodity(newCommodity);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 400,
        width: 500,
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
                onSelected: (String? selectedValue) {
                  setState(() {
                    if (selectedValue != null) {
                      // 假设字符串格式为 "id|name"
                      final parts = selectedValue.split('|');
                      if (parts.length == 2) {
                        commodityCategorySelectedValueID = int.parse(parts[0]);
                        commodityCategorySelectedValue = parts[1];
                      }
                    }
                  });
                },
                dropdownMenuEntries: widget.commodityCategorys.map(
                  (item) {
                    return DropdownMenuEntry(
                        value: '${item.id}|${item.name}', label: item.name);
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
              const Text(
                '选择图片：',
                style: TextStyle(
                  fontSize: 16.0, // 设置字体大小
                ),
              ),
              Expanded(
                child: selectedImageFile != null
                    ? GestureDetector(
                        onTap: () {
                          _selectImageFile();
                        },
                        child: Text(
                          selectedImageFile.toString(),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 1,
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          _selectImageFile();
                        },
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(146, 250, 250, 250),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text('选择图片'),
                        ),
                      ),
              ),
            ],
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
                onPressed: () async {
                  final name = nameController.text;
                  final price = priceController.text;
                  File sourceFile = File(selectedImageFile.toString());
                  if (name.isNotEmpty &&
                      price.isNotEmpty &&
                      sourceFile.isAbsolute) {
                    _addCommodity(commodityCategorySelectedValueID, name,
                        double.parse(price), targetImageFile.toString());
                    // 拷贝文件到目标路径
                    await sourceFile.copy(targetImageFile.toString());
                    setState(() {
                      selectedImageFile = '';
                    });
                    Navigator.of(context).pop(); // 关闭底部弹出框
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('不能留空'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: const Text('添加'),
              ),
            ],
          )
        ]),
      ),
    );
  }

  void _selectImageFile() async {
    try {
      // 弹出文件选择器
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'webp', 'bmp'],
      );

      if (result != null && result.files.single.path != null) {
        // 获取应用的文档目录
        final Directory appDocDir = await getApplicationDocumentsDirectory();

        // 在文档目录中创建一个子目录
        final Directory targetDir =
            Directory('${appDocDir.path}/.membership_system/images');
        if (!targetDir.existsSync()) {
          targetDir.createSync(recursive: true);
        }

        // 构建目标文件路径
        final String fileName = result.files.single.name; // 保留原始文件名
        final String targetFilePath = '${targetDir.path}/$fileName';

        setState(() {
          selectedImageFile = result.files.single.path;
          targetImageFile = targetFilePath;
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
          duration: Duration(seconds: 5),
        ),
      );
    }
  }
}
