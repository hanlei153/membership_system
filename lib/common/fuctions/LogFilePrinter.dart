import 'dart:io';
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
    final logFilePath = await _getLogFilePath();
    final logFile = File(logFilePath);

    // If the file doesn't exist, create it
    if (!await logFile.exists()) {
      await logFile.create();
    }

    // Append the log message to the file
    await logFile.writeAsString('$logMessage\n', mode: FileMode.append);
  }
}
