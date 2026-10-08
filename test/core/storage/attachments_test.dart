import 'dart:io';

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/models/attachment_kind.dart';
import 'package:vera_n/core/storage/files/attachment_name.dart';
import 'package:vera_n/core/storage/files/io_note_file_store.dart';
import 'package:vera_n/core/storage/files/note_markup.dart';
import 'package:vera_n/core/storage/files/note_text.dart';
import 'package:vera_n/core/storage/indexer/notes_relocator.dart';
import 'package:vera_n/core/storage/repositories/attachments_repository.dart';
import 'package:vera_n/features/note/state/attachment_insert.dart';
import 'package:vera_n/features/note/state/markup_editing.dart';

import '../../support/memory_note_file_store.dart';
import '../../support/storage_harness.dart';

void main() {
  const photo = '20261008-183000-a7f3.jpg';
  final embed = NoteMarkup.embed(photo);

  group('markup', () {
    test('an embed on its own line is found; elsewhere it is not', () {
      final spans = NoteMarkup.find('Trip\n$embed\nAfter');
      final e = spans.single;
      expect((e.kind, e.target, e.start), (MarkupKind.embed, photo, 5));
      expect(NoteMarkup.find('Trip $embed'), isEmpty);
      expect(NoteMarkup.embeds('A\n$embed\nB\n${NoteMarkup.embed('x.m4a')}'), [
        photo,
        'x.m4a',
      ]);
    });

    test('readers, titles and the AI never see attachment names', () {
      final body = '$embed\nTrip to Triund\n$embed\nThe view.';
      expect(NoteText.title(body), 'Trip to Triund');
      expect(NoteText.preview(body), 'The view.');
      expect(NoteMarkup.display('A\n$embed\nB'), 'A\nB');
    });

    test('kinds come from the name', () {
      expect(AttachmentName.kindOf(photo), AttachmentKind.photo);
      expect(AttachmentName.kindOf('a.drawing.svg'), AttachmentKind.drawing);
      expect(AttachmentName.kindOf('a.M4A'), AttachmentKind.voice);
      expect(AttachmentName.kindOf('a.pdf'), isNull);
    });
  });

  group('editing', () {
    TextEditingValue at(String text, int caret) => TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: caret),
    );

    test('inserting puts it on its own line, cursor on the next', () {
      final mid = AttachmentInsert.insert(at('Title\nab', 7), photo);
      expect(mid.text, 'Title\na\n$embed\nb');
      expect(mid.selection.baseOffset, 'Title\na\n$embed\n'.length);
      // At the end, a line to write on with one after it, so the cursor
      // isn't on the last line (drawn too low under a picture).
      final end = AttachmentInsert.insert(at('Title', 5), photo);
      expect(end.text, 'Title\n$embed\n\n');
      expect(end.selection.baseOffset, end.text.length - 1);
      final beforeBreak = AttachmentInsert.insert(at('A\nB', 1), photo);
      expect(beforeBreak.text, 'A\n$embed\nB');
    });

    test('backspace on the line after removes the whole attachment', () {
      final text = 'A\n$embed\nB';
      final caret = text.indexOf('B');
      final next = text.replaceRange(caret - 1, caret, '');
      final fixed = MarkupEditing.protect(at(text, caret), at(next, caret - 1));
      expect(fixed.text, 'A\nB');
      expect(fixed.selection.baseOffset, 2);
    });

    test('deleting into it removes it whole, never half', () {
      final text = 'A\n$embed\nB';
      final end = 2 + embed.length;
      final next = text.replaceRange(end - 1, end, '');
      final fixed = MarkupEditing.protect(at(text, end), at(next, end - 1));
      expect(fixed.text, 'A\nB');
    });

    test('the cursor never rests on its line', () {
      final text = 'A\n$embed\nB';
      final onIt = 2 + embed.length;
      final forward = MarkupEditing.protect(at(text, 1), at(text, onIt));
      expect(forward.selection.baseOffset, onIt + 1);
      final back = MarkupEditing.protect(at(text, onIt + 1), at(text, 2));
      expect(back.selection.baseOffset, 1);
    });
  });

  group('files', () {
    test('drawings are saved as text; names never collide', () async {
      final h = StorageHarness();
      addTearDown(h.dispose);
      final repo = AttachmentsRepository(h.db, h.store);
      final name = await repo.addDrawing('<svg/>');
      expect(AttachmentName.kindOf(name), AttachmentKind.drawing);
      expect(utf8.decode((await repo.read(name))!), '<svg/>');
      final other = await repo.add(Uint8List.fromList([2]), '.jpg');
      expect(other, isNot(name));
      expect(await repo.read(other), [2]);
    });
  });

  group('clean-up', () {
    late StorageHarness h;
    late AttachmentsRepository repo;
    late DateTime now;
    setUp(() {
      h = StorageHarness();
      now = DateTime(2026, 10, 8);
      repo = AttachmentsRepository(h.db, h.store, clock: () => now);
    });
    tearDown(() => h.dispose());

    Future<void> file(String name, int size) =>
        h.store.writeAttachment(name, Uint8List(size));

    test('unused means in no note; trashed notes still count', () async {
      await file('used.jpg', 10);
      await file('trashed.jpg', 20);
      await file('loose.jpg', 30);
      await h.repo.create('A\n${NoteMarkup.embed('used.jpg')}');
      final t = await h.repo.create('B\n${NoteMarkup.embed('trashed.jpg')}');
      await h.repo.trash(t);
      final usage = await repo.usage();
      expect((usage.count, usage.bytes), (3, 60));
      expect(usage.unused, ['loose.jpg']);
      expect(usage.unusedBytes, 30);
    });

    test('removing skips a file a note uses again by then', () async {
      await file('a.jpg', 1);
      await file('b.jpg', 1);
      await h.repo.create('Back\n${NoteMarkup.embed('b.jpg')}');
      await repo.delete(['a.jpg', 'b.jpg']);
      expect(h.store.attachments.keys, ['b.jpg']);
    });

    test('the automatic clean-up waits 30 days unused', () async {
      await file('old.jpg', 1);
      var since = await repo.sweep({});
      expect(since.keys, ['old.jpg']);
      now = now.add(const Duration(days: 29));
      since = await repo.sweep(since);
      expect(h.store.attachments.keys, ['old.jpg']);
      now = now.add(const Duration(days: 1));
      since = await repo.sweep(since);
      expect(h.store.attachments, isEmpty);
      expect(since, isEmpty);
    });

    test('plain files keep attachments beside Notes/', () async {
      final dir = await Directory.systemTemp.createTemp('vera_att');
      addTearDown(() => dir.delete(recursive: true));
      final store = IoNoteFileStore(Directory('${dir.path}/Notes'));
      await store.writeAttachment(photo, Uint8List.fromList([7, 8]));
      expect(File('${dir.path}/Attachments/$photo').readAsBytesSync(), [7, 8]);
      expect(await store.readAttachment('missing.jpg'), isNull);
      expect(
        () => store.writeAttachment('../x.jpg', Uint8List(0)),
        throwsArgumentError,
      );
    });

    test('moving notes to a picked folder brings their attachments', () async {
      final h = StorageHarness();
      addTearDown(h.dispose);
      final target = MemoryNoteFileStore();
      h.store.put('trip.md', 'Trip\n${NoteMarkup.embed('d.drawing.svg')}');
      await h.store.writeAttachment('d.drawing.svg', Uint8List.fromList([1]));
      await h.store.writeAttachment('unused.jpg', Uint8List.fromList([3]));
      await NotesRelocator(h.db).relocate(h.store, target);
      expect(target.attachments.keys, {'d.drawing.svg'});
    });
  });
}
