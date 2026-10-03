import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/app/app.dart';
import 'package:vera_n/core/storage/db/app_database.dart';
import 'package:vera_n/core/storage/storage_providers.dart';
import 'package:vera_n/core/storage/storage_services.dart';

import '../../support/fake_folder_access.dart';
import '../../support/memory_note_file_store.dart';

void main() {
  late StorageServices storage;
  late FakeFolderAccess folders;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    folders = FakeFolderAccess();
    storage = StorageServices(
      AppDatabase(NativeDatabase.memory()),
      MemoryNoteFileStore(),
      folders: folders,
    );
  });

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [storageProvider.overrideWithValue(storage)],
        child: const App(startWithOnboarding: true),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    storage.writer.dispose();
    await storage.db.close();
  }

  testWidgets('shows the folder question with both choices', (tester) async {
    await pump(tester);
    expect(find.text('Choose where your notes live.'), findsOneWidget);
    expect(find.text('Choose folder'), findsOneWidget);
    expect(find.text('Not now'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('"Not now" goes to Home and is remembered', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(find.text('Write your first thought.'), findsOneWidget);
    expect(await storage.settings.onboardingDone(), isTrue);
    expect(await storage.settings.notesFolder(), isNull);
    await finish(tester);
  });

  testWidgets('choosing a folder goes to Home', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Choose folder'));
    await tester.pumpAndSettle();
    expect(find.text('Write your first thought.'), findsOneWidget);
    expect(await storage.settings.notesFolder(), folders.nextPick);
    await finish(tester);
  });

  testWidgets('backing out of the picker stays here', (tester) async {
    folders.nextPick = null;
    await pump(tester);
    await tester.tap(find.text('Choose folder'));
    await tester.pumpAndSettle();
    expect(find.text('Choose where your notes live.'), findsOneWidget);
    expect(await storage.settings.onboardingDone(), isFalse);
    await finish(tester);
  });
}
