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
}
