import 'package:flutter/material.dart';

import '../../common/model/commodityCategory.dart';


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

  @override
  void initState() {
    super.initState();
    _data = generateCategory(widget.commodityCategorys);
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
        });
      },
      children: _data.map<ExpansionPanel>((CommodityCategorys item) {
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(item.name),
            );
          },
          body: ListTile(
              title: Text(item.name),
              subtitle:
                  const Text('To delete this panel, tap the trash can icon'),
              trailing: const Icon(Icons.delete),
              onTap: () {
                // setState(() {
                //   _data.removeWhere((Item currentItem) => item == currentItem);
                // });
              }),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }
}
