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
}
