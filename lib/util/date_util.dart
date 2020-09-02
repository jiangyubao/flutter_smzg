import 'package:date_format/date_format.dart';

class DateUtil {
  static String formatLongTime(DateTime dateTime) {
    return formatDate(
        dateTime, [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]);
  }

  static String formatShortDate(DateTime dateTime) {
    return formatDate(dateTime, [yyyy, '-', mm, '-', dd]);
  }
}
