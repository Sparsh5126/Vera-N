import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../../models/chunk_vector.dart';
import '../../models/note_to_analyze.dart';
import '../../models/suggestion.dart';
import '../../models/suggestion_draft.dart';
import '../../storage/repositories/analysis_repository.dart';
import '../../storage/repositories/suggestions_repository.dart';
import '../ai_settings.dart';
import '../chunking/note_chunker.dart';
import '../embedder/embedder.dart';
import '../matching/note_matcher.dart';
import '../matching/tag_suggester.dart';
import '../matching/vectors.dart';
import '../matching/word_signature.dart';

/// One batch of on-device analysis (product spec §4):
/// 1. drop expired suggestions;
/// 2. embed only notes whose text changed, and in them only the chunks
///    that changed (the model is loaded only if there is work, then
///    released);
/// 3. match each changed note against the others; strong matches become
///    suggestions.
class AnalysisRun {
  AnalysisRun({
    required this.analysis,
    required this.suggestions,
    required this.embedder,
    DateTime Function()? clock,
    Stopwatch? stopwatch,
    bool Function()? stopRequested,
    this.linkThreshold = AiSettings.strongMatch,
    this.tagThreshold = AiSettings.strongMatch,
  }) : _stopRequested = stopRequested ?? _never,
       _clock = clock ?? DateTime.now,
       _stopwatch = stopwatch ?? Stopwatch();

  /// The link bar, as learned from accept rates (product spec §8).
  final double linkThreshold;

  /// The bar for a tag's neighbours, learned separately (kind `tag`).
  final double tagThreshold;
  final AnalysisRepository analysis;
  final SuggestionsRepository suggestions;
  final Embedder embedder;

  final DateTime Function() _clock;
  final Stopwatch _stopwatch;

  /// Set when the system ends the work (charger unplugged, phone in use):
  /// the run finishes the note it is on and stops (CLAUDE.md §8).
  final bool Function() _stopRequested;

  static bool _never() => false;

  /// Runs one batch. Returns true when no changed notes are left.
  Future<bool> run() async {
    _stopwatch.start();
    await suggestions.expire(_clock());
    final model = embedder.model;
    final stale = await analysis.stale(model, limit: AiSettings.notesPerRun);
    if (stale.isEmpty) return true;

    final changed = <int>[];
    await embedder.load();
    try {
      for (final note in stale) {
        if (_stopRequested() || _stopwatch.elapsed > AiSettings.runBudget) {
          break;
        }
        if (await _embed(note, model)) changed.add(note.ref);
      }
    } finally {
      await embedder.close();
    }
    await _match(changed, model);
    return changed.length == stale.length &&
        stale.length < AiSettings.notesPerRun;
  }

  /// Embeds [note]'s changed chunks and stores them. Returns true when it
  /// has chunks to match.
  Future<bool> _embed(NoteToAnalyze note, String model) async {
    final old = {
      for (final c in await analysis.chunksOf(note.ref, model))
        c.hash: c.vector,
    };
    final pieces = _wordCount(note.body) < AiSettings.minWords
        ? const <TextChunk>[]
        : NoteChunker.split(
            note.body,
            embedder.countTokens,
            maxTokens: AiSettings.chunkTokens,
          );
    final chunks = <ChunkVector>[];
    for (final (i, piece) in pieces.indexed) {
      final hash = sha256.convert(utf8.encode(piece.text)).toString();
      final vector =
          old[hash] ?? Vectors.quantize(await embedder.embed(piece.text));
      chunks.add(
        ChunkVector(
          note: note.ref,
          idx: i,
          start: piece.start,
          end: piece.end,
          hash: hash,
          vector: vector,
        ),
      );
    }
    await analysis.save(note.ref, note.contentHash, model, chunks, _clock());
    return chunks.isNotEmpty;
  }

  Future<void> _match(List<int> changed, String model) async {
    if (changed.isEmpty) return;
    final all = await analysis.allChunks(model);
    final dates = await analysis.modifiedTimes();
    final drafts = <SuggestionDraft>[];
    for (final ref in changed) {
      final own = all.where((c) => c.note == ref).toList();
      drafts
        ..addAll(await _linkDrafts(ref, own, all))
        ..addAll(await _tagDrafts(ref, own, all))
        ..addAll(await _revisitDrafts(ref, own, all, dates));
    }
    await suggestions.add(drafts, _clock(), AiSettings.suggestionLifetime);
  }

