import 'package:flutter/material.dart';

import 'membersManage/memberListPage.dart';
import 'settings/settingPage.dart';
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
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    MemberListPage(),
    CommodityManagePage(),
    SettingsPage(),
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
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      body: Center(
        child: _widgetOptions[_selectedIndex],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                // color: Colors.blue,
              ),
              child: Text('导航'),
            ),
            ListTile(
              title: const Text('首页'),
              selected: _selectedIndex == 0,
              onTap: () {
                _onItemTapped(0);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('会员管理'),
              selected: _selectedIndex == 1,
              onTap: () {
                _onItemTapped(1);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('商品管理'),
              selected: _selectedIndex == 2,
              onTap: () {
                _onItemTapped(2);
                Navigator.of(context).pop();
              },
            ),
            // ListTile(
            //   title: const Text('设置'),
            //   selected: _selectedIndex == 10,
            //   onTap: () {
            //     _onItemTapped(10);
            //     Navigator.of(context).pop();
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}