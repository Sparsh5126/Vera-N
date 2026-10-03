import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/styles/app_styles.dart';

import 'support/app_harness.dart';

void main() {
  late AppHarness app;

  setUp(() => app = AppHarness());

  for (final brightness in Brightness.values) {
    testWidgets('builds with style tokens in $brightness', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = brightness;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await app.pump(tester);

      final context = tester.element(find.byType(Scaffold).first);
      final expected = brightness == Brightness.dark
          ? AppPalette.dark
          : AppPalette.light;
      expect(context.colors.background, expected.background);
      expect(Theme.of(context).scaffoldBackgroundColor, expected.background);
      await app.finish(tester);
    });
  }

  testWidgets('first launch shows the empty Home', (tester) async {
    await app.pump(tester);
    expect(find.text('Vera N'), findsOneWidget);
    expect(find.text('Write your first thought.'), findsOneWidget);
    expect(find.text('New note'), findsOneWidget);
    await app.finish(tester);
  });

  testWidgets('Home cards show link titles, not file names', (tester) async {
    await app.storage.notes.create(
      'Future Self\nsee [[20261003-153228-a7f3|Time Loop]] now',
    );
    await app.pump(tester);
    expect(find.text('see Time Loop now'), findsOneWidget);
    expect(find.textContaining('20261003'), findsNothing);
    await app.finish(tester);
  });

  testWidgets('write a note, go back, see it on Home', (tester) async {
    await app.pump(tester);
    await tester.tap(find.text('New note'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Future Self\nआज की बात');
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Write your first thought.'), findsNothing);
    expect(find.text('Future Self'), findsOneWidget);
    expect(find.text('आज की बात'), findsOneWidget);
    await app.finish(tester);
  });
}
