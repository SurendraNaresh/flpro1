import 'dart:async';
import 'dart:io';

class Logger {
  final String appName;
  final String logFile;
  DateTime? startTime;
  DateTime? endTime;
  Duration? totalTime;
  double? uptime;
  final Map<String, dynamic> otherData = {};

  Logger(this.appName, this.logFile) {
    startTime = DateTime.now();
  }

  void addData(String key, dynamic value) {
    otherData[key] = value;
  }

  void stop() {
    endTime = DateTime.now();
    totalTime = endTime!.difference(startTime!);
    uptime = totalTime!.inSeconds.toDouble();
  }

  String formatTimeOnly(DateTime dateTime) {
    String formattedTime = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
    if (dateTime.difference(DateTime.now()).inDays != 0) {
      formattedTime = '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} $formattedTime';
    }
    return formattedTime;
  }

  Future<void> writeLog() async {
    List<dynamic> data = [
      appName,
      startTime!,
      formatTimeOnly(endTime!),
      "",
      totalTime,
      uptime,
      otherData,
    ];
    List<String> dataStrings = data.map((value) => value.toString()).toList();
    await File(logFile).writeAsString(dataStrings.join(',') + '\n', mode: FileMode.append);
  }
}

void main() async {
  Logger logger = Logger('testLogApp', 'mylog.csv');
  logger.addData('version', '1.0');
  logger.stop();
  await logger.writeLog();
  print('Log written successfully.');
}
