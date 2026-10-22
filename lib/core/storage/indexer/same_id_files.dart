import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../db/note_rows.dart';
import '../files/note_file_store.dart';
import '../files/note_merge.dart';
import '../files/sync_conflict.dart';

/// One note id, one file (user, 2026-10-22). A note moved while another
/// device had no record of it, for example re-pairing after a reinstall,
/// comes back at its old path too: sync joins both folders, so the same
/// note sat in two places and showed as two notes.
///
/// After each scan, the copy this device already had stays the note (the
/// one being edited, else the one indexed first: where the user last put
/// it here). The other file goes; if it holds anything the kept note
/// lacks, it is first saved beside the kept note as a conflict copy, for
/// Compare / Keep. Nothing is lost.
///
/// Only the phone runs this: file times differ between devices, so two
/// devices could keep opposite copies and remove both. The laptop follows
/// what sync brings.
class SameIdFiles {
  SameIdFiles(this._db, this._store, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final NoteFileStore _store;
  final DateTime Function() _clock;

  /// Marks the conflict copies this makes (7 letters, like a device's).
  static const device = 'VERAIDS';

  /// Returns how many extra files were settled.
  Future<int> settle() async {
    var settled = 0;
    for (final group in await _groups()) {
      final pending = group.where((r) => r.pendingWrite).toList();
      // Edits waiting in two copies: settle once they are written.
      if (pending.length > 1) continue;
      final keep = pending.firstOrNull ?? group.first;
      for (final other in group) {
        if (other.id == keep.id) continue;
        await _settle(keep, other);
        settled++;
      }
    }
    return settled;
  }

  /// Live notes on disk that share an id with another, oldest row first.
  Future<List<List<NoteRow>>> _groups() async {
    final rows =
        await (_db.select(_db.notes)
              ..where(
                (n) =>
                    n.trashedAt.isNull() &
                    n.noteId.isNotNull() &
                    n.fileModifiedMs.isNotNull(),
              )
              ..orderBy([(n) => OrderingTerm(expression: n.id)]))
            .get();
    final byId = <String, List<NoteRow>>{};
    for (final r in rows) {
      byId.putIfAbsent(r.noteId!, () => []).add(r);
    }
    return [
      for (final g in byId.values)
        if (g.length > 1) g,
    ];
  }

  Future<void> _settle(NoteRow keep, NoteRow other) async {
    if (!_covers(keep, other)) {
      final text = await _store.read(other.path);
      await _store.write(
        SyncConflict.copyPath(keep.path, _clock(), device),
        text,
      );
      await (_db.update(_db.notes)..where((n) => n.id.equals(keep.id))).write(
        const NotesCompanion(conflict: Value(true)),
      );
    }
    await _store.delete(other.path);
    await (_db.delete(_db.notes)..where((n) => n.id.equals(other.id))).go();
  }

  /// Every line and tag of [other] is already in [keep].
  static bool _covers(NoteRow keep, NoteRow other) {
    final merged = NoteMerge.merge(keep.body, other.body);
    final keepTags = NoteRows.tagsOf(keep.headerRaw).map(_lower).toSet();
    return merged.trimRight() == keep.body.trimRight() &&
        NoteRows.tagsOf(other.headerRaw).map(_lower).every(keepTags.contains);
  }

  static String _lower(String s) => s.toLowerCase();
}
