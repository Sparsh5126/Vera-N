import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/storage/db/app_database.dart';
import 'package:vera_n/core/storage/repositories/settings_repository.dart';

void main() {
  test('a version 1 database gains settings and keeps its notes', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final dir = await Directory.systemTemp.createTemp('vera_n_migrate_');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/vera_n.sqlite');

    // Make a version 1 database: today's schema minus the settings table.
    final v1 = AppDatabase(NativeDatabase(file));
    await v1.customStatement(
      "INSERT INTO notes (path, path_key, folder, title, body, content_hash, "
      "created, modified) VALUES ('a.md', 'a.md', '', 'Old', 'Old', 'h', 0, 0)",
    );
    await v1.customStatement('DROP TABLE settings');
    await v1.customStatement('PRAGMA user_version = 1');
    await v1.close();

    final v2 = AppDatabase(NativeDatabase(file));
    final settings = SettingsRepository(v2);
    await settings.setOnboardingDone();
    expect(await settings.onboardingDone(), isTrue);
    expect((await v2.select(v2.notes).get()).single.title, 'Old');
    await v2.close();
  });
}
