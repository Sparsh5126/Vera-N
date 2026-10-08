import 'dart:typed_data';

import 'package:vera_n/core/storage/files/note_file_store.dart';

/// In-memory [NoteFileStore] with a fake clock, for fast storage tests.
///
/// Every write moves the clock forward one second, so file times differ.
/// Paths are case-sensitive, like Android's own storage.
class MemoryNoteFileStore implements NoteFileStore {
  final files = <String, ({String text, DateTime modified})>{};
  var reads = 0;
  var _now = DateTime(2026, 10, 3, 12);

  /// Writes as another app would (Syncthing, Obsidian).
  void put(String path, String text, {DateTime? modified}) {
    _now = _now.add(const Duration(seconds: 1));
    files[path] = (text: text, modified: modified ?? _now);
  }

  String? text(String path) => files[path]?.text;

  NoteFileEntry _entry(String path) {
    final f = files[path]!;
    return NoteFileEntry(path: path, modified: f.modified, size: f.text.length);
  }

  @override
  Future<List<NoteFileEntry>> listNotes() async => [
    for (final path in files.keys)
      if (path.endsWith('.md') &&
          !path.split('/').any((s) => s.startsWith('.')))
        _entry(path),
  ];

  @override
  Future<bool> exists(String path) async => files.containsKey(path);

  @override
  Future<NoteFileEntry?> stat(String path) async =>
      files.containsKey(path) ? _entry(path) : null;

  @override
  Future<String> read(String path) async {
    reads++;
    return files[path]!.text;
  }

  @override
  Future<NoteFileEntry> write(String path, String content) async {
    put(path, content);
    return _entry(path);
  }

  @override
  Future<void> move(String from, String to) async {
    files[to] = files.remove(from)!;
  }

  @override
  Future<void> delete(String path) async {
    files.remove(path);
  }

  /// Files in `.app/`, by name.
  final appFiles = <String, String>{};

  @override
  Future<String?> readAppFile(String name) async =>
      appFiles[checkAppFileName(name)];

  @override
  Future<void> writeAppFile(String name, String content) async {
    appFiles[checkAppFileName(name)] = content;
  }

  @override
  Future<List<String>> listAppFiles() async => appFiles.keys.toList();

  /// Files in `Attachments/`, by name.
  final attachments = <String, Uint8List>{};

  @override
  Future<Uint8List?> readAttachment(String name) async =>
      attachments[checkAppFileName(name)];

  @override
  Future<void> writeAttachment(String name, Uint8List bytes) async {
    attachments[checkAppFileName(name)] = bytes;
  }

  @override
  Future<List<NoteFileEntry>> listAttachments() async => [
    for (final e in attachments.entries)
      NoteFileEntry(path: e.key, modified: _now, size: e.value.length),
  ];

  @override
  Future<void> deleteAttachment(String name) async {
    attachments.remove(checkAppFileName(name));
  }
}
