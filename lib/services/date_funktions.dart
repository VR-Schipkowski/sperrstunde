import 'package:intl/intl.dart';

class DateHelper {
  static String getFormattedDate(DateTime date) {
    if (isSameDay(date, DateTime.now())) {
      return 'Heute';
    } else if (isSameDay(date, DateTime.now().add(Duration(days: 1)))) {
      return 'Morgen';
    } else {
      return formatDate(date);
    }
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static String formatDate(DateTime? date) {
    if (date == null) {
      return '';
    }
    final DateFormat formatter = DateFormat('EEEE, d.M', 'de_DE');
    return formatter.format(date);
  }

  static String getFormattedTime(DateTime? date) {
    if (date == null) {
      return '';
    }
    final DateFormat formatter = DateFormat('HH:mm', 'de_DE');
    return formatter.format(date);
  }
}
