import 'package:intl/intl.dart';

/// Utility class for formatting timestamps, scores, and clinical values.
class Formatters {
  Formatters._();

  /// Formats a [DateTime] to a human-readable relative string.
  /// e.g., "Today, 10:30 AM" or "Yesterday, 2:15 PM" or "May 10, 3:00 PM".
  static String formatSessionTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final sessionDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final timeStr = DateFormat('h:mm a').format(dateTime);

    if (sessionDate == today) {
      return 'Today, $timeStr';
    } else if (sessionDate == yesterday) {
      return 'Yesterday, $timeStr';
    } else {
      return '${DateFormat('MMM d').format(dateTime)}, $timeStr';
    }
  }

  /// Formats a score integer with a percentage suffix.
  static String formatScore(int score) => '$score%';

  /// Formats a double to one decimal place.
  static String formatDecimal(double value) => value.toStringAsFixed(1);

  /// Formats a large integer with comma separators.
  static String formatNumber(int value) => NumberFormat('#,##0').format(value);

  /// Returns a clinical severity label based on score.
  static String severityLabel(int score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Moderate';
    if (score >= 20) return 'Low';
    return 'Critical';
  }
}
