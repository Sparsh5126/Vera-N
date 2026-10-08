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
abstract final class NoteChunker {
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
      if (start != null && tokens + piece.tokens > maxTokens) flush();
      start ??= piece.start;
      end = piece.end;
      tokens += piece.tokens;
    }
    flush();
    return chunks;
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
