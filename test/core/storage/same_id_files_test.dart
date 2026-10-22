import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/storage/db/app_database.dart';
import 'package:vera_n/core/storage/files/sync_conflict.dart';
import 'package:vera_n/core/storage/indexer/same_id_files.dart';
import 'package:vera_n/core/storage/storage_services.dart';

import '../../support/memory_note_file_store.dart';
import '../../support/storage_harness.dart';

const id = '20261016-205538-71f0';

String note(String body, {String tags = ''}) =>
    '---\nid: $id\ncreated: 2026-10-16T20:55:38+05:30\n$tags---\n$body\n';

const game = 'Game Ideas\nA zombie game that changes as time ticks.';

void main() {
  late StorageHarness h;

  setUp(() => h = StorageHarness());
  tearDown(() => h.dispose());

  /// The note sits in Ideas/ (moved there on this phone); then sync brings
  /// back its old file at the top level.
  Future<void> movedThenOldCopyBack(String oldText) async {
    await h.store.write('Ideas/$id.md', note(game));
    await h.indexer.reconcile();
    await h.store.write('$id.md', oldText);
    await h.indexer.reconcile();
    expect(await h.db.select(h.db.notes).get(), hasLength(2));
  }

  Future<List<NoteRow>> notes() => h.db.select(h.db.notes).get();

  Future<List<String>> files() async =>
      [for (final e in await h.store.listNotes()) e.path]..sort();

  test(
    'an old copy of a moved note goes: one note, where it was put',
    () async {
      await movedThenOldCopyBack(note(game));
      expect(await SameIdFiles(h.db, h.store).settle(), 1);
      expect(await files(), ['Ideas/$id.md']);
      final rows = await notes();
      expect(rows.single.path, 'Ideas/$id.md');
      expect(rows.single.conflict, isFalse);
    },
  );

  test('an old copy with lines the note lacks is kept as a conflict copy '
      'beside it, for Compare', () async {
    await movedThenOldCopyBack(note('$game\nOnly in the old copy'));
    await SameIdFiles(h.db, h.store, clock: () => h.now).settle();
    final copy = SyncConflict.copyPath(
      'Ideas/$id.md',
      h.now,
      SameIdFiles.device,
    );
    expect(await files(), [copy, 'Ideas/$id.md']..sort());
    expect(await h.store.read(copy), contains('Only in the old copy'));
    expect((await notes()).single.conflict, isTrue);

    await h.indexer.reconcile();
    expect(await notes(), hasLength(1));
  });

  test('a tag only the old copy has keeps it as a conflict copy', () async {
    await movedThenOldCopyBack(note(game, tags: 'tags: [games]\n'));
    await SameIdFiles(h.db, h.store).settle();
    expect(await files(), hasLength(2));
    expect((await notes()).single.path, 'Ideas/$id.md');
  });

  test(
    'a locked note stays locked: the conflict copy goes in Locked/',
    () async {
      await h.store.write('Locked/$id.md', note(game));
      await h.indexer.reconcile();
      await h.store.write('$id.md', note('$game\nOlder words'));
      await h.indexer.reconcile();
      await SameIdFiles(h.db, h.store).settle();
      expect(await files(), everyElement(startsWith('Locked/')));
    },
  );

  test('the copy being edited is the one kept', () async {
    await movedThenOldCopyBack(note(game));
    final old = (await notes()).firstWhere((r) => r.path == '$id.md');
    await h.repo.updateBody(old.id, '$game\nTyped just now');
    await SameIdFiles(h.db, h.store).settle();
    final rows = await notes();
    expect(rows.single.id, old.id);
    expect(rows.single.body, contains('Typed just now'));
  });

  test('different ids, and notes without one, are left alone', () async {
    await h.store.write('a.md', 'Same words\nin both');
    await h.store.write('b.md', 'Same words\nin both');
    await h.store.write('Ideas/$id.md', note(game));
    await h.indexer.reconcile();
    expect(await SameIdFiles(h.db, h.store).settle(), 0);
    expect(await files(), hasLength(3));
  });

  test('on the phone, every scan settles it; the laptop leaves it', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    Future<int> notesAfterScan({required bool phone}) async {
      final store = MemoryNoteFileStore();
      final db = AppDatabase(NativeDatabase.memory());
      final services = StorageServices(db, store, settleSameIds: phone);
      await store.write('Ideas/$id.md', note(game));
      await services.reconcile();
      await store.write('$id.md', note(game));
      await services.reconcile();
      final count = (await db.select(db.notes).get()).length;
      services.writer.dispose();
      await db.close();
      return count;
    }

    expect(await notesAfterScan(phone: true), 1);
    expect(await notesAfterScan(phone: false), 2);
  });
}
