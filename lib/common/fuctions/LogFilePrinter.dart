import 'dart:io';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class LogFilePrinter extends LogPrinter {
  final String logFileName;

  LogFilePrinter({this.logFileName = 'log.txt'});

  Future<String> _getLogFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    final logDirectory = Directory('${directory.path}/.membership_system');

    // 如果目录不存在，则创建
    if (!await logDirectory.exists()) {
      await logDirectory.create(recursive: true); // 创建所有需要的父目录
    }
    return '${logDirectory.path}/$logFileName';
  }

  @override
  List<String> log(LogEvent event) {
    final message = event.message;
    final level = event.level.toString().split('.').last;
    final time = DateTime.now().toString();
    final logMessage = '[$time] [$level] $message';

    // Write to the log file
    _writeToFile(logMessage);

    return [logMessage];
  }

  Future<void> _writeToFile(String logMessage) async {
  try {
    final logFilePath = await _getLogFilePath();
    final logFile = File(logFilePath);
    final logDirectory = logFile.parent;

    if (!await logDirectory.exists()) {
      await logDirectory.create(recursive: true);
    }

    await logFile.writeAsString('$logMessage\n', mode: FileMode.append);
  } catch (e) {
    debugPrint('Failed to write log: $e'); // 使用debugPrint确保Release模式可见
  }
}
}
