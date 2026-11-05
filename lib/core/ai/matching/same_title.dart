import '../../storage/files/note_markup.dart';

/// Notes with the same title (user, 2026-11-05: two notes named "Quotes"
/// were never suggested). Their content may say nothing alike, so the
/// title alone is offered as a link, outside the learned match bar.
abstract final class SameTitle {
  /// [title] as compared: as shown, trimmed, case ignored.
  static String key(String title) =>
      NoteMarkup.display(title).trim().toLowerCase();

  /// Whether two titles are the same (an empty title never is).
  static bool alike(String a, String b) {
    final k = key(a);
    return k.isNotEmpty && k == key(b);
  }

  /// Notes grouped by title [key], from note id to title, leaving out
  /// untitled notes and titles only one note has.
  static Map<String, List<int>> groups(Map<int, String> titles) {
    final byKey = <String, List<int>>{};
    for (final MapEntry(:key, :value) in titles.entries) {
      final k = SameTitle.key(value);
      if (k.isNotEmpty) (byKey[k] ??= []).add(key);
    }
    return byKey..removeWhere((_, notes) => notes.length < 2);
  }

  /// The other notes in [groups] titled as [ref].
  static List<int> notesLike(int ref, Map<String, List<int>> groups) {
    for (final notes in groups.values) {
      if (notes.contains(ref)) return [...notes]..remove(ref);
    }
    return const [];
  }
}
