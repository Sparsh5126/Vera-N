import 'package:flutter_test/flutter_test.dart';

import '../../support/app_harness.dart';
import '../../support/fake_folder_access.dart';

void main() {
  late AppHarness app;
  late FakeFolderAccess folders;

  setUp(() {
    folders = FakeFolderAccess();
    app = AppHarness(folders: folders);
  });

  testWidgets('shows the folder question with both choices', (tester) async {
    await app.pump(tester, startWithOnboarding: true);
    expect(find.text('Choose where your notes live.'), findsOneWidget);
    expect(find.text('Choose folder'), findsOneWidget);
    expect(find.text('Not now'), findsOneWidget);
    await app.finish(tester);
  });

  testWidgets('"Not now" goes to Home and is remembered', (tester) async {
    await app.pump(tester, startWithOnboarding: true);
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(find.text('Write your first thought.'), findsOneWidget);
    expect(await app.storage.settings.onboardingDone(), isTrue);
    expect(await app.storage.settings.notesFolder(), isNull);
    await app.finish(tester);
  });

  testWidgets('choosing a folder goes to Home', (tester) async {
    await app.pump(tester, startWithOnboarding: true);
    await tester.tap(find.text('Choose folder'));
    await tester.pumpAndSettle();
    expect(find.text('Write your first thought.'), findsOneWidget);
    expect(await app.storage.settings.notesFolder(), folders.nextPick);
    await app.finish(tester);
  });

  testWidgets('backing out of the picker stays here', (tester) async {
    folders.nextPick = null;
    await app.pump(tester, startWithOnboarding: true);
    await tester.tap(find.text('Choose folder'));
    await tester.pumpAndSettle();
    expect(find.text('Choose where your notes live.'), findsOneWidget);
    expect(await app.storage.settings.onboardingDone(), isFalse);
    await app.finish(tester);
  });
}
