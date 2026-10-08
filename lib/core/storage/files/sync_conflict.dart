/// Syncthing's conflict copies (docs/LAPTOP_PLAN.md, L0). When a note was
/// changed on two devices, Syncthing keeps one version as `x.md` and the
/// other beside it as `x.sync-conflict-20261009-101500-ABCDEF1.md`.
///
/// Such a copy is never a note of its own: it is the other version of
/// `x.md`, settled with Compare / Keep this / Keep the other / Keep both,
/// then removed. It stays on disk until then, so the conflict is found
/// again on every scan, with nothing extra stored.
abstract final class SyncConflict {
  static final _name = RegExp(
    r'^(.*)\.sync-conflict-\d{8}-\d{6}-[A-Za-z0-9]{7}(\.md)$',
  );

  static bool isCopy(String path) => _name.hasMatch(path);

  /// The note [path] is a conflict copy of, or null if it is none.
  static String? originalOf(String path) {
    final m = _name.firstMatch(path);
    return m == null ? null : '${m.group(1)}${m.group(2)}';
  }
}
