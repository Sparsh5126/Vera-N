import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/models/note_reminder.dart';
import 'package:vera_n/core/reminders/reminder_parser.dart';

void main() {
  // Thursday 8 October 2026, 2 pm.
  final now = DateTime(2026, 10, 8, 14);

  DateTime? at(String line) => ReminderParser.find(line, now).single.at;
  ReminderIssue? issue(String line) =>
      ReminderParser.find(line, now).single.issue;

  test('only lines that ask: no "remind me", no reminder', () {
    expect(ReminderParser.find('Call mum tomorrow at 9 am', now), isEmpty);
    expect(ReminderParser.find('Title\nreminders are useful', now), isEmpty);
  });

  test('a date and a time', () {
    expect(
      at('remind me tomorrow at 9 am to call mum'),
      DateTime(2026, 10, 9, 9),
    );
    expect(at('Remind me on Friday at 6 pm'), DateTime(2026, 10, 9, 18));
    expect(
      at('remind me next Thursday at 10:30'),
      DateTime(2026, 10, 15, 10, 30),
    );
    expect(at('remind me 12 Oct at 5:30 pm'), DateTime(2026, 10, 12, 17, 30));
    expect(at('remind me October 20th at 7 a.m.'), DateTime(2026, 10, 20, 7));
    expect(at('remind me 15/11 at 17:00'), DateTime(2026, 11, 15, 17));
    expect(
      at('remind me day after tomorrow at noon'),
      DateTime(2026, 10, 10, 12),
    );
    expect(at('remind me tonight'), DateTime(2026, 10, 8, 20));
  });

  test('a date that has passed this year means next year', () {
    expect(at('remind me 3 March at 9 am'), DateTime(2027, 3, 3, 9));
  });

  test('a span from now', () {
    expect(at('remind me in 10 minutes'), now.add(const Duration(minutes: 10)));
    expect(at('remind me in an hour'), now.add(const Duration(hours: 1)));
    expect(at('remind me in 3 days'), now.add(const Duration(days: 3)));
  });

  test('a time alone is today; "at 5" after 5 am means 5 pm', () {
    expect(at('remind me at 4:30 pm'), DateTime(2026, 10, 8, 16, 30));
    expect(at('remind me at 5 to stretch'), DateTime(2026, 10, 8, 17));
  });

  test('a date with no time asks for one; a past time sets nothing', () {
    expect(
      issue('remind me tomorrow to water plants'),
      ReminderIssue.needsTime,
    );
    expect(issue('remind me about the trip'), ReminderIssue.needsTime);
    expect(issue('remind me today at 9 am'), ReminderIssue.past);
    expect(issue('remind me 1/1/2020 at 9 am'), ReminderIssue.past);
  });

  test('ordinary words are not dates or times', () {
    expect(
      issue('remind me to buy sun cream at the market'),
      ReminderIssue.needsTime,
    );
    expect(issue('remind me to decide 3 things'), ReminderIssue.needsTime);
  });

  test('relative words count from when the note was written, not from '
      'each later look', () {
    final written = DateTime(2026, 10, 8, 23);
    final nextMorning = DateTime(2026, 10, 9, 8);
    final tomorrow = ReminderParser.find(
      'remind me tomorrow at 9 am',
      written,
      now: nextMorning,
    ).single;
    expect(tomorrow.at, DateTime(2026, 10, 9, 9));
    final soon = ReminderParser.find(
      'remind me in 2 hours',
      written,
      now: nextMorning,
    ).single;
    expect(soon.issue, ReminderIssue.past);
  });

  test('each asking line is its own reminder, in a checklist too', () {
    final found = ReminderParser.find(
      'Trip\n- [ ] remind me tomorrow at 8 am to pack\nnotes\n'
      'remind me in 2 hours',
      now,
    );
    expect(found.map((r) => r.line), [1, 3]);
    expect(found.first.text, '☐ remind me tomorrow at 8 am to pack');
    expect(found.every((r) => r.isSet), isTrue);
  });
}
