import '../ai_settings.dart';
import '../../storage/files/note_markup.dart';

/// A piece of a note's text the model reads at once.
class TextChunk {
  const TextChunk(this.start, this.end, this.text);

  /// Where the piece sits in the note's text (Markdown included).
  final int start;
  final int end;

  /// The piece as a reader sees it (no Markdown symbols): what is embedded.
  final String text;
}

/// Splits a note into chunks of at most `maxTokens` tokens, along sentence
/// and line ends, so each chunk is one or more whole sentences where
/// possible (product spec §4: chunk-level embeddings, needed for "why").
///
/// A new chunk also starts at each new line, so a long note's chunks each
/// stay on one subject: packed across lines, their meaning blurred and
/// long notes found almost no matches (measured 2026-10-15: 4 of 13
/// related pairs found, 10 of 13 split by line or paragraph, no unrelated
/// pair over the bar either way). On a phone a thought often ends with one
/// Enter, not a blank line, so every line counts.
/// - The lines of a list (bullets, checkboxes, numbers) stay together: a
///   list is one subject, and single items would match by chance.
/// - A title of four words or more is a chunk of its own, which helps: it
///   says what the note is about. Shorter text ("Tuesday") has too little
///   meaning to judge, as with whole notes ([AiSettings.minWords]), and
///   stays with the next line.
abstract final class NoteChunker {
  /// Bumped whenever chunks are cut differently, so every note is
  /// analysed again (it is part of the analysis model id).
  static const version = 2;

  static final _listItem = RegExp(r'^[ \t]*(- |\* |\+ |• |\d{1,9}[.)] )');

  /// A sentence or line: text up to and including `.`, `!`, `?`, `।` or a
  /// line end.
  static final _sentence = RegExp(r'[^\n.!?।]+[.!?।]*');
  static final _word = RegExp(r'\S+');

  static List<TextChunk> split(
    String body,
    int Function(String text) countTokens, {
    required int maxTokens,
  }) {
    final chunks = <TextChunk>[];
    int? start;
    var end = 0;
    var tokens = 0;

    void flush() {
      if (start == null) return;
      final text = NoteMarkup.display(body.substring(start!, end)).trim();
      if (text.isNotEmpty) chunks.add(TextChunk(start!, end, text));
      start = null;
      tokens = 0;
    }

    for (final piece in _pieces(body, countTokens, maxTokens)) {
      final newLine =
          start != null &&
          _word.allMatches(body.substring(start!, end)).length >=
              AiSettings.minWords &&
          _breakBetween(body, end, piece.start);
      if (start != null && (newLine || tokens + piece.tokens > maxTokens)) {
        flush();
      }
      start ??= piece.start;
      end = piece.end;
      tokens += piece.tokens;
    }
    flush();
    return chunks;
  }

  /// Whether text ending at [end] and text starting at [next] belong in
  /// different chunks: a line break between them, unless both lines are
  /// items of one list (no blank line between).
  static bool _breakBetween(String body, int end, int next) {
    final gap = body.substring(end, next);
    if (!gap.contains('\n')) return false;
    if (RegExp(r'\n[ \t]*\n').hasMatch(gap)) return true;
    return !(_listItem.hasMatch(_lineAt(body, end - 1)) &&
        _listItem.hasMatch(_lineAt(body, next)));
  }

  static String _lineAt(String body, int i) {
    final from = body.lastIndexOf('\n', i < 0 ? 0 : i) + 1;
    final to = body.indexOf('\n', from);
    return body.substring(from, to < 0 ? body.length : to);
  }

  /// Sentences, with any sentence longer than [maxTokens] cut at words.
  static Iterable<_Piece> _pieces(
    String body,
    int Function(String) countTokens,
    int maxTokens,
  ) sync* {
    for (final m in _sentence.allMatches(body)) {
      final text = NoteMarkup.display(m.group(0)!);
      if (text.trim().isEmpty) continue;
      final tokens = countTokens(text);
      if (tokens <= maxTokens) {
        yield _Piece(m.start, m.end, tokens);
        continue;
      }
      for (final w in _word.allMatches(m.group(0)!)) {
        final t = countTokens(NoteMarkup.display(w.group(0)!));
        yield _Piece(m.start + w.start, m.start + w.end, t);
      }
    }
  }
}

class _Piece {
  const _Piece(this.start, this.end, this.tokens);
  final int start;
  final int end;
  final int tokens;
}
