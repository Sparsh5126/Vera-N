import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/features/note/state/note_editor_controller.dart';

import '../../support/storage_harness.dart';

void main() {
  late StorageHarness h;

  setUp(() => h = StorageHarness());
  tearDown(() => h.dispose());

  Future<int> noteCount() async => (await h.db.select(h.db.notes).get()).length;

  test(
    'opening a new note and leaving without typing creates nothing',
    () async {
      final editor = NoteEditorController(h.repo);
      editor.onTextChanged('   ');
      await editor.dispose();
      expect(await noteCount(), 0);
    },
  );

  test('first text creates the note once; later text updates it', () async {
    final editor = NoteEditorController(h.repo);
    editor.onTextChanged('F');
    editor.onTextChanged('Fu');
    await editor.save();
    final ref = editor.noteRef.value;
    expect(ref, isNotNull);
    editor.onTextChanged('Future Self');
    await editor.save();
    expect(await noteCount(), 1);
    expect((await h.row(ref!)).title, 'Future Self');
    expect(editor.saves.value, 2);
    await editor.dispose();
  });

  test('saves made back to back never create two notes', () async {
    final editor = NoteEditorController(h.repo);
    editor.onTextChanged('a');
    final first = editor.save();
    editor.onTextChanged('ab');
    await Future.wait([first, editor.save()]);
    expect(await noteCount(), 1);
    expect((await h.row(editor.noteRef.value!)).body, 'ab');
    await editor.dispose();
  });

  test('leaving saves unsaved text', () async {
    final editor = NoteEditorController(h.repo);
    editor.onTextChanged('Typed and left');
    await editor.dispose();
    final rows = await h.db.select(h.db.notes).get();
    expect(rows.single.body, 'Typed and left');
  });

  test('pin and trash act on the saved note', () async {
    final editor = NoteEditorController(h.repo);
    editor.onTextChanged('Pin me');
    await editor.setPinned(true);
    final ref = editor.noteRef.value!;
    expect((await h.row(ref)).pinned, isTrue);
    expect(await editor.trash(), ref);
    expect((await h.row(ref)).trashedAt, isNotNull);
    await editor.dispose();
  });
  group('a note left empty is deleted on leaving', () {
    test('typed, then cleared: the note and its file go', () async {
      final editor = NoteEditorController(h.repo);
      editor.onTextChanged('Short-lived');
      await editor.save();
      final path = (await h.row(editor.noteRef.value!)).path;
      editor.onTextChanged(' \n ');
      await editor.dispose();
      expect(await noteCount(), 0);
      expect(h.store.files.containsKey(path), isFalse);
    });

    test('an existing note cleared and left goes too', () async {
      final ref = await h.repo.create('Old thought');
      final editor = NoteEditorController(h.repo, ref: ref);
      editor.onTextChanged('');
      await editor.dispose();
      expect(await noteCount(), 0);
    });

    test('opening a note and leaving it unchanged keeps it', () async {
      final ref = await h.repo.create('Keep me');
      await NoteEditorController(h.repo, ref: ref).dispose();
      expect(await noteCount(), 1);
    });

    test('a note with only an attachment or a link is not empty', () async {
      final photo = await h.repo.create('![](Attachments/a.jpg)');
      final link = await h.repo.create('https://ex.com/a');
      await NoteEditorController(h.repo, ref: photo).dispose();
      await NoteEditorController(h.repo, ref: link).dispose();
      expect(await noteCount(), 2);
    });

    test('text that arrived meanwhile (sync) keeps the note', () async {
      final ref = await h.repo.create('Draft');
      final editor = NoteEditorController(h.repo, ref: ref);
      editor.onTextChanged('');
      await editor.save();
      await h.repo.updateBody(ref, 'Written on the laptop');
      await editor.dispose();
      expect((await h.row(ref)).body, 'Written on the laptop');
    });

    test('a trashed note is left for the trash', () async {
      final editor = NoteEditorController(h.repo);
      editor.onTextChanged('Bin me');
      await editor.save();
      final ref = await editor.trash();
      await h.repo.updateBody(ref!, '');
      await editor.dispose();
      expect((await h.row(ref)).trashedAt, isNotNull);
    });
  });
}
