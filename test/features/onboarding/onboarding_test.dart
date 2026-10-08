import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/copy/app_copy.dart';

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

  testWidgets('three intro screens, then the folder question', (tester) async {
    await start(tester);
    expect(find.text(AppCopy.onboardingPrivateTitle), findsOneWidget);
    await tapText(tester, AppCopy.next);
    expect(find.text(AppCopy.onboardingWhatTitle), findsOneWidget);
    await tapText(tester, AppCopy.next);
    expect(find.text(AppCopy.onboardingHowTitle), findsOneWidget);
    await tapText(tester, AppCopy.next);
    expect(find.text(AppCopy.onboardingFolderTitle), findsOneWidget);
    expect(await app.storage.settings.onboardingDone(), isFalse);
    await app.finish(tester);
  });

  testWidgets('Skip, Not now, Skip: Home, done, no name or folder', (
    tester,
  ) async {
    await start(tester);
    await tapText(tester, AppCopy.skip);
    await tapText(tester, AppCopy.notNow);
    expect(find.text(AppCopy.onboardingNameTitle), findsOneWidget);
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
    expect(find.text(AppCopy.onboardingNameTitle), findsOneWidget);
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
    expect(find.text(AppCopy.onboardingFolderTitle), findsOneWidget);
    await app.finish(tester);
  });

  testWidgets('swiping moves between pages, folder and name included', (
    tester,
  ) async {
    await start(tester);
    for (var i = 0; i < 4; i++) {
      await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
      await tester.pumpAndSettle();
    }
    expect(find.text(AppCopy.onboardingNameTitle), findsOneWidget);
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
    expect(find.text(AppCopy.onboardingNameTitle), findsOneWidget);
    await app.finish(tester);
  });
}
