import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/storage/repositories/notes_exporter.dart';
import 'package:vera_n/core/storage/repositories/trash_repository.dart';

import '../../support/storage_harness.dart';

void main() {
  late StorageHarness h;
  late TrashRepository trash;

  setUp(() {
    h = StorageHarness();
    trash = TrashRepository(h.db, h.store);
  });
  tearDown(() => h.dispose());

  Future<int> trashed(String body, DateTime when) async {
    final ref = await h.repo.create(body);
    h.now = when;
    await h.repo.trash(ref);
    return ref;
  }

  group('TrashRepository', () {
    test('lists trashed notes, most recently deleted first', () async {
      await h.repo.create('Kept\nStill here.');
      final older = await trashed('Old\nGone first.', DateTime(2026, 10, 1));
      final newer = await trashed('New\nGone later.', DateTime(2026, 10, 5));
      final list = await trash.watch().first;
      expect([for (final n in list) n.ref], [newer, older]);
      expect(list.first.title, 'New');
      expect(list.first.trashedAt, DateTime(2026, 10, 5));
    });

    test('delete forever removes the file and the note', () async {
      final ref = await trashed('Bye\nText.', DateTime(2026, 10, 5));
      final path = (await h.row(ref)).path;
      expect(await h.store.exists(path), isTrue);
      await trash.deleteForever(ref);
      expect(await h.store.exists(path), isFalse);
      expect(await trash.watch().first, isEmpty);
    });

    test('delete forever never touches a note outside the trash', () async {
      final ref = await h.repo.create('Safe\nText.');
      await h.writer.flush();
      final path = (await h.row(ref)).path;
      await trash.deleteForever(ref);
      expect(await h.store.exists(path), isTrue);
      expect((await h.row(ref)).body, contains('Text.'));
    });

    test('purge removes only notes kept past 30 days', () async {
      final old = await trashed('Old\nText.', DateTime(2026, 9, 1));
      final recent = await trashed('Recent\nText.', DateTime(2026, 9, 20));
      final removed = await trash.purge(DateTime(2026, 10, 8));
      expect(removed, 1);
      final left = await trash.watch().first;
      expect([for (final n in left) n.ref], [recent]);
      expect(left.any((n) => n.ref == old), isFalse);
    });
  });

  test('export: every note in its folder, without the trash', () async {
    final a = await h.repo.create('Alpha\nFirst.');
    await h.repo.create('Beta\nSecond.', folder: 'Ideas');
    await trashed('Gone\nDeleted.', DateTime(2026, 10, 5));
    final bytes = await NotesExporter(h.db, h.writer).zip();
    final files = {
      for (final f in ZipDecoder().decodeBytes(bytes))
        f.name: utf8.decode(f.content),
    };
    expect(files, hasLength(2));
    expect(files.keys.where((k) => k.startsWith('Ideas/')), hasLength(1));
    expect(files[(await h.row(a)).path], contains('First.'));
    expect(files.values.any((t) => t.contains('Deleted.')), isFalse);
  });

  test('export file name has the date', () {
    expect(
      NotesExporter.fileName('Vera N', DateTime(2026, 10, 8)),
      'Vera N notes 2026-10-08.zip',
    );
  });
}
