import 'package:flutter/foundation.dart';

/// Why a "remind me" line sets no reminder.
enum ReminderIssue {
  /// No time was given ("remind me tomorrow"): a reminder needs a date
  /// and a time.
  needsTime,

  /// The time has passed.
  past,
}

/// A "remind me …" line in a note (decided by the user, 2026-10-08): only
/// lines that ask, and only for a future date and time, set a reminder.
@immutable
class NoteReminder {
  const NoteReminder({
    required this.line,
    required this.text,
    this.at,
    this.issue,
  });

  /// The line it is on (0 is the first line).
  final int line;

  /// The line as the user wrote it, shown in the notification.
  final String text;

  /// When to remind; null when [issue] says why not.
  final DateTime? at;
  final ReminderIssue? issue;

  bool get isSet => at != null;

  @override
  bool operator ==(Object other) =>
      other is NoteReminder &&
      other.line == line &&
      other.text == text &&
      other.at == at &&
      other.issue == issue;

  @override
  int get hashCode => Object.hash(line, text, at, issue);
}
