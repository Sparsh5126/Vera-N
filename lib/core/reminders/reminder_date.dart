/// Dates in a "remind me" line (lower case), as the day they name.
abstract final class ReminderDate {
  static const _months = [
    'jan',
    'feb',
    'mar',
    'apr',
    'may',
    'jun',
    'jul',
    'aug',
    'sep',
    'oct',
    'nov',
    'dec',
  ];
  static const _weekdays = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  /// Month names and their usual short forms only, so "market 5" or
  /// "decide 3" are not dates.
  static const _monthWord =
      r'(jan(?:uary)?|feb(?:ruary)?|mar(?:ch)?|apr(?:il)?|may|june?|july?'
      r'|aug(?:ust)?|sep(?:t(?:ember)?)?|oct(?:ober)?|nov(?:ember)?'
      r'|dec(?:ember)?)\b';
  static final _dayMonth = RegExp(
    r'\b(\d{1,2})(?:st|nd|rd|th)?\s+(?:of\s+)?' +
        _monthWord +
        r'(?:\s+(\d{4}))?\b',
  );
  static final _monthDay = RegExp(
    r'\b' + _monthWord + r'\s+(\d{1,2})(?:st|nd|rd|th)?(?:,?\s+(\d{4}))?\b',
  );
  static final _numeric = RegExp(
    r'\b(\d{1,2})[/.-](\d{1,2})(?:[/.-](\d{2,4}))?\b',
  );

  /// Full day names only: "sun cream" or "sat down" are not days.
  static final _weekday = RegExp(
    r'\b(next\s+)?(monday|tuesday|wednesday|thursday|friday|saturday'
    r'|sunday)\b',
  );

  /// The day [lower] names, or null if it names none.
  static DateTime? find(String lower, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    if (RegExp(r'\bday after tomorrow\b').hasMatch(lower)) {
      return today.add(const Duration(days: 2));
    }
    if (RegExp(r'\b(tomorrow|tmrw|tmr)\b').hasMatch(lower)) {
      return today.add(const Duration(days: 1));
    }
    if (RegExp(r'\b(today|tonight)\b').hasMatch(lower)) return today;
    return _calendar(lower, today) ?? _weekdayFrom(lower, today);
  }

  static DateTime? _calendar(String lower, DateTime today) {
    final dm = _dayMonth.firstMatch(lower);
    if (dm != null) {
      return _day(today, int.parse(dm.group(1)!), dm.group(2)!, dm.group(3));
    }
    final md = _monthDay.firstMatch(lower);
    if (md != null) {
      return _day(today, int.parse(md.group(2)!), md.group(1)!, md.group(3));
    }
    final n = _numeric.firstMatch(lower);
    if (n == null) return null;
    final month = int.parse(n.group(2)!);
    if (month < 1 || month > 12) return null;
    return _day(today, int.parse(n.group(1)!), _months[month - 1], n.group(3));
  }

  /// Day [day] of [month]; without a year, the next time that date comes.
  static DateTime? _day(DateTime today, int day, String month, String? y) {
    final m = _months.indexOf(month.substring(0, 3)) + 1;
    if (m == 0 || day < 1 || day > 31) return null;
    var year = y == null ? today.year : int.parse(y);
    if (year < 100) year += 2000;
    final date = DateTime(year, m, day);
    if (date.month != m) return null; // e.g. 31 Feb
    if (y == null && date.isBefore(today)) return DateTime(year + 1, m, day);
    return date;
  }

  /// "Friday" or "on Friday": the next Friday, today included; "next
  /// Friday": the one after today.
  static DateTime? _weekdayFrom(String lower, DateTime today) {
    final w = _weekday.firstMatch(lower);
    if (w == null) return null;
    final target = _weekdays.indexOf(w.group(2)!) + 1;
    var ahead = (target - today.weekday) % 7;
    if (w.group(1) != null && ahead == 0) ahead = 7;
    return today.add(Duration(days: ahead));
  }
}
