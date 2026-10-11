import 'package:flutter/foundation.dart';

import 'web_link.dart';

/// Kinds of Markdown the app shows as formatting instead of symbols.
enum MarkupKind { link, bold, checkbox, bullet, numbered, embed, webLink }

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
  /// For embeds: the attachment's file name in `Attachments/`.
  /// For web links: the address.
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

  /// An attachment or a web link: a whole line drawn as one card.
  bool get isBlock => kind == MarkupKind.embed || kind == MarkupKind.webLink;

  /// Checkboxes and bullets are drawn as glyphs, a block as its card;
  /// numbers stay as written.
  bool get hasGlyph =>
      kind == MarkupKind.checkbox || kind == MarkupKind.bullet || isBlock;

  /// The character drawn as a checkbox (the ` `/`x` in `- [ ] `), a
  /// bullet (the `-` in `- `) or an attachment (the `!` of `![](…)`).
  int get glyphAt => kind == MarkupKind.checkbox ? start + 3 : start;

  /// Whether the character at [offset] is a hidden Markdown symbol.
  bool hides(int offset) {
    if (kind == MarkupKind.numbered) return false;
    // A block shows only its card, drawn in place of its first character.
    if (isBlock) {
      return offset > start && offset < end;
    }
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
    // A block is one piece: the cursor sits before or after it.
    if (isBlock) return offset > start && offset < end;
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

  /// An attachment on its own line: `![](Attachments/name.jpg)`, the path
  /// from `MyNotes/` (product spec §3), so other apps find it too.
  static final _embed = RegExp(
    r'^!\[[^\]\n]*\]\(Attachments/([^()\s/\\]+)\)[ \t]*$',
    multiLine: true,
  );

  /// An embed with its line break, so leaving it out leaves no gap.
  static final _embedLine = RegExp(
    r'^!\[[^\]\n]*\]\(Attachments/[^()\s/\\]+\)[ \t]*(\r?\n|$)',
    multiLine: true,
  );

  /// The markup that embeds attachment [name].
  static String embed(String name) => '![](Attachments/$name)';

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
      for (final m in _embed.allMatches(text))
        MarkupSpan(
          kind: MarkupKind.embed,
          start: m.start,
          contentStart: m.end,
          contentEnd: m.end,
          end: m.end,
          target: m.group(1),
        ),
      for (final m in [
        ...WebLink.card.allMatches(text),
        ...WebLink.bare.allMatches(text),
      ])
        MarkupSpan(
          kind: MarkupKind.webLink,
          start: m.start,
          contentStart: m.end,
          contentEnd: m.end,
          end: m.end,
          target: m.group(2) ?? m.group(1),
        ),
    ];
  }

  /// The attachments [text] embeds, in order.
  static List<String> embeds(String text) => [
    for (final m in _embed.allMatches(text)) m.group(1)!,
  ];

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
  /// their titles, bold without `**`, checklists as ☐ / ☑, bullets as •,
  /// and attachments left out (their file names mean nothing to a reader
  /// or to the AI). A web link line shows its title ([WebLink.label]);
  /// with [keepUrls] (copying) its address follows on the next line, so a
  /// copy still has a working link.
  ///
  /// [forScreen] draws checklists as □ / ✓ instead: the app's font (Inter)
  /// has no ☐ / ☑, and Android then falls back to its color emoji, a blue
  /// ☑️ that fights the palette. Text that leaves the screen (copy, the
  /// AI's chunks) keeps ☐ / ☑, so copies and analysis are unchanged.
  static String display(
    String text, {
    bool forScreen = false,
    bool keepUrls = false,
  }) {
    final open = forScreen ? '□ ' : '☐ ';
    final done = forScreen ? '✓ ' : '☑ ';
    String webLink(Match m) {
      final link = WebLink.parse(m[0]!)!;
      if (!keepUrls) return link.label;
      return link.title == null ? link.url : '${link.title}\n${link.url}';
    }

    return text
        .replaceAll(_embedLine, '')
        .replaceAllMapped(WebLink.card, webLink)
        .replaceAllMapped(WebLink.bare, webLink)
        .replaceAllMapped(_link, (m) {
          final label = m.group(2)?.trim();
          return label == null || label.isEmpty ? m.group(1)!.trim() : label;
        })
        .replaceAllMapped(_bold, (m) => m.group(1)!)
        .replaceAllMapped(_checkbox, (m) => m.group(1) == ' ' ? open : done)
        .replaceAll(_bullet, '• ');
  }
}
