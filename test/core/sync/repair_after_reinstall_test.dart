import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:vera_n/core/storage/db/app_database.dart';
import 'package:vera_n/core/storage/files/io_note_file_store.dart';
import 'package:vera_n/core/storage/storage_services.dart';

import '../../support/engine_pair.dart';

/// The duplicates the user found on 2026-10-22, with two real engines: a
/// freshly installed phone has never seen the laptop's copy of a note it
/// moved into a folder, so pairing joins both folders and the note is in
/// two places. The phone's scan settles it, and its removal reaches the
/// laptop. (The phone's folder is shared directly here; in the app a
/// mirror copies it both ways, unchanged.)
void main() {
  const id = '20261016-205538-71f0';
  const text = '---\nid: $id\n---\nGame Ideas\nA zombie game.\n';

  test(
    're-pairing a fresh phone leaves one copy of a moved note, on both',
    () async {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      final e = await EnginePair.create();
      final db = AppDatabase(NativeDatabase.memory());
      final phone = StorageServices(
        db,
        IoNoteFileStore(Directory(p.join(e.phoneFolder.path, 'Notes'))),
        settleSameIds: true,
      );
      try {
        e.laptopFile('Notes/$id.md')
          ..createSync(recursive: true)
          ..writeAsStringSync(text);
        e.phoneFile('Notes/Ideas/$id.md')
          ..createSync(recursive: true)
          ..writeAsStringSync(text);
        await phone.reconcile();

        await e.pair();
        // The bug, at the sync level: both paths on both devices.
        await EnginePair.until(
          () =>
              e.phoneFile('Notes/$id.md').existsSync() &&
              e.laptopFile('Notes/Ideas/$id.md').existsSync(),
        );

        await phone.reconcile();
        expect(await db.select(db.notes).get(), hasLength(1));
        expect(e.phoneFile('Notes/$id.md').existsSync(), isFalse);
        await EnginePair.until(
          () => !e.laptopFile('Notes/$id.md').existsSync(),
        );
        expect(e.laptopFile('Notes/Ideas/$id.md').readAsStringSync(), text);
      } finally {
        phone.writer.dispose();
        await db.close();
        await e.dispose();
      }
    },
    skip: EnginePair.available ? false : 'sync engine not fetched',
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
