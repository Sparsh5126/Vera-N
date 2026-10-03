/// Rules for names the user types: tags and folders.
abstract final class Names {
  /// A tag as stored: no leading `#`, no spaces (Obsidian tags can't hold
  /// them, so they become `-`). Null if nothing usable is left.
  static String? tag(String input) {
    final tag = input
        .trim()
        .replaceFirst(RegExp(r'^#+'), '')
        .replaceAll(RegExp(r'\s+'), '-');
    return tag.isEmpty ? null : tag;
  }

  /// A folder path inside the notes folder, `/`-separated. Null if empty
  /// or not allowed: segments can't be empty, `.`/`..`, start with `.`
  /// (hidden folders are never listed), or hold `\` or `:`.
  static String? folder(String input) {
    final parts = input
        .trim()
        .split('/')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (parts.isEmpty) return null;
    final bad = parts.any(
      (s) => s.startsWith('.') || s.contains(r'\') || s.contains(':'),
    );
    return bad ? null : parts.join('/');
  }
}
