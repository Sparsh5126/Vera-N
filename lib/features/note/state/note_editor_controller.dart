import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/storage/repositories/notes_repository.dart';
import '../../../core/utils/names.dart';
import '../../../core/utils/timings.dart';

/// Autosave for the note editor. There is no save button: text is saved
/// to the database a moment after typing stops, and when leaving.
///
/// A new note is only created once it has some text, so opening "New
/// note" and backing out leaves nothing behind.
class NoteEditorController {
  NoteEditorController(this._repo, {int? ref}) : noteRef = ValueNotifier(ref);

  final NotesRepository _repo;

  /// The note being edited; null until a new note is first saved.
  final ValueNotifier<int?> noteRef;

  /// Goes up after every save, to show the "saved" tick.
  final ValueNotifier<int> saves = ValueNotifier(0);

  Timer? _timer;
  String? _pending;
  Future<void> _queue = Future.value();
  bool _disposed = false;

  void onTextChanged(String text) {
    _pending = text;
    _timer?.cancel();
    _timer = Timer(AppTimings.saveAfterTyping, () => unawaited(save()));
  }

  /// Saves any unsaved text now. Saves run one after another.
  Future<void> save() {
    _timer?.cancel();
    final text = _pending;
    _pending = null;
    if (text == null) return _queue;
    return _queue = _queue.then((_) => _persist(text));
  }

  Future<void> setPinned(bool pinned) async {
    await save();
    final ref = noteRef.value;
    if (ref != null) await _repo.setPinned(ref, pinned);
  }

  /// Adds a tag the user typed or picked. Returns false if nothing usable.
  Future<bool> addTag(String input, List<String> current) async {
    final tag = Names.tag(input);
    final ref = noteRef.value;
    if (tag == null || ref == null) return false;
    final exists = current.any((t) => t.toLowerCase() == tag.toLowerCase());
    if (!exists) await _repo.setTags(ref, [...current, tag]);
    return true;
  }

  Future<void> removeTag(String tag, List<String> current) async {
    final ref = noteRef.value;
    if (ref == null) return;
    await _repo.setTags(ref, [
      for (final t in current)
        if (t != tag) t,
    ]);
  }

  Future<void> setTags(List<String> tags) async {
    final ref = noteRef.value;
    if (ref != null) await _repo.setTags(ref, tags);
  }

  /// Moves the note to [folder] (`''` is no folder). Returns the folder it
  /// was in, for undo; null if nothing moved.
  Future<String?> moveToFolder(String folder) async {
    await save();
    final ref = noteRef.value;
    if (ref == null) return null;
    return _repo.moveToFolder(ref, folder);
  }

  /// Moves the note to the trash. Returns its ref for undo, or null if
  /// the note was never saved.
  Future<int?> trash() async {
    _pending = null;
    await save();
    final ref = noteRef.value;
    if (ref != null) await _repo.trash(ref);
    return ref;
  }

  /// Saves what's left, then releases the notifiers.
  Future<void> dispose() async {
    await save();
    _disposed = true;
    noteRef.dispose();
    saves.dispose();
  }

  Future<void> _persist(String text) async {
    final ref = noteRef.value;
    if (ref == null) {
      if (text.trim().isEmpty) return;
      final created = await _repo.create(text);
      if (!_disposed) noteRef.value = created;
    } else {
      await _repo.updateBody(ref, text);
    }
    if (!_disposed) saves.value++;
  }
}
