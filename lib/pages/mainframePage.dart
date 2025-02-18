import 'package:flutter/material.dart';

import 'membersManage/memberListPage.dart';
import 'dataDisplay/dataDisplay.dart';
import 'home/homePage.dart';
import 'commodityManage/commodityManagePage.dart';

class MianFramePage extends StatefulWidget {
  const MianFramePage({super.key, required this.title});

  final String title;

  @override
  State<MianFramePage> createState() => _MianFramePageState();
}

class _MianFramePageState extends State<MianFramePage> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(fontSize: 14);
  double? iconSize = 20;
  double iconPadding = 10;
  static List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    MemberListPage(),
    CommodityManagePage(),
    DataDisplayPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Row(
        children: <Widget>[
          // 左侧导航栏
          NavigationRail(
            selectedIndex: _selectedIndex,
            elevation: 5,
            onDestinationSelected: _onItemTapped,
            labelType: NavigationRailLabelType.all,
            destinations: [
              NavigationRailDestination(
                padding: EdgeInsets.only(top: iconPadding),
                icon: Icon(Icons.home, size: iconSize),
                label: Text('首页', style: optionStyle),
              ),
              NavigationRailDestination(
                padding: EdgeInsets.only(top: iconPadding),
                icon: Icon(Icons.group, size: iconSize),
                label: Text('会员管理', style: optionStyle),
              ),
              NavigationRailDestination(
                padding: EdgeInsets.only(top: iconPadding),
                icon: Icon(Icons.shopping_cart, size: iconSize),
                label: Text('商品管理', style: optionStyle),
              ),
              NavigationRailDestination(
                padding: EdgeInsets.only(top: iconPadding),
                icon: Icon(Icons.receipt, size: iconSize),
                label: Text('消费记录', style: optionStyle),
              ),
            ],
          ),

          // 右侧显示的页面
          Expanded(
            child: _widgetOptions[_selectedIndex],
          ),
        ],
      ),
    );
  }
}
