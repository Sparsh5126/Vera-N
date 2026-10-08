import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/ai/ai_settings.dart';
import 'package:vera_n/core/ai/scheduler/analysis_run.dart';
import 'package:vera_n/core/copy/app_copy.dart';
import 'package:vera_n/core/models/app_prefs.dart';

import '../../support/app_harness.dart';

void main() {
  late AppHarness app;

  setUp(() => app = AppHarness());

  /// "Scales" lacks the word "piano", so keywords miss it; its meaning
  /// (most of its words) is close to the query.
  Future<void> notesAnalyzed(WidgetTester tester) async {
    await tester.runAsync(() async {
      final s = app.storage;
      await s.notes.create('Scales\nscales practice every morning slowly');
      await s.notes.create('Pasta\nboil pasta with garlic and tomatoes');
      await AnalysisRun(
        analysis: s.analysis,
        suggestions: s.suggestions,
        embedder: app.embedder,
        clock: DateTime.now,
        stopRequested: () => false,
      ).run();
    });
  }

  Future<void> search(
    WidgetTester tester,
    String q, {
    AppPrefs prefs = const AppPrefs(),
  }) async {
    await app.pump(tester, prefs: prefs);
    await tester.tap(find.bySemanticsLabel(AppCopy.navSearch).last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), q);
    await tester.pump(AiSettings.similarDelay);
    await tester.pumpAndSettle();
  }

  testWidgets('notes close in meaning appear a moment after the keywords', (
    tester,
  ) async {
    await notesAnalyzed(tester);
    await search(tester, 'piano scales morning');
    expect(find.text(AppCopy.emptySearch), findsNothing);
    expect(find.text(AppCopy.similarInMeaning), findsOneWidget);
    expect(find.text('Scales'), findsOneWidget);
    expect(find.text('Pasta'), findsNothing);
    await app.finish(tester);
  });

  testWidgets('with suggestions off, there is no meaning search', (
    tester,
  ) async {
    await notesAnalyzed(tester);
    await search(
      tester,
      'piano scales morning',
      prefs: const AppPrefs(suggestions: false),
    );
    expect(find.text(AppCopy.similarInMeaning), findsNothing);
    expect(find.text(AppCopy.emptySearch), findsOneWidget);
    await app.finish(tester);
  });
}
