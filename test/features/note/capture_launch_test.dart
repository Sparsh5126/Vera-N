import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/app/app.dart';
import 'package:vera_n/core/storage/db/app_database.dart';
import 'package:vera_n/core/storage/storage_providers.dart';
import 'package:vera_n/core/storage/storage_services.dart';

import '../../support/memory_note_file_store.dart';

/// A capture entry point (app shortcut; later widget and tile) starts the
/// app on the new-note route.
void main() {
  late StorageServices storage;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    storage = StorageServices(
      AppDatabase(NativeDatabase.memory()),
      MemoryNoteFileStore(),
    );
  });

  Future<void> launchIntoCapture(WidgetTester tester) async {
    tester.binding.platformDispatcher.defaultRouteNameTestValue = '/note/new';
    addTearDown(
      tester.binding.platformDispatcher.clearDefaultRouteNameTestValue,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [storageProvider.overrideWithValue(storage)],
        // Even on first launch, capture skips onboarding.
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

  testWidgets('opens a blank note with the cursor ready', (tester) async {
    await launchIntoCapture(tester);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, isEmpty);
    expect(field.focusNode!.hasFocus, isTrue);
    expect(find.text('Choose where your notes live.'), findsNothing);
    await finish(tester);
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
    await finish(tester);
  });
}
