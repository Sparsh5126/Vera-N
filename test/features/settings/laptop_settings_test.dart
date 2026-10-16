import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/copy/app_copy.dart';
import 'package:vera_n/core/models/booster_prefs.dart';
import 'package:vera_n/core/models/booster_result.dart';
import 'package:vera_n/core/sync/sync_status.dart';

import '../../support/app_harness.dart';

void main() {
  late AppHarness app;
  setUp(() => app = AppHarness());

  final page = find.byWidgetPredicate(
    (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
  );

  Future<void> openAt(
    WidgetTester tester,
    Finder row, {
    SyncStatus? sync,
  }) async {
    await app.pump(tester, sync: sync);
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

    const paired = SyncStatus(SyncState.connected, peerName: 'Laptop');
    final helped = SyncCopy.laptopHelped(AppCopy.today);

    Future<void> laptopHelpedToday() async {
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
    }

    testWidgets('no laptop AI section, and no separate Laptop row', (
      tester,
    ) async {
      await openAt(tester, find.text(SyncCopy.withLaptop), sync: paired);
      expect(find.text(LaptopCopy.section), findsNothing);
      expect(find.text('Laptop'), findsNothing);
      expect(find.textContaining(helped), findsNothing, reason: 'not yet');
      await app.finish(tester);
    });

    testWidgets('paired and the laptop helped today: the sync row says so', (
      tester,
    ) async {
      await laptopHelpedToday();
      await openAt(tester, find.text(SyncCopy.withLaptop), sync: paired);
      expect(find.text(SyncCopy.inSync('Laptop')), findsOneWidget);
      expect(find.text('$helped\n${SyncCopy.onlyWifi}'), findsOneWidget);
      await app.finish(tester);
    });

    testWidgets('not paired: only "Not paired", even after earlier help', (
      tester,
    ) async {
      await laptopHelpedToday();
      await openAt(
        tester,
        find.text(SyncCopy.withLaptop),
        sync: const SyncStatus(SyncState.notPaired),
      );
      expect(find.text(SyncCopy.notPaired), findsOneWidget);
      expect(find.textContaining(helped), findsNothing);
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
