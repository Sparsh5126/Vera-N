import 'dart:typed_data';

import 'note_file_store.dart';
import 'notes_folder_channel.dart';

/// [NoteFileStore] inside the folder the user picked on Android.
///
/// The picked folder is `MyNotes/`; notes live in its `Notes/` subfolder.
class SafNoteFileStore implements NoteFileStore {
  SafNoteFileStore(this.tree, {this.channel = const NotesFolderChannel()});

  static const notesDir = 'Notes';
  static const appDir = '.app';
  static const attachmentsDir = 'Attachments';

  /// URI of the picked folder.
  final String tree;
  final NotesFolderChannel channel;

  @override
  Future<List<NoteFileEntry>> listNotes() async {
    final raw = await channel.call<List<Object?>>('list', tree, path: notesDir);
    return [
      for (final item in raw ?? const [])
        _entry((item! as Map)['path'] as String, item),
    ];
  }

  @override
  Future<bool> exists(String path) async => await stat(path) != null;

  @override
  Future<NoteFileEntry?> stat(String path) async {
    final raw = await channel.call<Map<Object?, Object?>>(
      'stat',
      tree,
      path: _full(path),
    );
    return raw == null ? null : _entry(path, raw);
  }

  @override
  Future<String> read(String path) async =>
      await channel.call<String>('read', tree, path: _full(path)) ?? '';

  @override
  Future<NoteFileEntry> write(String path, String content) async {
    final raw = await channel.call<Map<Object?, Object?>>(
      'write',
      tree,
      path: _full(path),
      extra: {'content': content},
    );
    return _entry(path, raw!);
  }

  @override
  Future<void> move(String from, String to) => channel.call<void>(
    'move',
    tree,
    path: _full(from),
    extra: {'to': _full(to)},
  );

  @override
  Future<void> delete(String path) =>
      channel.call<void>('delete', tree, path: _full(path));

  @override
  Future<String?> readAppFile(String name) async {
    final path = '$appDir/${checkAppFileName(name)}';
    final found = await channel.call<Map<Object?, Object?>>(
      'stat',
      tree,
      path: path,
    );
    if (found == null) return null;
    return channel.call<String>('read', tree, path: path);
  }

  @override
  Future<void> writeAppFile(String name, String content) =>
      channel.call<Map<Object?, Object?>>(
        'write',
        tree,
        path: '$appDir/${checkAppFileName(name)}',
        extra: {'content': content},
      );

  @override
  Future<List<String>> listAppFiles() async {
    final raw = await channel.call<List<Object?>>('names', tree, path: appDir);
    return [for (final name in raw ?? const []) name! as String];
  }

  @override
  Future<Uint8List?> readAttachment(String name) => channel.call<Uint8List>(
    'readBytes',
    tree,
    path: '$attachmentsDir/${checkAppFileName(name)}',
  );

  @override
  Future<void> writeAttachment(String name, Uint8List bytes) =>
      channel.call<void>(
        'writeBytes',
        tree,
        path: '$attachmentsDir/${checkAppFileName(name)}',
        extra: {'bytes': bytes},
      );

  String _full(String path) => '$notesDir/${checkNotePath(path).join('/')}';

  NoteFileEntry _entry(String path, Map<Object?, Object?> raw) {
    return NoteFileEntry(
      path: path,
      modified: DateTime.fromMillisecondsSinceEpoch(raw['modified']! as int),
      size: raw['size']! as int,
    );
  }
}
