import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/copy/app_copy.dart';
import 'package:vera_n/features/onboarding/widgets/onboarding_art.dart';
import 'package:vera_n/features/onboarding/widgets/onboarding_art_kind.dart';

import '../../support/app_harness.dart';
import '../../support/fake_folder_access.dart';

void main() {
  late AppHarness app;
  late FakeFolderAccess folders;

  setUp(() {
    folders = FakeFolderAccess();
    app = AppHarness(folders: folders);
  });

  Future<void> start(WidgetTester tester) =>
      app.pump(tester, startWithOnboarding: true);

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  testWidgets('four intro screens, then the folder question; every page '
      'says it is private', (tester) async {
    await start(tester);
    for (final title in [
      OnboardingCopy.onboardingPrivateTitle,
      OnboardingCopy.onboardingWhatTitle,
      OnboardingCopy.onboardingHowTitle,
      OnboardingCopy.onboardingRemindTitle,
    ]) {
      expect(find.text(title), findsOneWidget);
      expect(find.text(OnboardingCopy.privacyLine), findsWidgets);
      await tapText(tester, AppCopy.next);
    }
    expect(find.text(OnboardingCopy.onboardingFolderTitle), findsOneWidget);
    expect(find.text(OnboardingCopy.privacyLine), findsWidgets);
    expect(await app.storage.settings.onboardingDone(), isFalse);
    await app.finish(tester);
  });

  /// The illustration on screen now (a neighbouring page may be built too).
  OnboardingArtKind? artOnScreen(WidgetTester tester) {
    final screen =
        Offset.zero & tester.view.physicalSize / tester.view.devicePixelRatio;
    for (final art in tester.widgetList<OnboardingArt>(
      find.byType(OnboardingArt),
    )) {
      if (screen.overlaps(tester.getRect(find.byWidget(art)))) return art.kind;
    }
    return null;
  }

  testWidgets('every page has its own illustration', (tester) async {
    await start(tester);
    final seen = <OnboardingArtKind?>[];
    for (var i = 0; i < 4; i++) {
      seen.add(artOnScreen(tester));
      await tapText(tester, AppCopy.next);
    }
    seen.add(artOnScreen(tester));
    await tapText(tester, AppCopy.notNow);
    seen.add(artOnScreen(tester));
    expect(seen, [
      OnboardingArtKind.privateNote,
      OnboardingArtKind.connections,
      OnboardingArtKind.onPhone,
      OnboardingArtKind.reminder,
      OnboardingArtKind.folder,
      OnboardingArtKind.name,
    ]);
    await app.finish(tester);
  });

  testWidgets('the name page drops its illustration while typing', (
    tester,
  ) async {
    await start(tester);
    await tapText(tester, AppCopy.skip);
    await tapText(tester, AppCopy.notNow);
    expect(artOnScreen(tester), OnboardingArtKind.name);
    tester.view.viewInsets = const FakeViewPadding(bottom: 900);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingArt), findsNothing);
    expect(find.byType(TextField), findsOneWidget);
    await app.finish(tester);
  });

  testWidgets('Skip, Not now, Skip: Home, done, no name or folder', (
    tester,
  ) async {
    await start(tester);
    await tapText(tester, AppCopy.skip);
    await tapText(tester, AppCopy.notNow);
    expect(find.text(OnboardingCopy.onboardingNameTitle), findsOneWidget);
    await tapText(tester, AppCopy.skip);
    expect(find.text(AppCopy.emptyHome), findsOneWidget);
    expect(await app.storage.settings.onboardingDone(), isTrue);
    expect(await app.storage.settings.notesFolder(), isNull);
    expect((await app.storage.settings.prefs()).name, isNull);
    await app.finish(tester);
  });

  testWidgets('choosing a folder, then a name, greets by name', (tester) async {
    await start(tester);
    await tapText(tester, AppCopy.skip);
    await tapText(tester, AppCopy.chooseFolder);
    expect(await app.storage.settings.notesFolder(), folders.nextPick);
    expect(find.text(OnboardingCopy.onboardingNameTitle), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Asha');
    await tester.pump();
    await tapText(tester, AppCopy.done);
    expect(find.textContaining(', Asha'), findsOneWidget);
    expect((await app.storage.settings.prefs()).name, 'Asha');
    await app.finish(tester);
  });

  testWidgets('backing out of the picker stays on the folder question', (
    tester,
  ) async {
    folders.nextPick = null;
    await start(tester);
    await tapText(tester, AppCopy.skip);
    await tapText(tester, AppCopy.chooseFolder);
    expect(find.text(OnboardingCopy.onboardingFolderTitle), findsOneWidget);
    await app.finish(tester);
  });

  testWidgets('swiping moves between pages, folder and name included', (
    tester,
  ) async {
    await start(tester);
    for (var i = 0; i < 5; i++) {
      await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
      await tester.pumpAndSettle();
    }
    expect(find.text(OnboardingCopy.onboardingNameTitle), findsOneWidget);
    expect(await app.storage.settings.onboardingDone(), isFalse);
    await app.finish(tester);
  });

  testWidgets('without folder picking (desktop), intro goes to the name', (
    tester,
  ) async {
    await app.storage.db.close();
    app = AppHarness();
    await start(tester);
    await tapText(tester, AppCopy.skip);
    expect(find.text(OnboardingCopy.onboardingNameTitle), findsOneWidget);
    await app.finish(tester);
  });
}
