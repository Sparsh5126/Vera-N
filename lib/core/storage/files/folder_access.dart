import 'note_file_store.dart';
import 'notes_folder_channel.dart';
import 'saf_note_file_store.dart';

/// Choosing the user-visible notes folder and opening it.
abstract interface class FolderAccess {
  /// Shows the system folder picker. Null if the user backed out.
  Future<String?> pick();

  /// Whether the app may still read and write [folder].
  Future<bool> hasAccess(String folder);

  /// The folder's name as the user sees it, e.g. "Vera N".
  Future<String?> displayName(String folder);

  /// The notes inside [folder] (its `Notes/` subfolder).
  NoteFileStore storeFor(String folder);
}

/// [FolderAccess] through Android's Storage Access Framework.
class AndroidFolderAccess implements FolderAccess {
  const AndroidFolderAccess([this._channel = const NotesFolderChannel()]);

  final NotesFolderChannel _channel;

  @override
  Future<String?> pick() => _channel.pick();

  @override
  Future<bool> hasAccess(String folder) => _channel.hasAccess(folder);

  @override
  Future<String?> displayName(String folder) => _channel.displayName(folder);

  @override
  NoteFileStore storeFor(String folder) =>
      SafNoteFileStore(folder, channel: _channel);
}
