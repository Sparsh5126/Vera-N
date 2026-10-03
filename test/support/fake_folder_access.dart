import 'package:vera_n/core/storage/files/folder_access.dart';
import 'package:vera_n/core/storage/files/note_file_store.dart';

import 'memory_note_file_store.dart';

/// [FolderAccess] with in-memory folders, standing in for Android's picker.
class FakeFolderAccess implements FolderAccess {
  /// What the next [pick] returns; null means the user backed out.
  String? nextPick = 'content://picked/Vera N';
  final folders = <String, MemoryNoteFileStore>{};
  final revoked = <String>{};

  MemoryNoteFileStore folder(String uri) =>
      folders.putIfAbsent(uri, MemoryNoteFileStore.new);

  @override
  Future<String?> pick() async => nextPick;

  @override
  Future<bool> hasAccess(String folder) async => !revoked.contains(folder);

  @override
  Future<String?> displayName(String folder) async => folder.split('/').last;

  @override
  NoteFileStore storeFor(String uri) => folder(uri);
}
