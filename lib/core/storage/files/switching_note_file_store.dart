import 'note_file_store.dart';

/// Forwards to the current notes folder, so the writer, indexer and
/// repository keep working when the user picks a folder.
class SwitchingNoteFileStore implements NoteFileStore {
  SwitchingNoteFileStore(this._current);

  NoteFileStore _current;

  NoteFileStore get current => _current;

  void switchTo(NoteFileStore store) => _current = store;

  @override
  Future<List<NoteFileEntry>> listNotes() => _current.listNotes();

  @override
  Future<bool> exists(String path) => _current.exists(path);

  @override
  Future<NoteFileEntry?> stat(String path) => _current.stat(path);

  @override
  Future<String> read(String path) => _current.read(path);

  @override
  Future<NoteFileEntry> write(String path, String content) =>
      _current.write(path, content);

  @override
  Future<void> move(String from, String to) => _current.move(from, to);

  @override
  Future<void> delete(String path) => _current.delete(path);
}
