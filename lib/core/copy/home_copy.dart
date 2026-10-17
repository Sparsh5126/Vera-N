import 'app_copy.dart';

/// Home's Folders view and selecting notes (UI spec §5). Exported by
/// `app_copy.dart`, the one import point for copy.
abstract final class HomeCopy {
  /// How many notes a folder holds: information, not a badge, so plain.
  static String noteCount(int n) => n == 1 ? '1 note' : '$n notes';

  /// Under a subfolder's name: the folders it sits in.
  static String inFolder(String parent) => 'in $parent';

  /// The back arrow above an opened folder's notes.
  static const allFolders = 'All folders';

  // Selecting notes (hold a card and let go).

  static String selectedCount(int n) => '$n selected';
  static const stopSelecting = 'Stop selecting';
  static const selectedNote = 'Selected';
  static const actionFolder = 'Folder';
  static const actionLock = 'Lock';
  static const actionArchive = 'Archive';

  /// After acting on [n] notes; one note keeps the single-note wording.
  static String movedNotes(int n, String folder) => switch ((n, folder)) {
    (1, '') => AppCopy.movedOutOfFolder,
    (1, _) => AppCopy.movedTo(folder),
    (_, '') => '$n notes moved out of their folders',
    _ => '$n notes moved to $folder',
  };
  static String archivedNotes(int n) =>
      n == 1 ? AppCopy.archived : '$n notes archived';
  static String lockedNotes(int n) =>
      n == 1 ? AppCopy.movedToLocked : '$n notes moved to Locked folder';
  static String trashedNotes(int n) =>
      n == 1 ? AppCopy.movedToTrash : '$n notes moved to trash';

  // Dragging notes onto folders.

  static const dropOnFolder = 'Drop on a folder, or rest on one to open it';
  static String dropInto(String folder) => 'Drop to move into $folder';

  /// What a screen reader hears for a folder card.
  static String folderCard(String name, String? parent, int notes) =>
      [name, if (parent != null) inFolder(parent), noteCount(notes)].join(', ');
}
