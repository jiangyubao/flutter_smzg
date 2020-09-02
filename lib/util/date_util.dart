import 'package:date_format/date_format.dart';

class DateUtil {
  static String formatNow() {
    return formatDate(
        DateTime.now(), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]);
  }
}
