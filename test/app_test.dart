import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/app/app.dart';
import 'package:vera_n/core/storage/db/app_database.dart';
import 'package:vera_n/core/storage/storage_providers.dart';
import 'package:vera_n/core/storage/storage_services.dart';
import 'package:vera_n/core/styles/app_styles.dart';

import 'support/memory_note_file_store.dart';

void main() {
  late StorageServices storage;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    storage = StorageServices(
      AppDatabase(NativeDatabase.memory()),
      MemoryNoteFileStore(),
    );
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [storageProvider.overrideWithValue(storage)],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Unmounts the app and closes the database inside the test, so no
  /// stream or timer outlives it.
  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    storage.writer.dispose();
    await storage.db.close();
  }

  for (final brightness in Brightness.values) {
    testWidgets('builds with style tokens in $brightness', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = brightness;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await pumpApp(tester);

      final context = tester.element(find.byType(Scaffold).first);
      final expected = brightness == Brightness.dark
          ? AppPalette.dark
          : AppPalette.light;
      expect(context.colors.background, expected.background);
      expect(Theme.of(context).scaffoldBackgroundColor, expected.background);
      await finish(tester);
    });
  }

  testWidgets('first launch shows the empty Home', (tester) async {
    await pumpApp(tester);
    expect(find.text('Vera N'), findsOneWidget);
    expect(find.text('Write your first thought.'), findsOneWidget);
    expect(find.text('New note'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('write a note, go back, see it on Home', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('New note'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Future Self\nआज की बात');
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Write your first thought.'), findsNothing);
    expect(find.text('Future Self'), findsOneWidget);
    expect(find.text('आज की बात'), findsOneWidget);
    await finish(tester);
  });
}
