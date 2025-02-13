import 'package:flutter/material.dart';

import '../../common/model/member.dart';
import '../../common/model/transaction.dart';

import '../../common/sqflite/databaseHelper.dart';

class DataDisplayPage extends StatefulWidget {
  @override
  _DataDisplayPageState createState() => _DataDisplayPageState();
}

class _DataDisplayPageState extends State<DataDisplayPage> {
  final dbHelper = DatabaseHelper();
  List<Transactions> transactions = [];

  void _initTransactions() async {
    // 从数据库中获取所有交易记录
    List<Transactions> _transactions = await dbHelper.getTransactions();
    setState(() {
      transactions = _transactions;
    });
  }

  @override
  void initState() {
    super.initState();
    _initTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return Card(
              elevation: 5, // 设置阴影效果
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // 设置卡片圆角
              ),
              margin: const EdgeInsets.symmetric(
                  vertical: 10, horizontal: 15), // 卡片的间距
              child: ListTile(
                title: Text(transaction.memberName),
                subtitle: Row(
                  children: [
                    Text('金额：${transaction.amount.toString()}'),
                    SizedBox(width: 10),
                    Text('时间：${DateTime.fromMillisecondsSinceEpoch(transaction.timestamp * 1000).toLocal().year}-${DateTime.fromMillisecondsSinceEpoch(transaction.timestamp * 1000).toLocal().month.toString().padLeft(2, '0')}-${DateTime.fromMillisecondsSinceEpoch(transaction.timestamp * 1000).toLocal().day.toString().padLeft(2, '0')} ${DateTime.fromMillisecondsSinceEpoch(transaction.timestamp * 1000).toLocal().hour.toString().padLeft(2, '0')}:${DateTime.fromMillisecondsSinceEpoch(transaction.timestamp * 1000).toLocal().minute.toString().padLeft(2, '0')}:${DateTime.fromMillisecondsSinceEpoch(transaction.timestamp * 1000).toLocal().second.toString().padLeft(2, '0')}'),
                    SizedBox(width: 10),
                    Text('备注：${transaction.note}'),
                  ],
                ),
                // trailing: Text(),
              ),
            );
          },
        ),
      ),
    );
  }
}
