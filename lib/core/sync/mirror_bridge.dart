import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../storage/files/note_file_store.dart';
import '../storage/files/sync_conflict.dart';

/// What one bridge run did.
class BridgeReport {
  int toFolder = 0;
  int toMirror = 0;
  int conflicts = 0;

  bool get changedFolder => toFolder > 0 || conflicts > 0;

  @override
  String toString() =>
      'BridgeReport(toFolder: $toFolder, toMirror: $toMirror, '
      'conflicts: $conflicts)';
}

/// The phone's mirror copy (docs/LAPTOP_PLAN.md, S3; user, 2026-10-16):
/// the sync engine shares a private copy inside Vera N, and this copies
/// changes both ways between that copy and the user's own notes folder,
/// so no "All files access" is needed.
///
/// For each file it remembers what each side last had (size and time, or
/// a hash for the small `.app/` files), so unchanged files aren't read.
/// - Changed on one side: copied to the other (a deletion too).
/// - Changed on both: a deletion loses to an edit; for a note, the folder's
///   version is kept and the other is saved beside it as a conflict copy
///   (`x.sync-conflict-<date>-<time>-VERAPHN.md`), which Compare / Keep
///   already handles.
class MirrorBridge {
  MirrorBridge({
    required this.folder,
    required this.mirror,
    required this.stateFile,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final NoteFileStore folder;
  final NoteFileStore mirror;
  final File stateFile;
  final DateTime Function() _clock;

  static const _device = 'VERAPHN';

  Future<BridgeReport> run() async {
    final state = await _readState();
    final report = BridgeReport();
    final f = await _snapshot(folder);
    final m = await _snapshot(mirror);
    for (final key in {...f.keys, ...m.keys, ...state.keys}) {
      final last = state[key] ?? const <String, String?>{};
      final fSig = f[key], mSig = m[key];
      final fChanged = fSig != last['f'];
      final mChanged = mSig != last['m'];
      if (!fChanged && !mChanged) continue;
      if (fChanged && !mChanged) {
        await _copy(key, from: folder, to: mirror, present: fSig != null);
        report.toMirror++;
      } else if (mChanged && !fChanged) {
        await _copy(key, from: mirror, to: folder, present: mSig != null);
        report.toFolder++;
      } else {
        await _both(key, fSig, mSig, report);
      }
      final after = {
        'f': await _sig(folder, key),
        'm': await _sig(mirror, key),
      };
      if (after['f'] == null && after['m'] == null) {
        state.remove(key);
      } else {
        state[key] = after;
      }
    }
    await _writeState(state);
    return report;
  }

  /// Both sides changed since the last run.
  Future<void> _both(
    String key,
    String? fSig,
    String? mSig,
    BridgeReport report,
  ) async {
    if (fSig == null || mSig == null) {
      // A deletion against an edit: the edit is kept on both sides.
      final (from, to) = fSig == null ? (mirror, folder) : (folder, mirror);
      await _copy(key, from: from, to: to, present: true);
      fSig == null ? report.toFolder++ : report.toMirror++;
      return;
    }
    final fBytes = await _read(folder, key);
    final mBytes = await _read(mirror, key);
    if (_equal(fBytes, mBytes)) return;
    if (key.startsWith('n:')) {
      await folder.write(
        SyncConflict.copyPath(key.substring(2), _clock(), _device),
        utf8.decode(mBytes!),
      );
      report.conflicts++;
    }
    await _copy(key, from: folder, to: mirror, present: true);
    report.toMirror++;
  }

  /// Every file on one side, by key: `n:` notes, `a:` attachments, `p:`
  /// app files, with its signature.
  Future<Map<String, String>> _snapshot(NoteFileStore store) async {
    final out = <String, String>{};
    for (final e in await store.listNotes()) {
      out['n:${e.path}'] = _entrySig(e);
    }
    for (final e in await store.listAttachments()) {
      out['a:${e.path}'] = _entrySig(e);
    }
    for (final name in await store.listAppFiles()) {
      final text = await store.readAppFile(name);
      if (text != null) out['p:$name'] = _hash(utf8.encode(text));
    }
    return out;
  }

  Future<String?> _sig(NoteFileStore store, String key) async {
    final name = key.substring(2);
    return switch (key[0]) {
      'n' => (await store.stat(name)).let(_entrySig),
      'a' =>
        (await store.listAttachments())
            .where((e) => e.path == name)
            .firstOrNull
            .let(_entrySig),
      _ => (await store.readAppFile(name))?.let((t) => _hash(utf8.encode(t))),
    };
  }

  Future<Uint8List?> _read(NoteFileStore store, String key) async {
    final name = key.substring(2);
    return switch (key[0]) {
      'n' =>
        await store.exists(name)
            ? Uint8List.fromList(utf8.encode(await store.read(name)))
            : null,
      'a' => await store.readAttachment(name),
      _ => (await store.readAppFile(
        name,
      ))?.let((t) => Uint8List.fromList(utf8.encode(t))),
    };
  }

  Future<void> _copy(
    String key, {
    required NoteFileStore from,
    required NoteFileStore to,
    required bool present,
  }) async {
    final name = key.substring(2);
    final bytes = present ? await _read(from, key) : null;
    switch (key[0]) {
      case 'n':
        bytes == null
            ? await _quietly(() => to.delete(name))
            : await to.write(name, utf8.decode(bytes));
      case 'a':
        bytes == null
            ? await _quietly(() => to.deleteAttachment(name))
            : await to.writeAttachment(name, bytes);
      default:
        // App files are never deleted by sync; an emptied one stays empty.
        await to.writeAppFile(name, bytes == null ? '' : utf8.decode(bytes));
    }
  }

  static Future<void> _quietly(Future<void> Function() action) async {
    try {
      await action();
    } on Object {
      // Already gone.
    }
  }

  static String _entrySig(NoteFileEntry e) =>
      '${e.size}:${e.modified.millisecondsSinceEpoch}';

  static String _hash(List<int> bytes) => sha256.convert(bytes).toString();

  static bool _equal(Uint8List? a, Uint8List? b) {
    if (a == null || b == null) return a == b;
    return _hash(a) == _hash(b);
  }

  Future<Map<String, Map<String, String?>>> _readState() async {
    if (!stateFile.existsSync()) return {};
    try {
      final json = jsonDecode(await stateFile.readAsString()) as Map;
      return {
        for (final e in json.entries)
          e.key as String: (e.value as Map).cast<String, String?>(),
      };
    } on Object {
      return {};
    }
  }

  Future<void> _writeState(Map<String, Map<String, String?>> state) async {
    await stateFile.parent.create(recursive: true);
    await stateFile.writeAsString(jsonEncode(state));
  }
}

extension<T extends Object> on T? {
  R? let<R>(R Function(T) f) {
    final v = this;
    return v == null ? null : f(v);
  }
}
