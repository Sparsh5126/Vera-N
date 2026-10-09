import '../../models/booster_result.dart';
import '../../models/rejection.dart';
import '../../models/suggestion.dart';
import '../../models/suggestion_draft.dart';
import '../../storage/repositories/analysis_repository.dart';
import '../../storage/repositories/booster_repository.dart';
import '../../storage/repositories/rejections_repository.dart';
import '../../storage/repositories/suggestions_repository.dart';
import '../ai_settings.dart';

/// Turns the laptop's results (docs/LAPTOP_PLAN.md, L3) into suggestions,
/// on the phone and on the laptop itself. Only results whose notes are
/// unchanged are used:
/// - a "Why?" sentence goes on the waiting link between the same notes;
/// - new tag names and topics become tag suggestions;
/// - copies become a `duplicate` suggestion.
///
/// Each result is offered once: if it expires or is rejected, it doesn't
/// come back. With no laptop results this does nothing.
class LaptopResultsImport {
  LaptopResultsImport({
    required this.booster,
    required this.suggestions,
    required this.analysis,
    required this.rejections,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final BoosterRepository booster;
  final SuggestionsRepository suggestions;
  final AnalysisRepository analysis;
  final RejectionsRepository rejections;
  final DateTime Function() _clock;

  /// Returns how many new suggestions were offered.
  Future<int> run() async {
    final stamps = await booster.stamps();
    final current = {for (final e in stamps.entries) e.key: e.value.hash};
    final fresh = [
      for (final r in await booster.readAll())
        if (r.found && r.freshIn(current)) r,
    ];
    final imported = await suggestions.importedResults();
    final rejected = await rejections.pairKeys();
    final drafts = <SuggestionDraft>[];
    final offered = <String>[];
    for (final r in fresh) {
      final refs = [for (final n in r.notes) stamps[n.key]!.ref];
      if (r.kind == BoosterKind.why) {
        if (refs.length == 2) {
          await suggestions.setLinkDetail(refs[0], refs[1], r.values.first);
        }
        continue;
      }
      if (imported.contains(r.jobKey)) continue;
      offered.add(r.jobKey);
      drafts.addAll(switch (r.kind) {
        BoosterKind.tags => await _tags(refs.single, r.values, refs.single),
        BoosterKind.topic => await _topic(refs, r.values.first),
        BoosterKind.duplicate => _duplicate(r, refs, rejected),
        BoosterKind.why => const [],
      });
    }
    final now = _clock();
    await suggestions.add(drafts, now, AiSettings.suggestionLifetime);
    await suggestions.markImported(offered, {
      for (final r in fresh) r.jobKey,
    }, now);
    return drafts.length;
  }

  /// Tag suggestions for [ref], leaving out tags it has, tags rejected
  /// for it, and tags already waiting. [reason] is the note shown as why.
  Future<List<SuggestionDraft>> _tags(
    int ref,
    List<String> names,
    int reason,
  ) async {
    final has = {
      for (final t in (await analysis.tagsOf([ref]))[ref] ?? const <String>{})
        t.toLowerCase(),
    };
    final skip = {
      ...has,
      ...await analysis.rejectedTags(ref),
      ...await analysis.pendingTags(ref),
    };
    return [
      for (final name in names)
        if (!skip.contains(name.toLowerCase()))
          SuggestionDraft(
            kind: Suggestion.tagKind,
            noteA: ref,
            noteB: reason,
            tag: name,
            score: 1,
            fromLaptop: true,
            chunkA: 0,
            chunkB: 0,
          ),
    ];
  }

  /// The topic's name as a tag on each of its notes; the reason shown is
  /// another note of the topic.
  Future<List<SuggestionDraft>> _topic(List<int> refs, String name) async {
    final drafts = <SuggestionDraft>[];
    for (var i = 0; i < refs.length; i++) {
      final other = refs[(i + 1) % refs.length];
      drafts.addAll(await _tags(refs[i], [name], other));
    }
    return drafts;
  }

  List<SuggestionDraft> _duplicate(
    BoosterResult r,
    List<int> refs,
    Set<String> rejected,
  ) {
    if (refs.length != 2) return const [];
    final key = Rejection.duplicatePairKey(r.notes[0].key, r.notes[1].key);
    if (rejected.contains(key)) return const [];
    return [
      SuggestionDraft(
        kind: Suggestion.duplicateKind,
        noteA: refs[0] < refs[1] ? refs[0] : refs[1],
        noteB: refs[0] < refs[1] ? refs[1] : refs[0],
        detail: r.values.first,
        score: 1,
        fromLaptop: true,
        chunkA: 0,
        chunkB: 0,
      ),
    ];
  }
}
