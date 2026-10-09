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

  test(
    'a version 5 database keeps its pending suggestions, tag empty',
    () async {
      final old = AppDatabase(NativeDatabase(file));
      for (final name in ['A', 'B']) {
        await old.customStatement(
          'INSERT INTO notes (path, path_key, name_key, folder, title, body, '
          "content_hash, created, modified) VALUES ('$name.md', "
          "'${name.toLowerCase()}.md', '${name.toLowerCase()}', '', '$name', "
          "'$name', 'h', 0, 0)",
        );
      }
      // The suggestions table as schema 5 made it.
      await old.customStatement('DROP TABLE suggestions');
      await old.customStatement(
        'CREATE TABLE suggestions (id INTEGER NOT NULL PRIMARY KEY '
        'AUTOINCREMENT, kind TEXT NOT NULL, note_a INTEGER NOT NULL '
        'REFERENCES notes (id) ON DELETE CASCADE, note_b INTEGER NOT NULL '
        'REFERENCES notes (id) ON DELETE CASCADE, score REAL NOT NULL, '
        'chunk_a INTEGER NOT NULL, chunk_b INTEGER NOT NULL, status TEXT NOT '
        'NULL, created_at INTEGER NOT NULL, expires_at INTEGER NOT NULL, '
        'UNIQUE (kind, note_a, note_b))',
      );
      await old.customStatement(
        'INSERT INTO suggestions (kind, note_a, note_b, score, chunk_a, '
        "chunk_b, status, created_at, expires_at) VALUES ('link', 1, 2, 0.7, "
        "0, 0, 'fresh', 0, 4102444800)",
      );
      await old.customStatement('PRAGMA user_version = 5');
      await old.close();

      final db = AppDatabase(NativeDatabase(file));
      final kept = (await db.select(db.suggestions).get()).single;
      expect(kept.kind, 'link');
      expect(kept.tag, '');
      await db.close();
    },
  );

  test('a version 6 database keeps its suggestions and gains the laptop '
      'columns', () async {
    final old = AppDatabase(NativeDatabase(file));
    for (final name in ['A', 'B']) {
      await old.customStatement(
        'INSERT INTO notes (path, path_key, name_key, folder, title, body, '
        "content_hash, created, modified) VALUES ('$name.md', "
        "'${name.toLowerCase()}.md', '${name.toLowerCase()}', '', '$name', "
        "'$name', 'h', 0, 0)",
      );
    }
    // The suggestions table as schema 6 made it, without the laptop's.
    await old.customStatement('DROP TABLE suggestions');
    await old.customStatement('DROP TABLE imported_results');
    await old.customStatement(
      'CREATE TABLE suggestions (id INTEGER NOT NULL PRIMARY KEY '
      'AUTOINCREMENT, kind TEXT NOT NULL, note_a INTEGER NOT NULL '
      'REFERENCES notes (id) ON DELETE CASCADE, note_b INTEGER NOT NULL '
      "REFERENCES notes (id) ON DELETE CASCADE, tag TEXT NOT NULL DEFAULT '', "
      'score REAL NOT NULL, chunk_a INTEGER NOT NULL, chunk_b INTEGER NOT '
      'NULL, status TEXT NOT NULL, created_at INTEGER NOT NULL, expires_at '
      'INTEGER NOT NULL, UNIQUE (kind, note_a, note_b, tag))',
    );
    await old.customStatement(
      'INSERT INTO suggestions (kind, note_a, note_b, score, chunk_a, '
      "chunk_b, status, created_at, expires_at) VALUES ('link', 1, 2, 0.7, "
      "0, 0, 'fresh', 0, 4102444800)",
    );
    await old.customStatement('PRAGMA user_version = 6');
    await old.close();

    final db = AppDatabase(NativeDatabase(file));
    final kept = (await db.select(db.suggestions).get()).single;
    expect(kept.detail, '');
    expect(kept.fromLaptop, isFalse);
    expect(await db.select(db.importedResults).get(), isEmpty);
    await db.close();
  });
}
