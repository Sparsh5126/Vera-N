import '../../models/note.dart';
import '../../models/suggestion.dart';
import '../../models/suggestion_view.dart';
import '../../storage/files/note_markup.dart';
import '../../storage/repositories/analysis_repository.dart';
import '../../storage/repositories/notes_repository.dart';

/// Turns stored suggestions into what the suggestion card shows: both
/// notes, newer first, each with the passage that matched.
class SuggestionViews {
  SuggestionViews(this._notes, this._analysis);

  final NotesRepository _notes;
  final AnalysisRepository _analysis;

  /// Null if a note of the pair is gone.
  Future<SuggestionView?> load(Suggestion s) async {
    final a = await _notes.getNote(s.noteA);
    final b = await _notes.getNote(s.noteB);
    if (a == null || b == null) return null;
    final first = await _side(a, s.chunkA);
    final second = await _side(b, s.chunkB);
    // A tag: the note to tag first, then the note that already has it.
    if (s.isTag) return SuggestionView(s, first, second);
    return a.created.isAfter(b.created)
        ? SuggestionView(s, first, second)
        : SuggestionView(s, second, first);
  }

  Future<List<SuggestionView>> loadAll(List<Suggestion> list) async {
    final views = <SuggestionView>[];
    for (final s in list) {
      final view = await load(s);
      if (view != null) views.add(view);
    }
    return views;
  }

  Future<SuggestedNote> _side(Note note, int chunk) async {
    final range = await _analysis.chunkRange(note.ref, chunk);
    final body = note.body;
    // The note may have changed since it was matched; then show its start.
    final usable = range != null && range.$2 <= body.length;
    final raw = usable ? body.substring(range.$1, range.$2) : body;
    return SuggestedNote(
      ref: note.ref,
      title: note.title,
      created: note.created,
      passage: NoteMarkup.display(raw, forScreen: true).trim(),
    );
  }
}