  Future<List<SuggestionDraft>> _linkDrafts(
    int ref,
    List<ChunkVector> own,
    List<ChunkVector> all,
  ) async {
    final matches = NoteMatcher.strongMatches(
      own,
      all,
      threshold: linkThreshold,
      limit: AiSettings.suggestionsPerNote,
      exclude: {
        ref,
        ...await analysis.linkedWith(ref),
        ...await _stillRejected(ref),
      },
    );
    return [
      for (final m in matches)
        SuggestionDraft(
          kind: Suggestion.linkKind,
          noteA: ref,
          noteB: m.note,
          score: m.score,
          chunkA: m.ownChunk,
          chunkB: m.otherChunk,
        ),
    ];
  }

  /// Tags that notes very close to [ref] share and it lacks (product spec
  /// §11; see [TagSuggester]).
  Future<List<SuggestionDraft>> _tagDrafts(
    int ref,
    List<ChunkVector> own,
    List<ChunkVector> all,
  ) async {
    final neighbours = NoteMatcher.strongMatches(
      own,
      all,
      threshold: tagThreshold,
      limit: AiSettings.tagNeighbours,
      exclude: {ref},
    );
    if (neighbours.length < TagSuggester.minNeighbours) return const [];
    final tags = await analysis.tagsOf([ref, ...neighbours.map((n) => n.note)]);
    final candidates = TagSuggester.forNote(
      neighbours: neighbours,
      tagsOf: tags,
      own: tags[ref] ?? const {},
      rejected: {
        ...await analysis.rejectedTags(ref),
        ...await analysis.pendingTags(ref),
      },
      limit: AiSettings.tagsPerNote,
    );
    return [
      for (final c in candidates)
        SuggestionDraft(
          kind: Suggestion.tagKind,
          noteA: ref,
          noteB: c.evidence.note,
          tag: c.tag,
          score: c.score,
          chunkA: c.evidence.ownChunk,
          chunkB: c.evidence.otherChunk,
        ),
    ];
  }

  /// Revisit (product spec §10): when [ref] changed recently, the old note
  /// (untouched for a month) it matches best, if any, is worth another
  /// look. Notes already linked to it or already offered are skipped.
  Future<List<SuggestionDraft>> _revisitDrafts(
    int ref,
    List<ChunkVector> own,
    List<ChunkVector> all,
    Map<int, DateTime> dates,
  ) async {
    final now = _clock();
    final changed = dates[ref];
    if (changed == null ||
        changed.isBefore(now.subtract(AiSettings.recentWindow))) {
      return const [];
    }
    final oldBefore = now.subtract(AiSettings.revisitAfter);
    final old = {
      for (final e in dates.entries)
        if (e.value.isBefore(oldBefore)) e.key,
    };
    if (old.isEmpty) return const [];
    final best = NoteMatcher.strongMatches(
      own,
      all.where((c) => old.contains(c.note)),
      threshold: linkThreshold,
      limit: 1,
      exclude: {
        ref,
        ...await analysis.linkedWith(ref),
        ...await analysis.revisitNotes(),
      },
    );
    return [
      for (final m in best)
        SuggestionDraft(
          kind: Suggestion.resurfaceKind,
          noteA: m.note,
          noteB: ref,
          score: m.score,
          chunkA: m.otherChunk,
          chunkB: m.ownChunk,
        ),
    ];
  }

  /// Notes rejected with [ref] where neither note changed a lot since
  /// (decided 2026-10-04: about a third of the words; product spec §8).
  Future<Set<int>> _stillRejected(int ref) async {
    final rejected = await analysis.rejectedWith(ref);
    final still = <int>{};
    for (final pair in rejected) {
      final own = pair.ownSignature;
      final other = pair.otherSignature;
      if (own == null ||
          other == null ||
          !await _changedALot(ref, own) &&
              !await _changedALot(pair.other, other)) {
        still.add(pair.other);
      }
    }
    return still;
  }

  Future<bool> _changedALot(int ref, Uint8List before) async {
    final body = await analysis.bodyOf(ref) ?? '';
    final now = WordSignature.of(body);
    return WordSignature.similarity(before, now) < AiSettings.sameNoteWords;
  }

  static final _word = RegExp(r'\S+');

  static int _wordCount(String text) => _word.allMatches(text).length;
}
