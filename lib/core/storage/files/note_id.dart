import 'dart:math';

/// Note ids and file names (ARCHITECTURE.md §8).
///
/// Local creation time plus a 4-character random suffix, for example
/// `20261003-153228-a7f3`. The file is `<id>.md` and is never renamed.
abstract final class NoteId {
  static const fileExtension = '.md';
  static final _generated = RegExp(r'^\d{8}-\d{6}-[0-9a-f]{4}$');

  /// A new id for a note created at [createdLocal].
  ///
  /// The caller checks the name is free and draws again if not.
  static String generate(DateTime createdLocal, {Random? random}) {
    final r = random ?? Random.secure();
    final suffix = r.nextInt(0x10000).toRadixString(16).padLeft(4, '0');
    return '${_stamp(createdLocal)}-$suffix';
  }

  /// Whether [id] has the generated form (imported notes may not).
  static bool isGenerated(String id) => _generated.hasMatch(id);

  static String fileName(String id) => '$id$fileExtension';

  static String _stamp(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    final date =
        '${t.year.toString().padLeft(4, '0')}${two(t.month)}'
        '${two(t.day)}';
    return '$date-${two(t.hour)}${two(t.minute)}${two(t.second)}';
  }
}
