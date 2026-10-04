import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/styles/app_styles.dart';

import '../support/app_harness.dart';

void main() {
  late AppHarness app;

  setUp(() => app = AppHarness());

  /// How far the amber pill still is from the Search tab, in pixels.
  double pillGap(WidgetTester tester) {
    final pill = tester.getRect(
      find.descendant(
        of: find.byType(AnimatedSlide),
        matching: find.byType(DecoratedBox),
      ),
    );
    final search = tester.getRect(find.bySemanticsLabel('Search'));
    return (pill.left - search.left).abs();
  }

  Future<void> tapSearch(WidgetTester tester) async {
    await tester.tap(find.bySemanticsLabel('Search'));
    await tester.pump();
    await tester.pump(AppMotion.standard ~/ 2);
  }

  testWidgets('switching tabs animates (pill slides, page fades)', (
    tester,
  ) async {
    await app.pump(tester);
    await tapSearch(tester);
    // Halfway through, the pill is still on its way.
    expect(pillGap(tester), greaterThan(1));
    await tester.pumpAndSettle();
    expect(pillGap(tester), lessThan(1));
    expect(find.text('Search notes…'), findsOneWidget);
    await app.finish(tester);
  });

  testWidgets('with reduce motion on, tabs switch instantly', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await app.pump(tester);
    await tapSearch(tester);
    // Already there, with no in-between frames.
    expect(pillGap(tester), lessThan(1));
    expect(find.text('Search notes…'), findsOneWidget);
    await app.finish(tester);
  });
}
