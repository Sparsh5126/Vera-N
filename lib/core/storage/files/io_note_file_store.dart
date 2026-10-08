import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import 'note_file_store.dart';
import 'note_id.dart';

/// [NoteFileStore] on plain files: the app-private holding folder, desktop,
/// and tests.
class IoNoteFileStore implements NoteFileStore {
  IoNoteFileStore(this.root);

  final Directory root;

  static const appDir = '.app';
  static const attachmentsDir = 'Attachments';

  @override
  Future<List<NoteFileEntry>> listNotes() async {
    if (!await root.exists()) return const [];
    final entries = <NoteFileEntry>[];
    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      final rel = p.relative(entity.path, from: root.path);
      final parts = p.split(rel);
      if (parts.any((s) => s.startsWith('.'))) continue;
      if (p.extension(rel) != NoteId.fileExtension) continue;
      final stat = await entity.stat();
      entries.add(
        NoteFileEntry(
          path: parts.join('/'),
          modified: stat.modified,
          size: stat.size,
        ),
      );
    }
    return entries;
  }

  @override
  Future<bool> exists(String path) => _file(path).exists();

  @override
  Future<NoteFileEntry?> stat(String path) async {
    final file = _file(path);
    if (!await file.exists()) return null;
    final stat = await file.stat();
    return NoteFileEntry(path: path, modified: stat.modified, size: stat.size);
  }

  @override
  Future<String> read(String path) => _file(path).readAsString();

  /// Writes to a hidden temp file, then renames, so a crash never leaves a
  /// half-written note.
  @override
  Future<NoteFileEntry> write(String path, String content) async {
    final file = _file(path);
    await file.parent.create(recursive: true);
    final temp = File(
      p.join(file.parent.path, '.${p.basename(file.path)}.tmp'),
    );
    await temp.writeAsString(content, flush: true);
    await temp.rename(file.path);
    final stat = await file.stat();
    return NoteFileEntry(path: path, modified: stat.modified, size: stat.size);
  }

  @override
  Future<void> move(String from, String to) async {
    final target = _file(to);
    await target.parent.create(recursive: true);
    await _file(from).rename(target.path);
  }

  @override
  Future<void> delete(String path) => _file(path).delete();

  /// `.app/` sits next to the notes folder, inside `MyNotes/`.
  @override
  Future<String?> readAppFile(String name) async {
    final file = _appFile(name);
    return await file.exists() ? file.readAsString() : null;
  }

  @override
  Future<void> writeAppFile(String name, String content) async {
    final file = _appFile(name);
    await file.parent.create(recursive: true);
    final temp = File('${file.path}.tmp');
    await temp.writeAsString(content, flush: true);
    await temp.rename(file.path);
  }

  @override
  Future<List<String>> listAppFiles() async {
    final dir = Directory(p.join(root.parent.path, appDir));
    if (!await dir.exists()) return const [];
    return [
      await for (final entry in dir.list())
        if (entry is File && !entry.path.endsWith('.tmp'))
          p.basename(entry.path),
    ];
  }

  /// `Attachments/` sits next to the notes folder, inside `MyNotes/`.
  @override
  Future<Uint8List?> readAttachment(String name) async {
    final file = _attachment(name);
    return await file.exists() ? file.readAsBytes() : null;
  }

  @override
  Future<void> writeAttachment(String name, Uint8List bytes) async {
    final file = _attachment(name);
    await file.parent.create(recursive: true);
    final temp = File(p.join(file.parent.path, '.$name.tmp'));
    await temp.writeAsBytes(bytes, flush: true);
    await temp.rename(file.path);
  }

  @override
  Future<List<NoteFileEntry>> listAttachments() async {
    final dir = Directory(p.join(root.parent.path, attachmentsDir));
    if (!await dir.exists()) return const [];
    final entries = <NoteFileEntry>[];
    await for (final entry in dir.list()) {
      final name = p.basename(entry.path);
      if (entry is! File || name.startsWith('.')) continue;
      final stat = await entry.stat();
      entries.add(
        NoteFileEntry(path: name, modified: stat.modified, size: stat.size),
      );
    }
    return entries;
  }

  @override
  Future<void> deleteAttachment(String name) async {
    final file = _attachment(name);
    if (await file.exists()) await file.delete();
  }

  File _attachment(String name) =>
      File(p.join(root.parent.path, attachmentsDir, checkAppFileName(name)));

  File _appFile(String name) =>
      File(p.join(root.parent.path, appDir, checkAppFileName(name)));

  /// Resolves [path] inside [root], refusing anything that escapes it.
  File _file(String path) {
    if (p.isAbsolute(path)) {
      throw ArgumentError.value(path, 'path', 'not a safe note path');
    }
    return File(p.joinAll([root.path, ...checkNotePath(path)]));
  }
}
