import '../models/note_reminder.dart';
import '../storage/files/note_markup.dart';
import 'reminder_date.dart';
import 'reminder_time.dart';

/// Finds "remind me …" lines in a note and when each asks to be reminded
/// (product spec §10a). Plain rules on this device, in English:
/// - a time: "at 9 am", "9:30 pm", "at 17:00", "noon", "tonight";
/// - a date: "today", "tomorrow", "day after tomorrow", "on Friday",
///   "next Monday", "12 Oct", "Oct 12", "12/10" (day first);
/// - or a span from now: "in 10 minutes", "in 2 hours", "in 3 days".
///
/// Words like "tomorrow" or "in 2 hours" count from [written], when the
/// note last changed, so the reminder stays put however often the note is
/// read again; only a future time counts, judged by [now]. A time alone
/// means that day (or that evening, if "at 5" had passed that morning). A
/// date with no time sets nothing and says so.
abstract final class ReminderParser {
  static final _ask = RegExp(r'\bremind me\b', caseSensitive: false);

  static List<NoteReminder> find(
    String body,
    DateTime written, {
    DateTime? now,
  }) {
    final lines = body.split('\n');
    return [
      for (var i = 0; i < lines.length; i++)
        if (_ask.firstMatch(lines[i]) case final m?)
          _reminder(
            i,
            lines[i],
            lines[i].substring(m.end),
            written,
            now ?? written,
          ),
    ];
  }

  static NoteReminder _reminder(
    int line,
    String text,
    String rest,
    DateTime written,
    DateTime now,
  ) {
    final shown = NoteMarkup.display(text).trim();
    final lower = rest.toLowerCase();
    final at =
        ReminderTime.span(lower, written) ?? _dateAndTime(lower, written);
    if (at == null) {
      return NoteReminder(
        line: line,
        text: shown,
        issue: ReminderIssue.needsTime,
      );
    }
    if (!at.isAfter(now)) {
      return NoteReminder(line: line, text: shown, issue: ReminderIssue.past);
    }
    return NoteReminder(line: line, text: shown, at: at);
  }

  static DateTime? _dateAndTime(String lower, DateTime now) {
    final time = ReminderTime.clock(lower);
    if (time == null) return null;
    final date = ReminderDate.find(lower, now);
    final day = date ?? DateTime(now.year, now.month, now.day);
    var at = DateTime(day.year, day.month, day.day, time.hour, time.minute);
    // "Remind me at 5" in the afternoon means 5 pm, not this morning.
    if (date == null && !time.meridiem && time.hour < 12 && !at.isAfter(now)) {
      at = at.add(const Duration(hours: 12));
    }
    return at;
  }
}
