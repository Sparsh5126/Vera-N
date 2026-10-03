import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app_harness.dart';

/// A capture entry point (app shortcut; later widget and tile) starts the
/// app on the new-note route.
void main() {
  late AppHarness app;

  setUp(() => app = AppHarness());

  Future<void> launchIntoCapture(WidgetTester tester) async {
    tester.binding.platformDispatcher.defaultRouteNameTestValue = '/note/new';
    addTearDown(
      tester.binding.platformDispatcher.clearDefaultRouteNameTestValue,
    );
    // Even on first launch, capture skips onboarding.
    await app.pump(tester, startWithOnboarding: true);
  }

  testWidgets('opens a blank note with the cursor ready', (tester) async {
    await launchIntoCapture(tester);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, isEmpty);
    expect(field.focusNode!.hasFocus, isTrue);
    expect(find.text('Choose where your notes live.'), findsNothing);
    await app.finish(tester);
  });

  testWidgets('Back after capturing goes Home, with the note there', (
    tester,
  ) async {
    await launchIntoCapture(tester);
    await tester.enterText(find.byType(TextField), 'Quick thought');
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Quick thought'), findsOneWidget);
    expect(find.text('Vera N'), findsOneWidget);
    await app.finish(tester);
  });
}
