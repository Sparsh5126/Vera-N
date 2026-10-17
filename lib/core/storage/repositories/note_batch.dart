import '../../models/archive_folder.dart';
import '../../models/locked_folder.dart';
import 'analysis_repository.dart';
import 'notes_repository.dart';

/// Actions on several notes at once: Home's selection and drag and drop
/// (UI spec §5). Each move returns where every note was, so one Undo
/// ([putBack]) restores the whole batch. File names never change; only
/// folders do, as with a single note.
class NoteBatch {
  NoteBatch(this._notes, this._analysis);

  final NotesRepository _notes;
  final AnalysisRepository _analysis;

  /// Moves [refs] into [folder] (`''` is the top level). Returns each moved
  /// note's old folder.
  Future<Map<int, String>> move(Iterable<int> refs, String folder) =>
      _moveEach(refs, (_) => folder);

  /// Into `Archive/`, each keeping its folder inside. Locked notes stay
  /// locked: archiving would take them out of `Locked/`.
  Future<Map<int, String>> archive(Iterable<int> refs) => _moveEach(
    refs,
    (f) => ArchiveFolder.contains(f) || LockedFolder.contains(f)
        ? null
        : ArchiveFolder.into(f),
  );

  /// Into `Locked/`, each keeping its folder inside; then the AI forgets
  /// everything it stored about them. The caller checks for a screen lock
  /// first, or they couldn't be opened.
  Future<Map<int, String>> lock(Iterable<int> refs) async {
    final old = await _moveEach(
      refs,
      (f) => LockedFolder.contains(f) ? null : LockedFolder.into(f),
    );
    await _analysis.forgetLocked();
    return old;
  }

  /// Puts each note back in its folder: Undo for [move], [archive], [lock].
  Future<void> putBack(Map<int, String> old) async {
    for (final MapEntry(key: ref, value: folder) in old.entries) {
      await _notes.moveToFolder(ref, folder);
    }
  }

  /// Pins or unpins every note in [refs].
  Future<void> pin(Iterable<int> refs, {required bool pinned}) async {
    for (final ref in refs) {
      await _notes.setPinned(ref, pinned);
    }
  }

  /// Moves every note in [refs] to the trash; [restore] brings them back.
  Future<void> trash(Iterable<int> refs) async {
    for (final ref in refs) {
      await _notes.trash(ref);
    }
  }

  Future<void> restore(Iterable<int> refs) async {
    for (final ref in refs) {
      await _notes.restore(ref);
    }
  }

  /// Moves each note to `target(its folder)`, skipping notes already there
  /// or for which [target] gives null.
  Future<Map<int, String>> _moveEach(
    Iterable<int> refs,
    String? Function(String folder) target,
  ) async {
    final old = <int, String>{};
    for (final ref in refs) {
      final note = await _notes.getNote(ref);
      if (note == null) continue;
      final to = target(note.folder);
      if (to == null || to.toLowerCase() == note.folder.toLowerCase()) {
        continue;
      }
      final was = await _notes.moveToFolder(ref, to);
      if (was != null) old[ref] = was;
    }
    return old;
  }
}
