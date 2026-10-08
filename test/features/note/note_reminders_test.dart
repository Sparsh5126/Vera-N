import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/copy/app_copy.dart';
import 'package:vera_n/core/models/app_prefs.dart';

import '../../support/app_harness.dart';

void main() {
  late AppHarness app;
  setUp(() => app = AppHarness());

  Future<void> open(
    WidgetTester tester,
    String title, {
    AppPrefs? prefs,
  }) async {
    await app.pump(tester, prefs: prefs ?? const AppPrefs());
    await tester.tap(find.text(title));
    await tester.pumpAndSettle();
  }

  testWidgets('below the text: the reminder, or why it is not set', (
    tester,
  ) async {
    await app.storage.notes.create(
      'Errands\nremind me tomorrow at 9 am to call mum\n'
      'remind me tomorrow to water plants',
    );
    await open(tester, 'Errands');
    expect(find.text(AppCopy.remindersHeading), findsOneWidget);
    expect(find.text(AppCopy.reminderOn('Tomorrow, 9:00 am')), findsOneWidget);
    expect(find.text(AppCopy.reminderNeedsTime), findsOneWidget);
    await app.finish(tester);
  });

  testWidgets('the app schedules it, and tapping it opens the note', (
    tester,
  ) async {
    await app.storage.notes.create('Errands\nremind me in 2 hours');
    await app.pump(tester);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    final r = app.notifications.scheduled.values.single;
    app.notifications.onOpen!(r.noteRef);
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text(AppCopy.remindersHeading), findsOneWidget);
    await app.finish(tester);
  });

  testWidgets('with reminders off, nothing shows and nothing is set', (
    tester,
  ) async {
    await app.storage.notes.create('Errands\nremind me in 2 hours');
    await open(tester, 'Errands', prefs: const AppPrefs(reminders: false));
    expect(find.text(AppCopy.remindersHeading), findsNothing);
    expect(app.notifications.scheduled, isEmpty);
    await app.finish(tester);
  });
}
