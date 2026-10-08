import '../../models/search_filters.dart';
import '../../models/search_hit.dart';
import '../../storage/files/note_markup.dart';
import '../../storage/repositories/analysis_repository.dart';
import '../../storage/repositories/notes_repository.dart';
import '../ai_settings.dart';
import '../embedder/embedder.dart';
import '../matching/vectors.dart';

/// "Similar in meaning" in Search (UI spec §9): notes whose meaning is
/// close to the words typed, found with the same on-device model as the
/// suggestions, against the passage vectors already stored. Nothing leaves
/// the phone.
///
/// The model loads on the first search and stays loaded only while Search
/// is open ([close] releases it), so each keystroke doesn't pay the load.
class MeaningSearch {
  MeaningSearch(
    this._analysis,
    this._notes, {
    required Embedder Function() embedder,
  }) : _makeEmbedder = embedder;

  final AnalysisRepository _analysis;
  final NotesRepository _notes;
  final Embedder Function() _makeEmbedder;
  Embedder? _embedder;
  Future<Embedder>? _loading;

  /// Up to [AiSettings.similarResults] notes close in meaning to [query],
  /// best first, leaving out [exclude] (the keyword matches) and notes the
  /// [filters] rule out. Each shows its closest passage.
  Future<List<SearchHit>> search(
    String query, {
    SearchFilters filters = const SearchFilters(),
    Set<int> exclude = const {},
  }) async {
    final words = query.trim();
    if (words.isEmpty) return const [];
    final embedder = await _ready();
    final target = Vectors.quantize(await embedder.embed(words));
    final best = <int, ({double score, int start, int end})>{};
    for (final c in await _analysis.allChunks(embedder.model)) {
      if (exclude.contains(c.note)) continue;
      final score = Vectors.cosine(target, c.vector);
      if (score < AiSettings.similarSearch) continue;
      final seen = best[c.note];
      if (seen == null || score > seen.score) {
        best[c.note] = (score: score, start: c.start, end: c.end);
      }
    }
    final allowed = filters.isActive ? await _allowed(filters) : null;
    final ranked =
        best.entries
            .where((e) => allowed == null || allowed.contains(e.key))
            .toList()
          ..sort((a, b) => b.value.score.compareTo(a.value.score));
    final hits = <SearchHit>[];
    for (final e in ranked.take(AiSettings.similarResults)) {
      final note = await _notes.getNote(e.key);
      if (note == null) continue;
      final end = e.value.end.clamp(0, note.body.length);
      final start = e.value.start.clamp(0, end);
      hits.add(
        SearchHit(
          ref: note.ref,
          title: MarkedText(note.title, const []),
          snippet: MarkedText(
            NoteMarkup.display(
              note.body.substring(start, end),
              forScreen: true,
            ).trim(),
            const [],
          ),
          modified: note.modified,
        ),
      );
    }
    return hits;
  }

  /// Releases the model (leaving Search).
  Future<void> close() async {
    final loading = _loading;
    _loading = null;
    _embedder = null;
    if (loading != null) await (await loading).close();
  }

  Future<Embedder> _ready() {
    final ready = _embedder;
    if (ready != null) return Future.value(ready);
    return _loading ??= () async {
      final embedder = _makeEmbedder();
      await embedder.load();
      _embedder = embedder;
      return embedder;
    }();
  }

  Future<Set<int>> _allowed(SearchFilters filters) async {
    final notes = await _notes.watchNotes(filters: filters).first;
    return {for (final n in notes) n.ref};
  }
}
