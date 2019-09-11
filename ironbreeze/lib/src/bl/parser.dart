import 'package:ironbreeze/src/util/utils.dart';

class Parser {
  static DateTime parseDateFromIsoString(String dateTimeString,
      [bool toLocalTime = false]) {
    if (dateTimeString == null) return null;
    if (dateTimeString.length == 0) return null;

    dateTimeString = dateTimeString.replaceAll('Z', "");
    final components = dateTimeString.split('T');
    if (components.length != 2) {
      if (components.length == 1 &&
          !dateTimeString.contains('T') &&
          dateTimeString.contains('-')) {
        components.add("00:00:00");
      } else {
        return null;
      }
    }
    String dateString = components[0];
    String timeString = components[1];
    var dateComponents = dateString.split('-');
    var timeComponents = timeString.split(':');
    if (dateComponents.length != 3) return null;
    if (timeComponents.length == 0) {
      timeComponents = ["00", "00", "00"];
    } else if (timeComponents.length == 2) {
      timeComponents.add("00");
    }

    if (timeComponents.length != 3) return null;

    const millisecond = 0;
    const microsecond = 0;

    int timeZoneOffset = Utils.now().timeZoneOffset.inHours;
    int offset = toLocalTime ? timeZoneOffset : 0;

    final int year = int.tryParse(dateComponents[0]);
    final int month = int.tryParse(dateComponents[1]);
    final int day = int.tryParse(dateComponents[2]);

    final int hours = int.tryParse(timeComponents[0]) + offset;
    final int minutes = int.tryParse(timeComponents[1]);
    final int seconds = int.tryParse(timeComponents[2]);

    return DateTime.utc(
        year, month, day, hours, minutes, seconds, millisecond, microsecond);
  }

  static int tryParseInt(dynamic intString, [int defaultValue]) {
    if (intString == null) return defaultValue;
    return int.tryParse(intString.toString()) ?? defaultValue;
  }

  static double tryParseDouble(dynamic doubleString, [double defaultValue]) {
    if (doubleString == null) return defaultValue;
    return double.tryParse(doubleString.toString()) ?? defaultValue;
  }

  static bool tryParseBool(String boolAsString, [bool defaultValue = false]) {
    if (boolAsString == null) return defaultValue;
    return boolAsString.toString() == '1' || boolAsString.toString() == 'true';
  }
}
