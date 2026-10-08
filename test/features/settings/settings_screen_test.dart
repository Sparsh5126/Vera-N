import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/copy/app_copy.dart';
import 'package:vera_n/core/models/app_prefs.dart';
import 'package:vera_n/core/models/rejection.dart';
import 'package:vera_n/core/models/suggestion_draft.dart';

import '../../support/app_harness.dart';

void main() {
  late AppHarness app;

  setUp(() => app = AppHarness());

  /// The Settings page itself, not the sideways pill rows inside it.
  final page = find.byWidgetPredicate(
    (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
  );

  /// Scrolls [row] to the middle of the page, clear of the nav bar.
  Future<void> reach(WidgetTester tester, Finder row) async {
    await tester.scrollUntilVisible(row, 200, scrollable: page.first);
    await tester.runAsync(
      () => Scrollable.ensureVisible(tester.element(row), alignment: 0.5),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openSettings(
    WidgetTester tester, {
    AppPrefs prefs = const AppPrefs(),
  }) async {
    await app.pump(tester, prefs: prefs);
    await tester.tap(find.bySemanticsLabel(AppCopy.navSettings).last);
    await tester.pumpAndSettle();
  }

  Future<void> suggestPair() async {
    final a = await app.storage.notes.create('Time loop\nEvery day.');
    final b = await app.storage.notes.create('Piano\nPractice daily.');
    await app.storage.suggestions.add(
      [
        SuggestionDraft(
          kind: 'link',
          noteA: a,
          noteB: b,
          score: .7,
          chunkA: 0,
          chunkB: 0,
        ),
      ],
      DateTime.now(),
      const Duration(days: 30),
    );
  }

  test('prefs are saved and read back', () async {
    final s = app.storage.settings;
    expect((await s.prefs()).chargingOnly, isTrue);
    await s.savePrefs(
      const AppPrefs(
        name: ' Asha ',
        layout: NotesLayout.list,
        theme: ThemeChoice.dark,
        suggestions: false,
      ),
    );
    final p = await s.prefs();
    expect(p.name, 'Asha');
    expect(p.layout, NotesLayout.list);
    expect(p.theme, ThemeChoice.dark);
    expect(p.suggestions, isFalse);
    expect(p.chargingOnly, isTrue);
    await app.storage.db.close();
  });

  testWidgets('choosing Dark changes the theme and is saved', (tester) async {
    await openSettings(tester);
    await tester.tap(find.text(AppCopy.themeDark));
    await tester.pumpAndSettle();
    final material = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(material.themeMode, ThemeMode.dark);
    expect((await app.storage.settings.prefs()).theme, ThemeChoice.dark);
    await app.finish(tester);
  });

  testWidgets('with suggestions off, Home shows none', (tester) async {
    await suggestPair();
    await app.pump(tester, prefs: const AppPrefs(suggestions: false));
    expect(find.bySemanticsLabel(RegExp('Has suggestions')), findsNothing);
    expect(find.textContaining('connection'), findsNothing);
    await app.finish(tester);
  });

  testWidgets('reset rejected forgets them; Undo brings them back', (
    tester,
  ) async {
    await app.storage.rejections.add(
      Rejection(
        noteA: 'a',
        hashA: 'h1',
        noteB: 'b',
        hashB: 'h2',
        rejectedAt: DateTime(2026, 10),
        deviceId: 'dev1',
      ),
    );
    await openSettings(tester);
    await reach(tester, find.text(AppCopy.showAdvanced));
    await tester.tap(find.text(AppCopy.showAdvanced));
    await tester.pumpAndSettle();
    await reach(tester, find.text(AppCopy.resetRejected));
    await tester.tap(find.text(AppCopy.resetRejected));
    await tester.pumpAndSettle();
    expect(await app.storage.rejections.all(), isEmpty);

    await tester.tap(find.text(AppCopy.undo));
    await tester.pumpAndSettle();
    expect(await app.storage.rejections.all(), hasLength(1));
    await app.finish(tester);
  });
}
