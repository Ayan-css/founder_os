import 'package:intl/intl.dart';

abstract final class AppDateUtils {
  static final _dbFormat      = DateFormat('yyyy-MM-dd');
  static final _displayFormat = DateFormat('EEEE, MMMM d');

  static String toDbDate(DateTime date)   => _dbFormat.format(date);
  static DateTime fromDbDate(String date) => _dbFormat.parse(date);
  static String todayDbDate()             => toDbDate(DateTime.now());

  static String formatDisplayDate(DateTime date) => _displayFormat.format(date);

  static String getGreeting() {
    final h = DateTime.now().hour;
    if (h < 5)  return 'Still up?';
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    if (h < 21) return 'Good evening';
    return 'Wind down';
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static int getDayOfYear() {
    final now = DateTime.now();
    return now.difference(DateTime(now.year, 1, 1)).inDays;
  }
}
