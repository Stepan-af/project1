import 'package:intl/intl.dart';

/// Utility class for date/time operations
class AppDateUtils {
  AppDateUtils._();

  /// Format date as "Jan 4, 2026"
  static String formatDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }

  /// Format date as "January 4, 2026"
  static String formatDateLong(DateTime date) {
    return DateFormat('MMMM d, y').format(date);
  }

  /// Format time as "2:30 PM"
  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  /// Format date and time as "Jan 4, 2026 at 2:30 PM"
  static String formatDateTime(DateTime date) {
    return '${formatDate(date)} at ${formatTime(date)}';
  }

  /// Get start of day for a given date
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day for a given date
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Get start of today
  static DateTime get startOfToday => startOfDay(DateTime.now());

  /// Get end of today
  static DateTime get endOfToday => endOfDay(DateTime.now());

  /// Check if two dates are the same day
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Get date N days ago
  static DateTime daysAgo(int days) {
    return DateTime.now().subtract(Duration(days: days));
  }
}
