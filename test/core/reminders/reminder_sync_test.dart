import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/copy/app_copy.dart';
import 'package:vera_n/core/models/locked_folder.dart';
import 'package:vera_n/core/reminders/reminder_sync.dart';

import '../../support/app_harness.dart';
import '../../support/fake_reminder_notifications.dart';

void main() {
  late AppHarness app;
  late FakeReminderNotifications shown;
  late ReminderSync sync;

  setUp(() {
    app = AppHarness();
    shown = FakeReminderNotifications();
    sync = ReminderSync(app.storage.notes, app.storage.settings, shown);
  });
  tearDown(() async {
    app.storage.writer.dispose();
    await app.storage.db.close();
  });

  test('only notes that ask, only future times', () async {
    final notes = app.storage.notes;
    final asks = await notes.create(
      'Call\nremind me tomorrow at 9 am to call mum',
    );
    await notes.create('Plain\ncall mum tomorrow at 9 am');
    await notes.create('Vague\nremind me tomorrow');
    await notes.create('Late\nremind me 1/1/2020 at 9 am');
    await sync.syncOnce();
    // "Tomorrow" counts from when the note was written.
    final written = (await notes.getNote(asks))!.modified;
    final r = shown.scheduled.values.single;
    expect(r.noteRef, asks);
    expect(r.at, DateTime(written.year, written.month, written.day + 1, 9));
    expect(r.body, 'remind me tomorrow at 9 am to call mum');
  });

  test('editing the line moves it; removing it or trashing the note '
      'cancels it', () async {
    final notes = app.storage.notes;
    final ref = await notes.create('Call\nremind me tomorrow at 9 am');
    await sync.syncOnce();
    final first = shown.scheduled.keys.single;

    await notes.updateBody(ref, 'Call\nremind me tomorrow at 10 am');
    await sync.syncOnce();
    expect(shown.scheduled.keys.single, isNot(first));
    expect(shown.scheduled.values.single.at.hour, 10);

    await notes.updateBody(ref, 'Call\nno longer needed');
    await sync.syncOnce();
    expect(shown.scheduled, isEmpty);

    await notes.updateBody(ref, 'Call\nremind me tomorrow at 9 am');
    await sync.syncOnce();
    await notes.trash(ref);
    await sync.syncOnce();
    expect(shown.scheduled, isEmpty);
  });

  test('a locked note never shows its words', () async {
    final notes = app.storage.notes;
    final ref = await notes.create('Diary\nremind me tomorrow at 9 am');
    await notes.moveToFolder(ref, LockedFolder.into(''));
    await sync.syncOnce();
    expect(shown.scheduled.values.single.body, AppCopy.lockedReminder);
  });

  test('notifications are asked for once, when a reminder first appears; '
      'reminders off cancels them all', () async {
    await sync.syncOnce();
    expect(shown.asked, 0);
    await app.storage.notes.create('A\nremind me in 2 hours');
    await sync.syncOnce();
    expect(shown.asked, 1);
    shown.notificationsAllowed = false;
    await app.storage.notes.create('B\nremind me in 3 hours');
    await sync.syncOnce();
    expect(shown.asked, 1);
    await sync.stop();
    expect(shown.scheduled, isEmpty);
  });
}
