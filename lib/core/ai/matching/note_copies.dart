import '../../storage/files/note_footer.dart';
import '../ai_settings.dart';

/// Whether two notes are copies of each other (a note duplicated by sync
/// or by hand): they share nearly all their words. Such a pair is offered
/// to merge, never to link a note to its own copy (user, 2026-10-22).
///
/// Exact word sets, not [WordSignature]: only a few strong matches per
/// note are checked, and an estimate from 32 numbers is too coarse this
/// close to 1. The "Linked notes" footer is left out, as in matching.
abstract final class NoteCopies {
  static final _word = RegExp(r'[\p{L}\p{N}]+', unicode: true);

  static bool alike(String a, String b) {
    final x = _words(a);
    final y = _words(b);
    if (x.isEmpty || y.isEmpty) return false;
    final shared = x.intersection(y).length;
    final all = x.length + y.length - shared;
    return shared / all >= AiSettings.copyWords;
  }

  static Set<String> _words(String body) => {
    for (final m in _word.allMatches(NoteFooter.strip(body).toLowerCase()))
      m.group(0)!,
  };
}
