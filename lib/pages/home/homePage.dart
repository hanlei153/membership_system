import 'package:flutter/material.dart';

import '../../common/sqflite/databaseHelper.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final dbHelper = DatabaseHelper();
  List _data = [];

  // 获取上月初末时间戳
  List<int> getLastMonthDate() {
    DateTime now = DateTime.now();
    DateTime firstDayOfLastMonth = DateTime(now.year, now.month - 1, 1);
    if (now.month == 1) {
      firstDayOfLastMonth = DateTime(now.year - 1, 12, 1);
    }
    DateTime lastDayOfLastMonth = DateTime(now.year, now.month, 0);
    int firstDayOfLastMonthTimestampInSeconds =
        firstDayOfLastMonth.millisecondsSinceEpoch ~/ 1000;
    int lastDayOfLastMonthTimestampInSeconds =
        lastDayOfLastMonth.millisecondsSinceEpoch ~/ 1000;
    return [
      firstDayOfLastMonthTimestampInSeconds,
      lastDayOfLastMonthTimestampInSeconds
    ];
  }

  // 获取本年初末时间戳
  List<int> getThisYearDate() {
    DateTime now = DateTime.now();
    DateTime firstDayOfThisYear = DateTime(now.year, 1, 1);
    DateTime lastDayOfThisYear = DateTime(now.year, 12, 31, 23, 59, 59);
    int firstDayOfThisYearTimestampInSeconds =
        firstDayOfThisYear.millisecondsSinceEpoch ~/ 1000;
    int lastDayOfThisYearTimestampInSeconds =
        lastDayOfThisYear.millisecondsSinceEpoch ~/ 1000;
    return [
      firstDayOfThisYearTimestampInSeconds,
      lastDayOfThisYearTimestampInSeconds
    ];
  }

  void initData() async {
    // 本月新增会员
    int thisMonthAddMembers = await dbHelper.searchAddMember(
        DateTime(DateTime.now().year, DateTime.now().month, 1)
                .millisecondsSinceEpoch ~/
            1000,
        DateTime.now().millisecondsSinceEpoch ~/ 1000);

    // 上月新增会员
    List lastMonthTimestamp = getLastMonthDate();
    int lastMonthAddMembers = await dbHelper.searchAddMember(
        lastMonthTimestamp[0], lastMonthTimestamp[1]);

    // 本年新增会员
    List thisYeardate = getThisYearDate();
    int thisYearAddMembers =
        await dbHelper.searchAddMember(thisYeardate[0], thisYeardate[1]);

    // 本月收入
    int thisMonthEarning = await dbHelper.searchEarning(
        DateTime(DateTime.now().year, DateTime.now().month, 1)
                .millisecondsSinceEpoch ~/
            1000,
        DateTime.now().millisecondsSinceEpoch ~/ 1000);

    // 上月收入
    int lastMonthEarning = await dbHelper.searchEarning(
        lastMonthTimestamp[0], lastMonthTimestamp[1]);

    // 本年收入
    int thisYearEarning =
        await dbHelper.searchEarning(thisYeardate[0], thisYeardate[1]);
    final data = [
      {"title": "本月新增", "value": thisMonthAddMembers, "icon": Icons.person_add},
      {"title": "上月新增", "value": lastMonthAddMembers, "icon": Icons.person_add},
      {"title": "本年新增", "value": thisYearAddMembers, "icon": Icons.person_add},
      {"title": "本月收入", "value": thisMonthEarning, "icon": Icons.attach_money},
      {"title": "上月收入", "value": lastMonthEarning, "icon": Icons.attach_money},
      {"title": "本年收入", "value": thisYearEarning, "icon": Icons.attach_money},
    ];
    setState(() {
      _data = data;
    });
  }

  @override
  void initState() {
    super.initState();
    initData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              '数据展示：',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 设置每行显示的列数
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.6,
                ),
                itemCount: _data.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_data[index]["icon"], size: 50),
                          const SizedBox(height: 16),
                          Text(_data[index]["title"],
                              style: const TextStyle(fontSize: 28)),
                          const SizedBox(height: 8),
                          Text(_data[index]["value"].toString(),
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
