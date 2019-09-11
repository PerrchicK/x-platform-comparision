import 'package:ironbreeze/src/util/utils.dart';
//import 'package:logging/logging.dart';

class AppLogger {
  static void error(dynamic errorLogMessage) {
    if (!Utils.isInDebugMode) return;

    // https://flutter.dev/docs/cookbook/maintenance/error-reporting
    print("Error: $errorLogMessage at:\n ${StackTrace.current}");
  }

  static void log(dynamic logMessage, {withStackTrace = true}) {
    if (!Utils.isInDebugMode) return;

    if (withStackTrace) {
      String line = StackTrace.current.toString().split('\n')[1];
      line = line.replaceAll("flutter: #1", "");
      print("$line: $logMessage");
    } else {
      print(logMessage);
    }
  }
}
