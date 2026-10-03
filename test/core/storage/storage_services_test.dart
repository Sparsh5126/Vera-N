import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/storage/db/app_database.dart';
import 'package:vera_n/core/storage/storage_services.dart';

import '../../support/fake_folder_access.dart';
import '../../support/memory_note_file_store.dart';

void main() {
  late AppDatabase db;
  late MemoryNoteFileStore holding;
  late FakeFolderAccess folders;
  late StorageServices storage;
  const picked = 'content://picked/Vera N';

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
    holding = MemoryNoteFileStore();
    folders = FakeFolderAccess();
    storage = StorageServices(db, holding, folders: folders);
  });

  tearDown(() async {
    storage.writer.dispose();
    await db.close();
  });

  Future<List<NoteRow>> rows() => db.select(db.notes).get();

  test('choosing a folder moves notes there and remembers it', () async {
    final ref = await storage.notes.create('Kept safe');
    await storage.writer.flush();
    final path = (await rows()).single.path;

    expect(await storage.chooseFolder(), isTrue);

    expect(holding.files, isEmpty);
    expect(folders.folder(picked).text(path), endsWith('Kept safe'));
    expect(await storage.settings.notesFolder(), picked);
    expect(await storage.notesFolderName(), 'Vera N');

    await storage.notes.updateBody(ref, 'Kept safe, edited');
    await storage.writer.flush();
    expect(folders.folder(picked).text(path), endsWith('edited'));
  });

  test('backing out of the picker changes nothing', () async {
    folders.nextPick = null;
    await storage.notes.create('Still here');
    await storage.writer.flush();
    expect(await storage.chooseFolder(), isFalse);
    expect(holding.files, hasLength(1));
    expect(await storage.settings.notesFolder(), isNull);
  });

  test('a picked folder with notes already in it keeps them', () async {
    folders.folder(picked).put('Old/from laptop.md', 'From the laptop');
    await storage.notes.create('From the phone');
    await storage.writer.flush();
    await storage.chooseFolder();
    expect(await rows(), hasLength(2));
    expect((await rows()).map((r) => r.title).toSet(), {
      'From the laptop',
      'From the phone',
    });
  });

  test('a same-named file with other text is not overwritten', () async {
    holding.put('idea.md', 'Phone version');
    await storage.reconcile();
    folders.folder(picked).put('idea.md', 'Laptop version');
    await storage.chooseFolder();
    final store = folders.folder(picked);
    expect(store.text('idea.md'), 'Laptop version');
    final moved = store.files.keys.singleWhere((k) => k != 'idea.md');
    expect(store.text(moved), 'Phone version');
    expect((await rows()).map((r) => r.path).toSet(), {'idea.md', moved});
  });

  test('on restart, the picked folder is used again', () async {
    await storage.settings.setNotesFolder(picked);
    folders.folder(picked).put('a.md', 'In the folder');
    await storage.reconnectFolder();
    await storage.reconcile();
    expect((await rows()).single.title, 'In the folder');
  });

  test('if access was removed, notes are rewritten into the app', () async {
    await storage.chooseFolder();
    await storage.notes.create('Do not lose me');
    await storage.writer.flush();
    folders.revoked.add(picked);

    await storage.reconnectFolder();
    await storage.writer.flush();

    expect(await storage.settings.notesFolder(), isNull);
    expect(holding.files.values.single.text, endsWith('Do not lose me'));
    await storage.reconcile();
    expect((await rows()).single.title, 'Do not lose me');
  });
}
