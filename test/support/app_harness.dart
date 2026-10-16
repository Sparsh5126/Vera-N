import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/app/app.dart';
import 'package:vera_n/core/ai/search/meaning_search_provider.dart';
import 'package:vera_n/core/models/app_prefs.dart';
import 'package:vera_n/core/platform/attachment_capture.dart';
import 'package:vera_n/core/platform/device_lock.dart';
import 'package:vera_n/core/platform/reminder_notifications.dart';
import 'package:vera_n/core/settings/app_prefs_controller.dart';
import 'package:vera_n/core/storage/db/app_database.dart';
import 'package:vera_n/core/storage/files/folder_access.dart';
import 'package:vera_n/core/storage/storage_providers.dart';
import 'package:vera_n/core/storage/storage_services.dart';
import 'package:vera_n/core/sync/sync_providers.dart';
import 'package:vera_n/core/sync/sync_status.dart';

import 'fake_attachment_capture.dart';
import 'fake_device_lock.dart';
import 'fake_embedder.dart';
import 'fake_reminder_notifications.dart';
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

  /// The model Search's meaning search uses in widget tests.
  final embedder = FakeEmbedder();

  /// Camera, gallery and microphone in widget tests.
  final capture = FakeAttachmentCapture();

  /// The phone's lock (Locked folder) in widget tests.
  final lock = FakeDeviceLock();

  /// Reminders' notifications in widget tests.
  final notifications = FakeReminderNotifications();

  Future<void> pump(
    WidgetTester tester, {
    bool startWithOnboarding = false,
    AppPrefs prefs = const AppPrefs(),
    SyncStatus? sync,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Built-in sync is off in tests unless a status is given.
          if (sync != null)
            syncStatusProvider.overrideWith((ref) => Stream.value(sync)),
          storageProvider.overrideWithValue(storage),
          initialPrefsProvider.overrideWithValue(prefs),
          // Meaning search uses the fake model, never the real one.
          embedderFactoryProvider.overrideWithValue(() => embedder),
          attachmentCaptureProvider.overrideWithValue(capture),
          deviceLockProvider.overrideWithValue(lock),
          reminderNotificationsProvider.overrideWithValue(notifications),
        ],
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
