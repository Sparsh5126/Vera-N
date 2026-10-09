import 'dart:typed_data';

import '../models/booster_result.dart';
import '../storage/repositories/analysis_repository.dart';
import '../storage/repositories/booster_repository.dart';
import '../storage/repositories/suggestions_repository.dart';
import 'ai_server_client.dart';
import 'booster_prompts.dart';
import 'booster_replies.dart';
import 'booster_settings.dart';
import 'note_groups.dart';

/// One idle run of the laptop booster's four jobs (docs/LAPTOP_PLAN.md,
/// L2): a written "Why?" for waiting links, duplicates, topics, and new
/// tag names, in that order.
///
/// A job is asked once per set of note texts: its result, even "nothing
/// found", is written at once to this device's results file, which is
/// also the record of what is done. A changed note gets new jobs.
class BoosterRun {
  BoosterRun({
    required this.client,
    required this.model,
    required this.booster,
    required this.analysis,
    required this.suggestions,
    required this.deviceId,
    required this.embedderModel,
    required this.stopRequested,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final AiServerClient client;
  final String model;
  final BoosterRepository booster;
  final AnalysisRepository analysis;
  final SuggestionsRepository suggestions;
  final String deviceId;

  /// The on-device embedder's model, whose stored vectors are grouped.
  final String embedderModel;
  final bool Function() stopRequested;
  final DateTime Function() _clock;

  final _byRef = <int, NoteStamp>{};
  final _done = <String>{};
  var _asks = 0;

  bool get _mustStop => stopRequested() || _asks >= BoosterSettings.asksPerRun;

  /// Returns true when no job is left; false when stopped or out of asks.
  Future<bool> run() async {
    final stamps = await booster.stamps();
    await booster.compact(deviceId, {
      for (final e in stamps.entries) e.key: e.value.hash,
    });
    for (final e in stamps.entries) {
      _byRef[e.value.ref] = NoteStamp(e.key, e.value.hash);
    }
    _done.addAll((await booster.readAll()).map((r) => r.jobKey));
    final tags = await _knownTags();
    await _why();
    final meanings = NoteGroups.meanings(
      (await analysis.allChunks(embedderModel))
          .where((c) => _byRef.containsKey(c.note)),
    );
    if (!_mustStop) await _duplicates(meanings);
    if (!_mustStop) await _topics(meanings, tags);
    if (!_mustStop) await _tags(tags);
    return !_mustStop;
  }

  Future<void> _why() async {
    for (final s in await suggestions.pending()) {
      if (_mustStop) return;
      if (!s.isLink) continue;
      final pending = _pending(BoosterKind.why, [s.noteA, s.noteB]);
      if (pending == null) continue;
      final a = await _passage(s.noteA, s.chunkA);
      final b = await _passage(s.noteB, s.chunkB);
      if (a == null || b == null) continue;
      final reply = await _ask(
        BoosterPrompts.why,
        BoosterPrompts.passages(a, b),
      );
      final sentence = BoosterReplies.sentence(reply);
      await _save(pending, [?sentence]);
    }
  }

  Future<void> _duplicates(Map<int, Float32List> meanings) async {
    final lengths = <int, int>{};
    for (final ref in meanings.keys) {
      lengths[ref] = (await analysis.bodyOf(ref))?.length ?? 0;
    }
    final pairs = NoteGroups.duplicateCandidates(meanings, lengths);
    for (final (a, b) in pairs) {
      if (_mustStop) return;
      final pending = _pending(BoosterKind.duplicate, [a, b]);
      if (pending == null) continue;
      final textA = await analysis.bodyOf(a), textB = await analysis.bodyOf(b);
      if (textA == null || textB == null) continue;
      final reply = await _ask(
        BoosterPrompts.duplicate,
        BoosterPrompts.pair(textA, textB),
      );
      final verdict = BoosterReplies.duplicate(reply);
      await _save(pending, verdict.same ? [verdict.why ?? ''] : const []);
    }
  }

  Future<void> _topics(
    Map<int, Float32List> meanings,
    List<String> tags,
  ) async {
    for (final group in NoteGroups.topics(meanings)) {
      if (_mustStop) return;
      final pending = _pending(BoosterKind.topic, group);
      if (pending == null) continue;
      final texts = [for (final ref in group) ?await analysis.bodyOf(ref)];
      final reply = await _ask(
        BoosterPrompts.topic,
        BoosterPrompts.notes(texts, tags),
      );
      await _save(pending, [?BoosterReplies.topicName(reply, tags)]);
    }
  }

  Future<void> _tags(List<String> tags) async {
    final refs = _byRef.keys.toList()..sort();
    for (final ref in refs) {
      if (_mustStop) return;
      final pending = _pending(BoosterKind.tags, [ref]);
      if (pending == null) continue;
      final text = await analysis.bodyOf(ref);
      if (text == null || _words(text) < BoosterSettings.minWordsForTags) {
        continue;
      }
      final reply = await _ask(
        BoosterPrompts.tags,
        BoosterPrompts.note(text, tags),
      );
      final has = (await analysis.tagsOf([ref]))[ref] ?? const {};
      final names = BoosterReplies.tagNames(
        reply,
        tags,
      ).where((t) => !has.contains(t.toLowerCase())).toList();
      await _save(pending, names);
    }
  }

  /// Tags in use, the most used first (they lead the prompt's list).
  Future<List<String>> _knownTags() async {
    final counts = <String, int>{};
    for (final tags in (await analysis.tagsOf(_byRef.keys)).values) {
      for (final t in tags) {
        counts[t] = (counts[t] ?? 0) + 1;
      }
    }
    return counts.keys.toList()
      ..sort((a, b) => counts[b]!.compareTo(counts[a]!));
  }

  /// The job for [refs], unless it is done or a note is off limits.
  BoosterResult? _pending(BoosterKind kind, List<int> refs) {
    final notes = [for (final r in refs) _byRef[r]];
    if (notes.contains(null)) return null;
    final job = BoosterResult(
      kind: kind,
      notes: notes.cast(),
      values: const [],
      model: model,
      madeAt: _clock(),
      deviceId: deviceId,
    );
    return _done.contains(job.jobKey) ? null : job;
  }

  Future<String> _ask(String system, String user) {
    _asks++;
    return client.chat(model: model, system: system, user: user);
  }

  Future<void> _save(BoosterResult job, List<String> values) async {
    final result = BoosterResult(
      kind: job.kind,
      notes: job.notes,
      values: values,
      model: model,
      madeAt: _clock(),
      deviceId: deviceId,
    );
    await booster.add(deviceId, [result]);
    _done.add(result.jobKey);
  }

  Future<String?> _passage(int ref, int chunk) async {
    final body = await analysis.bodyOf(ref);
    final range = await analysis.chunkRange(ref, chunk);
    if (body == null || range == null) return body;
    final (start, end) = range;
    if (start < 0 || end > body.length || start >= end) return body;
    return body.substring(start, end);
  }

  static int _words(String text) =>
      text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
}
