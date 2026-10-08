/// A clock time in a "remind me" line.
typedef ClockTime = ({int hour, int minute, bool meridiem});

/// Times and spans from now in a "remind me" line (lower case).
abstract final class ReminderTime {
  static final _span = RegExp(
    r'\bin\s+(\d+|an?|one|two|three|four|five|six|ten|fifteen|twenty|thirty)'
    r'\s*(minutes?|mins?|hours?|hrs?|days?|weeks?)\b',
  );
  static final _meridiem = RegExp(
    r'\b(\d{1,2})(?:[:.](\d{2}))?\s*(a\.?m\.?|p\.?m\.?)(?=\W|$)',
  );
  static final _clock24 = RegExp(r'\b(\d{1,2}):(\d{2})\b');
  static final _atHour = RegExp(r'\bat\s+(\d{1,2})\b(?![:./\d])');

  static const _words = {
    'a': 1,
    'an': 1,
    'one': 1,
    'two': 2,
    'three': 3,
    'four': 4,
    'five': 5,
    'six': 6,
    'ten': 10,
    'fifteen': 15,
    'twenty': 20,
    'thirty': 30,
  };

  /// "in 10 minutes", "in an hour", "in 3 days": that long from [now].
  static DateTime? span(String lower, DateTime now) {
    final m = _span.firstMatch(lower);
    if (m == null) return null;
    final n = int.tryParse(m.group(1)!) ?? _words[m.group(1)!]!;
    final unit = m.group(2)!;
    final Duration d;
    if (unit.startsWith('m')) {
      d = Duration(minutes: n);
    } else if (unit.startsWith('h')) {
      d = Duration(hours: n);
    } else if (unit.startsWith('w')) {
      d = Duration(days: 7 * n);
    } else {
      d = Duration(days: n);
    }
    return now.add(d);
  }

  /// The clock time asked for, if any. [ClockTime.meridiem] is true when
  /// am / pm (or a word like "noon") made it unambiguous.
  static ClockTime? clock(String lower) {
    final m = _meridiem.firstMatch(lower);
    if (m != null) {
      var hour = int.parse(m.group(1)!);
      final minute = int.tryParse(m.group(2) ?? '') ?? 0;
      if (hour < 1 || hour > 12 || minute > 59) return null;
      final pm = m.group(3)!.startsWith('p');
      hour = hour % 12 + (pm ? 12 : 0);
      return (hour: hour, minute: minute, meridiem: true);
    }
    final c = _clock24.firstMatch(lower);
    if (c != null) {
      final hour = int.parse(c.group(1)!);
      final minute = int.parse(c.group(2)!);
      if (hour > 23 || minute > 59) return null;
      return (hour: hour, minute: minute, meridiem: hour > 12 || hour == 0);
    }
    final a = _atHour.firstMatch(lower);
    if (a != null) {
      final hour = int.parse(a.group(1)!);
      if (hour > 23) return null;
      return (hour: hour, minute: 0, meridiem: hour > 12 || hour == 0);
    }
    return _wordTime(lower);
  }

  static ClockTime? _wordTime(String lower) {
    if (RegExp(r'\bnoon\b|\bmidday\b').hasMatch(lower)) {
      return (hour: 12, minute: 0, meridiem: true);
    }
    if (RegExp(r'\btonight\b').hasMatch(lower)) {
      return (hour: 20, minute: 0, meridiem: true);
    }
    return null;
  }
}
