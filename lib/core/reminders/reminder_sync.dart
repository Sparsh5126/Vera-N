import 'dart:async';

import '../copy/app_copy.dart';
import '../models/locked_folder.dart';
import '../platform/reminder_notifications.dart';
import '../storage/repositories/notes_repository.dart';
import '../storage/repositories/settings_repository.dart';
import 'reminder_parser.dart';

/// Keeps the phone's scheduled reminders matching the notes: a note's
/// "remind me" lines with a future date and time are scheduled; a line
/// changed or removed, a note trashed, or the time passed, and its
/// reminder goes. The notes are the source of truth (product spec §10a).
class ReminderSync {
  ReminderSync(
    this._notes,
    this._settings,
    this._notifications, {
    DateTime Function()? clock,
    this.onAsked,
  }) : _clock = clock ?? DateTime.now;

  final NotesRepository _notes;
  final SettingsRepository _settings;
  final ReminderNotifications _notifications;
  final DateTime Function() _clock;

  /// Called once the notification prompt was answered.
  final void Function()? onAsked;
  StreamSubscription<void>? _watching;
  Future<void> _running = Future.value();

  /// Follows the notes until [stop]. Changes are handled one at a time.
  void start() {
    _watching ??= _notes.watchReminderSources().listen((sources) {
      _running = _running.then((_) => _apply(sources)).catchError((_) {});
    });
  }

  /// Reminders off: nothing is scheduled any more.
  Future<void> stop() async {
    await _watching?.cancel();
    _watching = null;
    await _running;
    await _notifications.cancelAll();
  }

  /// Stops following the notes; what is scheduled stays.
  void dispose() {
    unawaited(_watching?.cancel());
    _watching = null;
  }

  /// Schedules what the notes ask for now (once, for tests and start-up).
  Future<void> syncOnce() async =>
      _apply(await _notes.watchReminderSources().first);

  Future<void> _apply(List<ReminderSource> sources) async {
    final wanted = _wanted(sources);
    final scheduled = await _notifications.scheduledIds();
    for (final id in scheduled.difference(wanted.keys.toSet())) {
      await _notifications.cancel(id);
    }
    final fresh = [
      for (final e in wanted.entries)
        if (!scheduled.contains(e.key)) e.value,
    ];
    if (fresh.isEmpty) return;
    await _askOnce();
    for (final r in fresh) {
      await _notifications.schedule(r);
    }
  }

  Map<int, ScheduledReminder> _wanted(List<ReminderSource> sources) {
    final now = _clock();
    return {
      for (final s in sources)
        for (final r in ReminderParser.find(s.body, s.written, now: now))
          if (r.at case final at?)
            idFor(s.ref, r.line, at): ScheduledReminder(
              id: idFor(s.ref, r.line, at),
              noteRef: s.ref,
              at: at,
              // A locked note's words never reach the notification.
              body: LockedFolder.contains(s.folder)
                  ? AppCopy.lockedReminder
                  : r.text,
            ),
    };
  }

  /// Notifications are asked for the first time a note has a reminder,
  /// never at install, and only once (Android also limits re-asking).
  Future<void> _askOnce() async {
    if (await _notifications.allowed()) return;
    if (await _settings.notificationsAsked()) return;
    await _settings.setNotificationsAsked();
    await _notifications.askToAllow();
    onAsked?.call();
  }

  /// Stable across runs: the same note, line and minute give the same id,
  /// so an unchanged reminder is left as it is.
  static int idFor(int ref, int line, DateTime at) {
    final minute = at.millisecondsSinceEpoch ~/ Duration.millisecondsPerMinute;
    return (ref * 1000003 + line * 7919 + minute) & 0x7fffffff;
  }
}
