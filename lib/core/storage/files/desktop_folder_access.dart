import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as p;

import 'folder_access.dart';
import 'io_note_file_store.dart';
import 'note_file_store.dart';

/// [FolderAccess] on a laptop (docs/LAPTOP_PLAN.md, L0): the folder is a
/// plain path, typically the `MyNotes` folder Syncthing shares with the
/// phone. Notes are in its `Notes/` subfolder, as on the phone.
class DesktopFolderAccess implements FolderAccess {
  const DesktopFolderAccess();

  static const notesDir = 'Notes';

  @override
  Future<String?> pick() => getDirectoryPath();

  @override
  Future<bool> hasAccess(String folder) => Directory(folder).exists();

  @override
  Future<String?> displayName(String folder) async => p.basename(folder);

  @override
  NoteFileStore storeFor(String folder) =>
      IoNoteFileStore(Directory(p.join(folder, notesDir)));
}
