import '../files/note_merge.dart';
import 'notes_repository.dart';

/// Merges notes into one (see [NoteMerge]): copies in Review, and the
/// notes selected on Home. Nothing is deleted: merged notes go to the
/// trash, and the returned undo brings them back.
class NoteMerger {
  NoteMerger(this._notes);

  final NotesRepository _notes;

  /// Adds to [keep] the lines only [others] have, each in turn (the order
  /// they were selected in), then moves [others] to the trash. Returns
  /// the undo, or null if a note is gone.
  Future<Future<void> Function()?> merge(int keep, List<int> others) async {
    final kept = await _notes.getNote(keep);
    if (kept == null) return null;
    var merged = kept.body;
    for (final ref in others) {
      final other = await _notes.getNote(ref);
      if (other == null) return null;
      merged = NoteMerge.merge(merged, other.body);
    }
    final changed = merged.trimRight() != kept.body.trimRight();
    if (changed) await _notes.updateBody(keep, merged);
    for (final ref in others) {
      await _notes.trash(ref);
    }
    return () async {
      for (final ref in others) {
        await _notes.restore(ref);
      }
      // Only if it wasn't edited since: Undo never touches the user's words.
      final now = await _notes.getNote(keep);
      if (changed && now?.body == merged) {
        await _notes.updateBody(keep, kept.body);
      }
    };
  }
}
