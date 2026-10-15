import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/copy/app_copy.dart';
import 'package:vera_n/core/models/booster_prefs.dart';
import 'package:vera_n/core/models/booster_result.dart';

import '../../support/app_harness.dart';

void main() {
  late AppHarness app;
  setUp(() => app = AppHarness());

  final page = find.byWidgetPredicate(
    (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
  );

  Future<void> openAt(WidgetTester tester, Finder row) async {
    await app.pump(tester);
    await tester.tap(find.bySemanticsLabel(AppCopy.navSettings).last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(row, 200, scrollable: page.first);
    await tester.pumpAndSettle();
  }

  group('phone', () {
    testWidgets('the status line says when it looks and when it last did', (
      tester,
    ) async {
      await openAt(tester, find.text(AppCopy.looksWhileCharging));
      expect(find.text(AppCopy.notLookedYet), findsOneWidget);
      await app.finish(tester);
    });

    testWidgets('after a run: "Last looked: Today"', (tester) async {
      await app.storage.settings.setLastAnalysis(DateTime.now());
      await openAt(tester, find.text(AppCopy.looksWhileCharging));
      expect(find.text(AppCopy.lastLooked(AppCopy.today)), findsOneWidget);
      await app.finish(tester);
    });

    testWidgets('no laptop: "Not set up", and a tap explains it', (
      tester,
    ) async {
      await openAt(tester, find.text(LaptopCopy.laptop));
      expect(find.text(LaptopCopy.notSetUp), findsOneWidget);
      expect(find.text(LaptopCopy.section), findsNothing);
      await tester.tap(find.text(LaptopCopy.laptop));
      await tester.pumpAndSettle();
      expect(find.text(LaptopCopy.explain), findsOneWidget);
      await tester.tap(find.text(LaptopCopy.gotIt));
      await tester.pumpAndSettle();
      await app.finish(tester);
    });

    testWidgets('a laptop helped today: the row says so', (tester) async {
      final note = await app.storage.notes.create('Trek\nSpring.');
      final id = (await app.storage.notes.ensureId(note))!;
      await app.storage.booster.add('laptop1', [
        BoosterResult(
          kind: BoosterKind.tags,
          notes: [NoteStamp(id, 'h')],
          values: const [],
          model: 'm',
          madeAt: DateTime.now(),
          deviceId: 'laptop1',
        ),
      ]);
      await openAt(tester, find.text(LaptopCopy.laptop));
      expect(find.text(LaptopCopy.lastHelpedOn(AppCopy.today)), findsOneWidget);
      await app.finish(tester);
    });
  });

  group('laptop', () {
    testWidgets('AI ON THIS COMPUTER: on by default and optional; jobs can '
        'be switched off; off hides the rest', (tester) async {
      // Flutter wants this reset inside the test itself.
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      // A closed port, so no real AI app on this machine is asked.
      await app.storage.settings.saveBoosterPrefs(
        const BoosterPrefs(address: 'http://127.0.0.1:9/v1'),
      );
      await openAt(tester, find.text(LaptopCopy.jobCopies));
      expect(find.text(LaptopCopy.laptop), findsNothing);

      await tester.tap(find.text(LaptopCopy.jobCopies));
      await tester.pumpAndSettle();
      var prefs = await app.storage.settings.boosterPrefs();
      expect(prefs.jobs.contains(BoosterKind.duplicate), isFalse);

      final helpSwitch = find.widgetWithText(
        SwitchListTile,
        LaptopCopy.helpSwitch,
      );
      await tester.ensureVisible(helpSwitch);
      await tester.pumpAndSettle();
      await tester.tap(helpSwitch);
      await tester.pumpAndSettle();
      prefs = await app.storage.settings.boosterPrefs();
      expect(prefs.on, isFalse);
      expect(find.text(LaptopCopy.address), findsNothing);
      await app.finish(tester);
      debugDefaultTargetPlatformOverride = null;
    });
  });
}
