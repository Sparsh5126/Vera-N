import '../../models/archive_folder.dart';
import '../../models/locked_folder.dart';
import 'analysis_repository.dart';
import 'note_merger.dart';
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

  /// Merges [refs] into the first selected (user, 2026-10-22): each next
  /// one is added to it in turn, then goes to the trash (see
  /// [NoteMerger]). Returns the kept note's title and the undo, or null
  /// when a note is gone. The caller checks [mergeWouldUnlock] first.
  Future<({String title, Future<void> Function() undo})?> merge(
    List<int> refs,
  ) async {
    if (refs.length < 2) return null;
    final undo = await NoteMerger(_notes).merge(refs.first, refs.sublist(1));
    final kept = await _notes.getNote(refs.first);
    if (undo == null || kept == null) return null;
    return (title: kept.title, undo: undo);
  }

  /// True when a locked note would be merged into one that isn't locked:
  /// its words would leave the Locked folder.
  Future<bool> mergeWouldUnlock(List<int> refs) async {
    final notes = [for (final ref in refs) await _notes.getNote(ref)];
    final first = notes.firstOrNull;
    if (first == null || LockedFolder.contains(first.folder)) return false;
    return notes.any((n) => n != null && LockedFolder.contains(n.folder));
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
