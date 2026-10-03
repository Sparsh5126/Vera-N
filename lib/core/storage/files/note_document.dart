import 'package:flutter/foundation.dart';

/// A note file split into its header block and its body.
///
/// The header lines are kept exactly as written, including fields this app
/// doesn't know, so files from Obsidian or other apps are never damaged.
/// `parse` followed by `serialize` returns the original text unchanged.
@immutable
class NoteDocument {
  const NoteDocument({
    required this.headerLines,
    required this.body,
    this.newline = '\n',
  });

  /// Lines between the `---` fences, or null when the file has no header.
  final List<String>? headerLines;

  /// Everything after the header, exactly as in the file.
  final String body;

  /// Line ending used by the header, so rewrites keep the file's style.
  final String newline;

  bool get hasHeader => headerLines != null;

  static const _fence = '---';

  factory NoteDocument.parse(String text) {
    final newline = text.contains('\r\n') ? '\r\n' : '\n';
    if (!text.startsWith('$_fence$newline')) {
      return NoteDocument(headerLines: null, body: text, newline: newline);
    }
    final lines = <String>[];
    var offset = _fence.length + newline.length;
    while (offset <= text.length) {
      final end = text.indexOf(newline, offset);
      final line = end == -1
          ? text.substring(offset)
          : text.substring(offset, end);
      final next = end == -1 ? text.length : end + newline.length;
      if (line == _fence) {
        return NoteDocument(
          headerLines: lines,
          body: text.substring(next),
          newline: newline,
        );
      }
      if (end == -1) break;
      lines.add(line);
      offset = next;
    }
    // No closing fence: not a header, so the whole file is the body.
    return NoteDocument(headerLines: null, body: text, newline: newline);
  }

  String serialize() {
    final header = headerLines;
    if (header == null) return body;
    final inner = header.map((l) => '$l$newline').join();
    return '$_fence$newline$inner$_fence$newline$body';
  }

  NoteDocument withHeaderLines(List<String> lines) =>
      NoteDocument(headerLines: lines, body: body, newline: newline);

  NoteDocument withBody(String newBody) =>
      NoteDocument(headerLines: headerLines, body: newBody, newline: newline);
}
