import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../common/sqflite/databaseHelper.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final dbHelper = DatabaseHelper();
  List _data = [];
  List<FlSpot> _weeklyData = [];
  List<FlSpot> _monthlyData = [];
  bool isLoading = true;

  TimeRange _selectedRange = TimeRange.week;

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

  // 获取本周第一天和最后一天
  List<int> getThisWeekDate() {
    DateTime now = DateTime.now();
    int currentWeekday = now.weekday; // 获取今天是周几（周一=1，周日=7）

    // 计算本周的第一天（周一）的 0 点
    DateTime firstDayOfWeek =
        DateTime(now.year, now.month, now.day - currentWeekday + 1);
    int firstDayTimestamp = firstDayOfWeek.millisecondsSinceEpoch ~/ 1000;

    // 计算本周的最后一天（周日）的 24 点
    DateTime lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6, hours: 24));
    int lastDayTimestamp = lastDayOfWeek.millisecondsSinceEpoch ~/ 1000;
    return [firstDayTimestamp, lastDayTimestamp];
  }

  List<int> getThisMonthDate() {
    final now = DateTime.now();
    // 当月第一天0点（精确到毫秒）
    final firstDayOfMonth = DateTime.utc(now.year, now.month, 1);
    final firstDayTimestamp = firstDayOfMonth.millisecondsSinceEpoch ~/ 1000;
    // 下个月第一天0点（本月最后一天的24点）
    final nextMonth = now.month == 12
        ? DateTime.utc(now.year + 1, 1, 1)
        : DateTime.utc(now.year, now.month + 1, 1);
    final lastDayTimestamp = nextMonth.millisecondsSinceEpoch ~/ 1000;
    return [firstDayTimestamp, lastDayTimestamp];
  }

  // 生成本周所有日期（MM/dd格式）
  List<String> _generateWeekDates() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));

    return List.generate(7, (index) {
      final date = monday.add(Duration(days: index));
      return _formatDate(date);
    });
  }

  // 生成当月所有日期列表
  List<String> _generateMonthDates() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay =
        DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));

    final dates = <String>[];
    DateTime currentDay = firstDay;

    while (
        currentDay.isBefore(lastDay) || currentDay.isAtSameMomentAs(lastDay)) {
      dates.add(_formatDate(currentDay));
      currentDay = currentDay.add(const Duration(days: 1));
    }

    return dates;
  }

  // 日期格式化工具（保证两位数）
  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  // 数据格式转换器
  Map<String, double> _convertToDateMap(List<Map<String, dynamic>> rawData) {
    final result = <String, double>{};
    for (var item in rawData) {
      item.forEach((key, value) {
        result[key] = value;
      });
    }
    return result;
  }

  // 数据转换与过滤
  Map<String, double> _convertAndFilterData(
      List<Map<String, dynamic>> rawData, List<String> validDates) {
    final result = <String, double>{};
    final dateSet = validDates.toSet();

    for (var item in rawData) {
      item.forEach((key, value) {
        if (dateSet.contains(key)) {
          result[key] = value;
        }
      });
    }
    return result;
  }

  List<Map<String, double>> completeWeeklyData(
      List<Map<String, dynamic>> rawData) {
    // 生成本周日期范围（周一至周日）
    final weekDates = _generateWeekDates();

    // 转换原始数据为Map方便查询
    final dataMap = _convertToDateMap(rawData);

    // 构建完整数据集
    return weekDates.map((dateStr) {
      return {dateStr: dataMap[dateStr] ?? 0.0};
    }).toList();
  }

  List<Map<String, double>> completeMonthlyData(
      List<Map<String, dynamic>> rawData) {
    // 生成当月所有日期（MM/dd格式）
    final monthDates = _generateMonthDates();

    // 转换原始数据为Map格式并验证日期有效性
    final dataMap = _convertAndFilterData(rawData, monthDates);

    // 构建完整数据集
    return monthDates.map((dateStr) {
      return {dateStr: dataMap[dateStr] ?? 0.0};
    }).toList();
  }

  void initWeekData() async {
    List<int> weekDate = getThisWeekDate();
    List<Map<String, dynamic>> weekSales =
        await dbHelper.searchSales(weekDate[0], weekDate[1]);
    // 使用Map来聚合数据，提高效率
    final Map<String, double> weekSalesMap = {};
    // 处理原始数据
    for (var sale in weekSales) {
      // 确保使用UTC时间避免时区问题
      final date =
          DateTime.fromMillisecondsSinceEpoch(sale['timestamp'] * 1000).toUtc();
      final dateKey = DateFormat('MM/dd').format(date);

      // 累加销售额
      weekSalesMap.update(
        dateKey,
        (value) => value + sale['amount'],
        ifAbsent: () => sale['amount'],
      );
    }
    // 转换为列表格式并补全数据
    List<Map<String, double>> weeklySales =
        weekSalesMap.entries.map((e) => {e.key: e.value}).toList();

    weeklySales = completeWeeklyData(weeklySales);

    // 生成折线图数据
    double x = 0;
    for (var map in weeklySales) {
      x += 1; // X轴递增
      map.forEach((key, value) {
        _weeklyData.add(FlSpot(x, value / 1000)); // 转换为千分位
      });
    }
    setState(() {
      _weeklyData = _weeklyData;
      isLoading = false;
    });
  }

  void initMonthData() async {
    List<int> monthDate = getThisMonthDate();
    // 获取销售数据
    List<Map<String, dynamic>> monthSales =
        await dbHelper.searchSales(monthDate[0], monthDate[1]);
    // 使用Map来聚合数据，提高效率
    final Map<String, double> monthSalesMap = {};
    // 处理原始数据
    for (var sale in monthSales) {
      // 确保使用UTC时间避免时区问题
      final date =
          DateTime.fromMillisecondsSinceEpoch(sale['timestamp'] * 1000).toUtc();
      final dateKey = DateFormat('MM/dd').format(date);

      // 累加销售额
      monthSalesMap.update(
        dateKey,
        (value) => value + sale['amount'],
        ifAbsent: () => sale['amount'],
      );
    }
    // 转换为列表格式并补全数据
    List<Map<String, double>> monthlySales =
        monthSalesMap.entries.map((e) => {e.key: e.value}).toList();

    monthlySales = completeMonthlyData(monthlySales);
    // 生成折线图数据
    for (var map in monthlySales) {
      map.forEach((key, value) {
        double x = double.parse(key.split('/')[1]);
        _monthlyData.add(FlSpot(x, value / 1000)); // 转换为千分位
      });
    }
    setState(() {
      _monthlyData = _monthlyData;
    });
  }

  void initMembersData() async {
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
    initMembersData();
    initWeekData();
    initMonthData();
  }

  double _getMaxY(List<FlSpot> data) {
    if (data.isEmpty) return 1;
    // 最大值加1留出顶部间距
    var maxY = (data.map((spot) => spot.y).reduce(max) + 1).round().toDouble();
    return maxY;
  }

  @override
  Widget build(BuildContext context) {
    LineChartData buildChartData() {
      final currentData =
          _selectedRange == TimeRange.week ? _weeklyData : _monthlyData;
      final maxX = _selectedRange == TimeRange.week
          ? 7.0
          : _monthlyData.length.toDouble();
      final interval = _selectedRange == TimeRange.week ? 1.0 : 1.0;
      final dateLabels = _selectedRange == TimeRange.week
          ? ['周一', '周二', '周三', '周四', '周五', '周六', '周日']
          : List.generate(_monthlyData.length, (i) => '${i + 1}日');
      return LineChartData(
        backgroundColor: Colors.white,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 1,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withValues(alpha: 0.2),
            strokeWidth: 1,
            dashArray: [5],
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: Colors.grey.withValues(alpha: 0.2),
            strokeWidth: 1,
            dashArray: [5],
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: interval,
              getTitlesWidget: (value, meta) {
                final index = (value ~/ interval) - 1;
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(index >= 0 && index < dateLabels.length
                      ? dateLabels[index]
                      : ''),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text('${value.toInt()}k'),
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border:
              Border.all(color: Colors.blueGrey.withValues(alpha: 0.3), width: 0.3),
        ),
        minX: 1,
        maxX: maxX,
        minY: 0,
        maxY: _getMaxY(currentData),
        lineBarsData: [
          LineChartBarData(
            spots: currentData,
            isCurved: true,
            curveSmoothness: 0.3,
            color: Colors.blue,
            barWidth: 2,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                radius: 2,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: Colors.blueAccent,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withValues(alpha: 0.3),
                  Colors.blue.withValues(alpha: 0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            shadow: BoxShadow(
              color: Colors.blue.withValues(alpha: 0.2),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
              return LineTooltipItem(
                '${spot.y} k\n${dateLabels[spot.x.toInt() - 1]}',
                const TextStyle(color: Colors.white),
              );
            }).toList(),
          ),
        ),
      );
    }

    Widget buildTimeButton(String text, TimeRange range) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: _selectedRange == range
              ? Colors.white
              : const Color.fromARGB(179, 58, 199, 255),
          backgroundColor: _selectedRange == range
              ? const Color.fromARGB(179, 58, 199, 255)
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color.fromARGB(179, 58, 199, 255)),
          ),
        ),
        onPressed: () {
          setState(() {
            _selectedRange = range;
          });
        },
        child: Text(text),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                '数据展示：',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              height: (_selectedRange == TimeRange.week
                      ? _getMaxY(_weeklyData) > 10
                      : _getMaxY(_monthlyData) > 10)
                  ? 450
                  : 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    const Text(
                      '销售数据：',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    buildTimeButton('本周', TimeRange.week),
                    const SizedBox(width: 10),
                    buildTimeButton('本月', TimeRange.month)
                  ]),
                  const SizedBox(height: 16),
                  isLoading
                      ? const Spacer()
                      : Expanded(child: LineChart(buildChartData()))
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(16),
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
          ],
        ),
      ),
    );
  }
}

enum TimeRange { week, month }
