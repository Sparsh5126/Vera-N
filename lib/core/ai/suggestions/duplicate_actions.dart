import '../../models/note.dart';
import '../../models/rejection.dart';
import '../../models/suggestion.dart';
import '../../storage/files/note_text.dart';
import '../../storage/repositories/note_merger.dart';
import '../../storage/repositories/notes_repository.dart';
import '../../storage/repositories/rejections_repository.dart';
import '../../storage/repositories/settings_repository.dart';
import '../../storage/repositories/suggestions_repository.dart';
import 'suggestion_actions.dart' show Undo;

/// What the user can do with two notes found to be copies, by the laptop
/// (docs/LAPTOP_PLAN.md, decided 2026-10-09) or by on-device matching
/// (user, 2026-10-22): Merge, Remove one, or say
/// they aren't copies. Nothing is deleted: a removed note goes to the
/// trash, and every choice has an Undo.
class DuplicateActions {
  DuplicateActions({
    required this.notes,
    required this.suggestions,
    required this.rejections,
    required this.settings,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final NotesRepository notes;
  final SuggestionsRepository suggestions;
  final RejectionsRepository rejections;
  final SettingsRepository settings;
  final DateTime Function() _clock;

  /// The note Merge keeps unless told otherwise: the one with more text
  /// (the older one when equal), so the least is added.
  static int keepByDefault(Note a, Note b) {
    if (a.body.length != b.body.length) {
      return a.body.length > b.body.length ? a.ref : b.ref;
    }
    return a.created.isAfter(b.created) ? b.ref : a.ref;
  }

  /// Adds to the kept note the lines only the other has, then moves the
  /// other to the trash.
  Future<Undo> merge(Suggestion s, {int? keep}) async {
    final pair = await _pair(s);
    if (pair == null) return _removeOnly(s);
    final keepRef = keep ?? keepByDefault(pair.$1, pair.$2);
    final other = s.otherThan(keepRef);
    final unmerge = await NoteMerger(notes).merge(keepRef, [other]);
    if (unmerge == null) return _removeOnly(s);
    await suggestions.remove(s.id);
    return () async {
      await unmerge();
      await suggestions.putBack(s);
    };
  }

  /// Moves [remove] to the trash and keeps the other as it is.
  Future<Undo> removeOne(Suggestion s, int remove) async {
    await notes.trash(remove);
    await suggestions.remove(s.id);
    return () async {
      await notes.restore(remove);
      await suggestions.putBack(s);
    };
  }

  /// They aren't copies: remembered in the rejections file, so neither
  /// device offers the pair as copies again (a link is still possible).
  Future<Undo> notCopies(Suggestion s) async {
    final pair = await _pair(s);
    final idA = await notes.ensureId(s.noteA);
    final idB = await notes.ensureId(s.noteB);
    if (pair == null || idA == null || idB == null) return _removeOnly(s);
    final (first, second) = Rejection.duplicateSides(idA, idB);
    final firstIsA = first == idA;
    final hashA = NoteText.contentHash(pair.$1.body);
    final hashB = NoteText.contentHash(pair.$2.body);
    final deviceId = await settings.deviceId();
    final rejection = Rejection(
      noteA: first,
      hashA: firstIsA ? hashA : hashB,
      noteB: second,
      hashB: firstIsA ? hashB : hashA,
      rejectedAt: _clock(),
      deviceId: deviceId,
    );
    await rejections.add(rejection);
    await suggestions.remove(s.id);
    return () async {
      await rejections.remove(rejection.pairKey, deviceId);
      await suggestions.putBack(s);
    };
  }

  Future<(Note, Note)?> _pair(Suggestion s) async {
    final a = await notes.getNote(s.noteA);
    final b = await notes.getNote(s.noteB);
    return a == null || b == null ? null : (a, b);
  }

  Future<Undo> _removeOnly(Suggestion s) async {
    await suggestions.remove(s.id);
    return () => suggestions.putBack(s);
  }
}
