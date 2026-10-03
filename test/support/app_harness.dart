import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/app/app.dart';
import 'package:vera_n/core/storage/db/app_database.dart';
import 'package:vera_n/core/storage/files/folder_access.dart';
import 'package:vera_n/core/storage/storage_providers.dart';
import 'package:vera_n/core/storage/storage_services.dart';

import 'memory_note_file_store.dart';

/// The whole app on an in-memory database and fake files, for widget tests.
class AppHarness {
  AppHarness({FolderAccess? folders}) {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    storage = StorageServices(
      AppDatabase(NativeDatabase.memory()),
      MemoryNoteFileStore(),
      folders: folders,
    );
  }

  late final StorageServices storage;

  Future<void> pump(
    WidgetTester tester, {
    bool startWithOnboarding = false,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [storageProvider.overrideWithValue(storage)],
        child: App(startWithOnboarding: startWithOnboarding),
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
}
