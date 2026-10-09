import 'dart:convert';

import 'booster_settings.dart';

/// Reads the model's replies defensively: local models add quotes, labels
/// and chatter, so anything that doesn't fit is dropped, never shown.
abstract final class BoosterReplies {
  static final _label = RegExp(
    r'^(sentence|answer|reply|why|reason)\s*:\s*',
    caseSensitive: false,
  );
  static final _quotes = RegExp('^["“”\'`*]+|["“”\'`*]+\$');
  static final _spaces = RegExp(r'\s+');
  static final _ends = RegExp(r'[.!?।]$');
  static final _array = RegExp(r'\[[\s\S]*?\]');
  static final _notTagChar = RegExp(r'[^\p{L}\p{M}\p{N}-]', unicode: true);
  static final _dashes = RegExp('-{2,}');

  /// One plain sentence from [reply], or null if there is none.
  static String? sentence(String reply) {
    final line = reply
        .split('\n')
        .map((l) => l.trim())
        .firstWhere((l) => l.isNotEmpty, orElse: () => '');
    var s = line
        .replaceFirst(_label, '')
        .replaceAll(_quotes, '')
        .replaceAll(_spaces, ' ')
        .trim();
    if (s.isEmpty) return null;
    if (s.length > BoosterSettings.sentenceMaxChars) {
      final cut = s.substring(0, BoosterSettings.sentenceMaxChars);
      final space = cut.lastIndexOf(' ');
      s = (space > 0 ? cut.substring(0, space) : cut).trim();
    }
    return _ends.hasMatch(s) ? s : '$s.';
  }

  /// Up to two tag names from a JSON array in [reply], each folded into
  /// [known] when it is the same name written differently.
  static List<String> tagNames(String reply, Iterable<String> known) {
    final match = _array.firstMatch(reply);
    if (match == null) return const [];
    Object? list;
    try {
      list = jsonDecode(match.group(0)!);
    } on FormatException {
      return const [];
    }
    if (list is! List) return const [];
    final names = <String>[];
    for (final item in list) {
      final name = item is String ? tagName(item, known) : null;
      if (name != null && !names.contains(name)) names.add(name);
      if (names.length == BoosterSettings.tagsPerNote) break;
    }
    return names;
  }

  /// A topic name from the first line of [reply], or null.
  static String? topicName(String reply, Iterable<String> known) {
    final line = reply.trim().split('\n').first;
    return tagName(line.replaceFirst(_label, ''), known);
  }

  /// Whether [reply] says the notes are copies, and its sentence why.
  static ({bool same, String? why}) duplicate(String reply) {
    final lines = reply
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    if (lines.isEmpty) return (same: false, why: null);
    final first = lines.first.replaceAll(_quotes, '');
    if (!first.toLowerCase().startsWith('yes')) {
      return (same: false, why: null);
    }
    final rest = lines.length > 1
        ? lines.skip(1).join(' ')
        : first.substring(3).replaceFirst(RegExp(r'^[\s,.:-]+'), '');
    return (same: true, why: sentence(rest));
  }

  /// [raw] as a tag: lower case, hyphens between words, letters and
  /// digits only (Devanagari included), 1–3 words. A name that matches
  /// a [known] tag once hyphens and a plural "s" are ignored becomes it.
  static String? tagName(String raw, Iterable<String> known) {
    final name = raw
        .trim()
        .toLowerCase()
        .replaceAll(_quotes, '')
        .replaceFirst(RegExp('^#'), '')
        .replaceAll(RegExp(r'[\s_]+'), '-')
        .replaceAll(_notTagChar, '')
        .replaceAll(_dashes, '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    if (name.length < BoosterSettings.tagMinLength) return null;
    if (name.length > BoosterSettings.tagMaxLength) return null;
    if (name.split('-').length > 3) return null;
    for (final k in known) {
      if (_squash(k) == _squash(name)) return k;
    }
    return name;
  }

  static String _squash(String tag) {
    final s = tag.toLowerCase().replaceAll('-', '');
    return s.length > 3 && s.endsWith('s') ? s.substring(0, s.length - 1) : s;
  }
}
