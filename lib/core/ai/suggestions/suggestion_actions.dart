import 'package:flutter/foundation.dart';

import '../../models/note.dart';
import '../../models/rejection.dart';
import '../../models/suggestion.dart';
import '../../storage/files/note_footer.dart';
import '../../storage/files/note_text.dart';
import '../../storage/repositories/links_repository.dart';
import '../../storage/repositories/notes_repository.dart';
import '../../storage/repositories/rejections_repository.dart';
import '../../storage/repositories/settings_repository.dart';
import '../../storage/repositories/suggestions_repository.dart';
import '../matching/word_signature.dart';
import '../ai_settings.dart';
import 'duplicate_actions.dart';
import 'suggestion_learning.dart';

/// Undoes the choice just made.
typedef Undo = Future<void> Function();

/// What the user can do with a suggestion, the same from the Review screen
/// and the note's suggestion sheet (UI spec §8). Each returns an [Undo].
class SuggestionActions {
  SuggestionActions({
    required this.notes,
    required this.links,
    required this.suggestions,
    required this.rejections,
    required this.settings,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final NotesRepository notes;
  final LinksRepository links;
  final SuggestionsRepository suggestions;
  final RejectionsRepository rejections;
  final SettingsRepository settings;
  final DateTime Function() _clock;

  /// Merge, Remove one and "not copies" for the laptop's duplicates.
  late final duplicates = DuplicateActions(
    notes: notes,
    suggestions: suggestions,
    rejections: rejections,
    settings: settings,
    clock: _clock,
  );

  /// Links the two notes: the newer note gets a link to the older one in
  /// its "Linked notes" footer (only added to, never rewritten).
  /// For copies, accepting is Merge (see [DuplicateActions.merge]).
  Future<Undo> accept(Suggestion s) async {
    if (s.isTag) return _acceptTag(s);
    if (s.isDuplicate) return duplicates.merge(s);
    final pair = await _notes(s);
    if (pair == null) return _removeOnly(s);
    final (newer, older) = pair.$1.created.isAfter(pair.$2.created)
        ? pair
        : (pair.$2, pair.$1);
    final link = await links.linkTextFor(older.ref);
    if (link == null) return _removeOnly(s);
    final linked = NoteFooter.append(newer.body, link);
    await notes.updateBody(newer.ref, linked);
    await suggestions.remove(s.id);
    final unlearn = await _learn(s, accepted: true);
    return () async {
      await unlearn();
      // Only if the note wasn't edited since: undo never touches the
      // user's own words.
      final now = await notes.getNote(newer.ref);
      if (now?.body == linked) await notes.updateBody(newer.ref, newer.body);
      await suggestions.putBack(s);
    };
  }

  /// Remembers the pair so it isn't suggested again (product spec §8).
  /// For copies: "these aren't copies".
  Future<Undo> reject(Suggestion s) async {
    if (s.isTag) return _rejectTag(s);
    if (s.isDuplicate) return duplicates.notCopies(s);
    final pair = await _notes(s);
    if (pair == null) return _removeOnly(s);
    final idA = await notes.ensureId(s.noteA);
    final idB = await notes.ensureId(s.noteB);
    if (idA == null || idB == null) return _removeOnly(s);
    final deviceId = await settings.deviceId();
    final rejection = _rejection(
      (idA, pair.$1.body),
      (idB, pair.$2.body),
      deviceId,
    );
    await rejections.add(rejection);
    await suggestions.remove(s.id);
    final unlearn = await _learn(s, accepted: false);
    return () async {
      await unlearn();
      await rejections.remove(rejection.pairKey, deviceId);
      await suggestions.putBack(s);
    };
  }

  /// Counts the decision toward the kind's match bar (product spec §8);
  /// returns its undo. The laptop's suggestions never passed this
  /// device's bar, so they don't move it.
  Future<Undo> _learn(Suggestion s, {required bool accepted}) async {
    if (s.fromLaptop) return () async {};
    final kind = s.kind;
    final learned = await settings.learning(kind);
    await settings.saveLearning(
      kind,
      SuggestionLearning.record(
        learned,
        accepted,
        base: SuggestionLearning.baseFor(kind),
      ),
    );
    return () async => settings.saveLearning(
      kind,
      SuggestionLearning.undoLast(await settings.learning(kind)),
    );
  }

  /// A tag suggestion accepted: the tag joins the note's tags (an
  /// addition, approved; product spec §11). Undo removes it again unless
  /// the tags changed since.
  Future<Undo> _acceptTag(Suggestion s) async {
    final note = await notes.getNote(s.noteA);
    if (note == null) return _removeOnly(s);
    final before = note.tags;
    final after = [...before, s.tag];
    await notes.setTags(s.noteA, after);
    await suggestions.remove(s.id);
    final unlearn = await _learn(s, accepted: true);
    return () async {
      await unlearn();
      final now = await notes.getNote(s.noteA);
      if (now != null && listEquals(now.tags, after)) {
        await notes.setTags(s.noteA, before);
      }
      await suggestions.putBack(s);
    };
  }

  /// A tag suggestion rejected: remembered as the pair (note id, `#tag`)
  /// in the same rejections file, so it isn't suggested again.
  Future<Undo> _rejectTag(Suggestion s) async {
    final note = await notes.getNote(s.noteA);
    final id = note == null ? null : await notes.ensureId(s.noteA);
    if (note == null || id == null) return _removeOnly(s);
    final deviceId = await settings.deviceId();
    final tagSide = Rejection.tagSide(s.tag);
    final noteFirst = id.compareTo(tagSide) < 0;
    final noteHash = NoteText.contentHash(note.body);
    final tagHash = s.tag.toLowerCase();
    final rejection = Rejection(
      noteA: noteFirst ? id : tagSide,
      hashA: noteFirst ? noteHash : tagHash,
      noteB: noteFirst ? tagSide : id,
      hashB: noteFirst ? tagHash : noteHash,
      rejectedAt: _clock(),
      deviceId: deviceId,
    );
    await rejections.add(rejection);
    await suggestions.remove(s.id);
    final unlearn = await _learn(s, accepted: false);
    return () async {
      await unlearn();
      await rejections.remove(rejection.pairKey, deviceId);
      await suggestions.putBack(s);
    };
  }

  /// A revisit was opened: it has done its job and leaves the list.
  Future<void> revisited(Suggestion s) => suggestions.remove(s.id);

  /// "Not now" on a revisit: hidden for a month (then it may come back if
  /// still relevant). Undo shows it again.
  Future<Undo> putOff(Suggestion s) async {
    await suggestions.snooze(s.id, _clock().add(AiSettings.revisitAfter));
    return () => suggestions.putBack(s);
  }

  /// Keeps it dimmed; it comes back in a later batch until it expires.
  Future<Undo> notSure(Suggestion s) async {
    await suggestions.setNotSure(s.id, notSure: true);
    return () => suggestions.setNotSure(s.id, notSure: s.notSure);
  }

  Rejection _rejection(
    (String, String) a,
    (String, String) b,
    String deviceId,
  ) {
    final (first, second) = a.$1.compareTo(b.$1) < 0 ? (a, b) : (b, a);
    return Rejection(
      noteA: first.$1,
      hashA: NoteText.contentHash(first.$2),
      signatureA: WordSignature.of(first.$2),
      noteB: second.$1,
      hashB: NoteText.contentHash(second.$2),
      signatureB: WordSignature.of(second.$2),
      rejectedAt: _clock(),
      deviceId: deviceId,
    );
  }

  Future<(Note, Note)?> _notes(Suggestion s) async {
    final a = await notes.getNote(s.noteA);
    final b = await notes.getNote(s.noteB);
    return a == null || b == null ? null : (a, b);
  }

  /// A note of the pair is gone: the suggestion just goes away.
  Future<Undo> _removeOnly(Suggestion s) async {
    await suggestions.remove(s.id);
    return () => suggestions.putBack(s);
  }
}
