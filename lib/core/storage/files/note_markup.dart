import 'package:flutter/foundation.dart';

/// Kinds of Markdown the app shows as formatting instead of symbols.
enum MarkupKind { link, bold, checkbox, bullet, numbered }

/// One piece of Markdown in a note's text. The file keeps the Markdown; the
/// editor shows [contentStart]..[contentEnd] formatted, hides the symbols,
/// and draws checkboxes and bullets as real ones.
@immutable
class MarkupSpan {
  const MarkupSpan({
    required this.kind,
    required this.start,
    required this.contentStart,
    required this.contentEnd,
    required this.end,
    this.target,
    this.checked = false,
    this.number,
  });

  final MarkupKind kind;
  final int start;
  final int contentStart;
  final int contentEnd;
  final int end;

  /// For links: what the link points at (`name` in `[[name|Title]]`).
  final String? target;

  /// For checkboxes: ticked (`- [x] `).
  final bool checked;

  /// For numbered lines: the number written (`3` in `3. `).
  final int? number;

  /// Checklist, bullet and numbered markers apply to a whole line.
  bool get isLine =>
      kind == MarkupKind.checkbox ||
      kind == MarkupKind.bullet ||
      kind == MarkupKind.numbered;

  /// Checkboxes and bullets are drawn as glyphs; numbers stay as written.
  bool get hasGlyph => kind == MarkupKind.checkbox || kind == MarkupKind.bullet;

  /// The character drawn as a checkbox (the ` `/`x` in `- [ ] `) or a
  /// bullet (the `-` in `- `).
  int get glyphAt => kind == MarkupKind.checkbox ? start + 3 : start;

  /// Whether the character at [offset] is a hidden Markdown symbol.
  bool hides(int offset) {
    if (kind == MarkupKind.numbered) return false;
    if (isLine) {
      // Everything before the content except the glyph and the space
      // that separates it from the text.
      return offset >= start && offset < contentStart - 1 && offset != glyphAt;
    }
    return (offset >= start && offset < contentStart) ||
        (offset >= contentEnd && offset < end);
  }

  /// Whether the cursor may not rest at [offset] (inside hidden symbols,
  /// or before a line's checkbox or bullet).
  bool blocksCaret(int offset) {
    // A number is ordinary visible text the user may edit.
    if (kind == MarkupKind.numbered) return false;
    if (isLine) return offset >= start && offset < contentStart;
    return (offset > start && offset < contentStart) ||
        (offset > contentEnd && offset < end);
  }
}

/// Finds the Markdown the app formats. Results for the last few texts are
/// kept, since the editor asks about the same text several times per
/// keystroke.
abstract final class NoteMarkup {
  static final _link = RegExp(r'\[\[([^\[\]|\n]+?)(?:\|([^\[\]\n]*))?\]\]');
  static final _bold = RegExp(r'\*\*(?=[^\s*])([^\n]*?[^\s*])\*\*');
  static final _checkbox = RegExp(r'^- \[([ xX])\] ', multiLine: true);
  static final _bullet = RegExp(r'^- (?!\[[ xX]\] )', multiLine: true);
  static final _numbered = RegExp(r'^(\d{1,9})\. ', multiLine: true);

  static const _cacheSize = 3;
  static final _cache = <String, List<MarkupSpan>>{};

  static List<MarkupSpan> find(String text) {
    final cached = _cache[text];
    if (cached != null) return cached;
    final spans = _scan(text)..sort((a, b) => a.start.compareTo(b.start));
    if (_cache.length >= _cacheSize) _cache.remove(_cache.keys.first);
    _cache[text] = spans;
    return spans;
  }

  static List<MarkupSpan> _scan(String text) {
    int lineEnd(int from) {
      final i = text.indexOf('\n', from);
      return i == -1 ? text.length : i;
    }

    return [
      for (final m in _link.allMatches(text)) _linkSpan(m),
      for (final m in _bold.allMatches(text))
        MarkupSpan(
          kind: MarkupKind.bold,
          start: m.start,
          contentStart: m.start + 2,
          contentEnd: m.end - 2,
          end: m.end,
        ),
      for (final m in _checkbox.allMatches(text))
        MarkupSpan(
          kind: MarkupKind.checkbox,
          start: m.start,
          contentStart: m.end,
          contentEnd: lineEnd(m.end),
          end: lineEnd(m.end),
          checked: m.group(1) != ' ',
        ),
      for (final m in _bullet.allMatches(text))
        MarkupSpan(
          kind: MarkupKind.bullet,
          start: m.start,
          contentStart: m.end,
          contentEnd: lineEnd(m.end),
          end: lineEnd(m.end),
        ),
      for (final m in _numbered.allMatches(text))
        MarkupSpan(
          kind: MarkupKind.numbered,
          start: m.start,
          contentStart: m.end,
          contentEnd: lineEnd(m.end),
          end: lineEnd(m.end),
          number: int.parse(m.group(1)!),
        ),
    ];
  }

  static MarkupSpan _linkSpan(RegExpMatch m) {
    final target = m.group(1)!;
    final hasLabel = m.group(2)?.trim().isNotEmpty ?? false;
    return MarkupSpan(
      kind: MarkupKind.link,
      start: m.start,
      contentStart: hasLabel ? m.start + 3 + target.length : m.start + 2,
      contentEnd: m.end - 2,
      end: m.end,
      target: target,
    );
  }

  /// [text] as a reader sees it, for cards and search results: links as
  /// their titles, bold without `**`, checklists as ☐ / ☑, bullets as •.
  static String display(String text) {
    return text
        .replaceAllMapped(_link, (m) {
          final label = m.group(2)?.trim();
          return label == null || label.isEmpty ? m.group(1)!.trim() : label;
        })
        .replaceAllMapped(_bold, (m) => m.group(1)!)
        .replaceAllMapped(_checkbox, (m) => m.group(1) == ' ' ? '☐ ' : '☑ ')
        .replaceAll(_bullet, '• ');
  }
}
