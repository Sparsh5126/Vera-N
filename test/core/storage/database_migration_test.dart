import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/storage/db/app_database.dart';
import 'package:vera_n/core/storage/repositories/settings_repository.dart';

/// Turns today's schema back into an older version, keeping one note.
Future<void> makeOldDatabase(File file, int version) async {
  final db = AppDatabase(NativeDatabase(file));
  await db.customStatement(
    'INSERT INTO notes (path, path_key, name_key, folder, title, body, '
    "content_hash, created, modified) VALUES ('Ideas/Old.md', "
    "'ideas/old.md', 'old', 'Ideas', 'Old', 'Old, see [[Other]]', 'h', 0, 0)",
  );
  await db.customStatement('DROP TABLE rejections');
  if (version < 4) {
    for (final table in ['suggestions', 'chunks', 'note_analysis']) {
      await db.customStatement('DROP TABLE $table');
    }
  }
  if (version < 3) {
    await db.customStatement('DROP TABLE links');
    await db.customStatement('DROP INDEX notes_name_key');
    await db.customStatement('ALTER TABLE notes DROP COLUMN name_key');
  }
  if (version < 2) await db.customStatement('DROP TABLE settings');
  await db.customStatement('PRAGMA user_version = $version');
  await db.close();
}

void main() {
  late File file;

  setUp(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final dir = await Directory.systemTemp.createTemp('vera_n_migrate_');
    addTearDown(() => dir.delete(recursive: true));
    file = File('${dir.path}/vera_n.sqlite');
  });

  for (final version in [1, 2, 3, 4]) {
    test('a version $version database upgrades and keeps its notes', () async {
      await makeOldDatabase(file, version);

      final db = AppDatabase(NativeDatabase(file));
      final settings = SettingsRepository(db);
      await settings.setOnboardingDone();
      expect(await settings.onboardingDone(), isTrue);

      final note = (await db.select(db.notes).get()).single;
      expect(note.title, 'Old');
      expect(note.nameKey, 'old');
      if (version < 3) {
        final links = await db.select(db.links).get();
        expect(links.single.targetKey, 'other');
        expect(links.single.source, note.id);
      }
      expect(await db.select(db.suggestions).get(), isEmpty);
      expect(await db.select(db.chunks).get(), isEmpty);
      expect(await db.select(db.rejections).get(), isEmpty);
      await db.close();
    });
  }
}
