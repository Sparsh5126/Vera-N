import 'package:characters/characters.dart';
import 'package:flutter/foundation.dart';

/// One `[[link]]` found in a note's text.
@immutable
class ParsedLink {
  const ParsedLink(this.targetKey, this.label);

  /// The target as a lookup key: lower case, `/`-separated, no `.md`,
  /// no `#heading` or `^block` part. Either a file name or a path.
  final String targetKey;

  /// The text after `|`, if any.
  final String? label;
}

/// Reading and writing Obsidian-style links: `[[name]]`, `[[name|text]]`,
/// `[[folder/name]]`, and embeds `![[name]]`. Links point at file names
/// (ARCHITECTURE.md §8), adding the folder path only when ambiguous.
abstract final class NoteLinks {
  /// Longest title written into a link; a note's title is its whole first
  /// line, which can be a long sentence.
  static const labelMaxLength = 40;

  static final _link = RegExp(r'\[\[([^\[\]|]+?)(?:\|([^\[\]]*))?\]\]');

  /// Every link in [body], in order, without repeats of the same target.
  static List<ParsedLink> parse(String body) {
    final seen = <String>{};
    final links = <ParsedLink>[];
    for (final m in _link.allMatches(body)) {
      final key = targetKey(m.group(1)!);
      if (key == null || !seen.add(key)) continue;
      final label = m.group(2)?.trim();
      links.add(ParsedLink(key, label == null || label.isEmpty ? null : label));
    }
    return links;
  }

  /// [text] as a reader sees it: `[[name|Title]]` becomes `Title`, and
  /// `[[name]]` becomes `name`. For cards, search results and titles;
  /// the note itself keeps the full links.
  static String displayText(String text) => text.replaceAllMapped(_link, (m) {
    final label = m.group(2)?.trim();
    return label == null || label.isEmpty ? m.group(1)!.trim() : label;
  });

  /// Lookup key for a link target; null if nothing is left.
  static String? targetKey(String target) {
    var t = target.split(RegExp('[#^]')).first.trim().replaceAll(r'\', '/');
    if (t.toLowerCase().endsWith('.md')) t = t.substring(0, t.length - 3);
    t = t.replaceAll(RegExp('^/+|/+\$'), '');
    return t.isEmpty ? null : t.toLowerCase();
  }

  /// Lookup key for a note's file name: `Ideas/A b.md` → `a b`.
  static String nameKey(String path) {
    final name = path.split('/').last;
    final stem = name.toLowerCase().endsWith('.md')
        ? name.substring(0, name.length - 3)
        : name;
    return stem.toLowerCase();
  }

  /// The link text to write for a note at [path] shown as [title]:
  /// `[[name|Title]]`, or `[[folder/name|Title]]` when [ambiguous].
  static String write(String path, String title, {required bool ambiguous}) {
    final noExt = path.toLowerCase().endsWith('.md')
        ? path.substring(0, path.length - 3)
        : path;
    final target = ambiguous ? noExt : noExt.split('/').last;
    var shown = title
        .replaceAll('|', '-')
        .replaceAll(RegExp(r'[\[\]]'), '')
        .trim()
        .characters;
    if (shown.length > labelMaxLength) {
      shown = '${shown.take(labelMaxLength - 1).toString().trimRight()}…'
          .characters;
    }
    return shown.isEmpty ? '[[$target]]' : '[[$target|$shown]]';
  }
}
