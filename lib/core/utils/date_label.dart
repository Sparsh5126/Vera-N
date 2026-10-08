import '../copy/app_copy.dart';

/// Short, plain dates for cards: "Today", "Sep 21", "Sep 21, 2025".
abstract final class DateLabel {
  static String of(DateTime date, DateTime now) {
    final d = date.toLocal();
    final n = now.toLocal();
    if (d.year == n.year && d.month == n.month && d.day == n.day) {
      return AppCopy.today;
    }
    final monthDay = '${AppCopy.monthsShort[d.month - 1]} ${d.day}';
    return d.year == n.year ? monthDay : '$monthDay, ${d.year}';
  }

  /// When a reminder comes: "Today, 9:00 am", "Tomorrow, 6:30 pm",
  /// "Fri, 6:00 pm" within the week, else "12 Oct, 5:30 pm".
  static String reminder(DateTime at, DateTime now) {
    final d = at.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final days = DateTime(d.year, d.month, d.day).difference(today).inDays;
    final String day;
    if (days == 0) {
      day = AppCopy.today;
    } else if (days == 1) {
      day = AppCopy.tomorrow;
    } else if (days > 1 && days < 7) {
      day = AppCopy.weekdaysShort[d.weekday - 1];
    } else {
      final monthDay = '${d.day} ${AppCopy.monthsShort[d.month - 1]}';
      day = d.year == now.year ? monthDay : '$monthDay ${d.year}';
    }
    return '$day, ${_clock(d)}';
  }

  static String _clock(DateTime d) {
    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final minute = d.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${d.hour < 12 ? 'am' : 'pm'}';
  }
}
