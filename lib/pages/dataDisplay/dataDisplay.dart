import 'package:flutter/material.dart';
import '../../common/model/transaction.dart';
import '../../common/sqflite/databaseHelper.dart';
import '../../common/model/member.dart';

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
                title: Text(
                    '${transaction.memberName} (${transaction.memberPhone})'),
                subtitle: Row(
                  children: [
                    Text('金额：${transaction.amount.toString()}'),
                    SizedBox(width: 20),
                    Text(
                        '时间：${DateTime.fromMillisecondsSinceEpoch(transaction.timestamp * 1000).toLocal().year}-${DateTime.fromMillisecondsSinceEpoch(transaction.timestamp * 1000).toLocal().month.toString().padLeft(2, '0')}-${DateTime.fromMillisecondsSinceEpoch(transaction.timestamp * 1000).toLocal().day.toString().padLeft(2, '0')} ${DateTime.fromMillisecondsSinceEpoch(transaction.timestamp * 1000).toLocal().hour.toString().padLeft(2, '0')}:${DateTime.fromMillisecondsSinceEpoch(transaction.timestamp * 1000).toLocal().minute.toString().padLeft(2, '0')}:${DateTime.fromMillisecondsSinceEpoch(transaction.timestamp * 1000).toLocal().second.toString().padLeft(2, '0')}'),
                    SizedBox(width: 20),
                    Text('备注：${transaction.note}'),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () async {
                    // 检查交易是否已退款
                    if (transaction.isRefund == 0 && transaction.type == '消费') {
                      // 执行退款操作
                      await dbHelper.refundBalancePoints(
                          transaction.memberId, transaction.amount);
                      await dbHelper.updateTransaction(transaction.id!, 1);
                      _initTransactions();
                    } else if (transaction.type == '充值') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('充值记录无法退款')),
                      );
                    }
                  },
                  child: Text(transaction.isRefund == 0 ? '退款' : '已退款'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
