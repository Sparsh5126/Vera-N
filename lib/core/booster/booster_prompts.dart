import 'booster_settings.dart';

/// The booster's prompts: short, one job each (docs/LAPTOP_PLAN.md, L2).
/// Note text goes only to the local server. Replies keep the notes'
/// language, use plain words, and never speak as an assistant or "Vera".
abstract final class BoosterPrompts {
  static const _voice =
      'Write in the same language as the notes (Hindi, English, or both '
      'mixed, as they are). Use plain everyday words. Do not talk about '
      'yourself, do not greet, do not explain.';

  static const why =
      'Two passages from one person\'s notes were found to be about related '
      'things. Write ONE short sentence (at most 20 words) that says what '
      'they have in common, so the person sees why the notes could be '
      'linked. Describe the notes, for example: "Both plan a spring trek to '
      'Triund." $_voice Reply with the sentence only.';

  static const tags =
      'Suggest up to two short tags for this note: topics a person would '
      'file it under. Each tag is one to three words in lower case, joined '
      'with hyphens, like "trek-planning". Prefer one of the existing tags '
      'when it fits. If no tag fits well, reply with []. $_voice Reply with '
      'a JSON array of strings only.';

  static const topic =
      'These notes from one person are about the same topic. Name the topic '
      'in one to three words, lower case, joined with hyphens, like '
      '"trek-planning". If an existing tag fits, use it. $_voice Reply with '
      'the name only.';

  static const duplicate =
      'Do these two notes say the same thing, so that one is a copy or a '
      'near copy of the other? Notes that are only about the same topic are '
      'NOT copies. First line: YES or NO. Second line, only if YES: one '
      'short sentence on what both contain. $_voice';

  static String passages(String a, String b) =>
      'Passage 1:\n${_cut(a)}\n\nPassage 2:\n${_cut(b)}';

  static String note(String text, List<String> knownTags) =>
      'Existing tags: ${_tagList(knownTags)}\n\nNote:\n${_cut(text)}';

  static String notes(List<String> texts, List<String> knownTags) {
    final each = BoosterSettings.maxNoteChars ~/ texts.length.clamp(1, 8);
    return 'Existing tags: ${_tagList(knownTags)}\n\n'
        '${[for (var i = 0; i < texts.length; i++) 'Note ${i + 1}:\n${_cut(texts[i], each)}'].join('\n\n')}';
  }

  static String pair(String a, String b) =>
      'Note 1:\n${_cut(a)}\n\nNote 2:\n${_cut(b)}';

  static String _tagList(List<String> tags) => tags.isEmpty
      ? '(none)'
      : tags.take(BoosterSettings.knownTagsInPrompt).join(', ');

  static String _cut(String text, [int max = BoosterSettings.maxNoteChars]) =>
      text.length <= max ? text.trim() : '${text.substring(0, max).trim()}…';
}
