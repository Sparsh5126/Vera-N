import 'package:flutter/foundation.dart';

/// A web link on its own line in a note, shown as a card (product spec §3).
/// The file keeps plain Markdown so other apps read it too:
/// - `[Title](https://…)` or `[Title](https://… "Description")`, as
///   written when a link is shared to the app;
/// - a bare `https://…` line, as pasted or typed.
///
/// Everything here works offline: the title and description come from
/// whatever the sharing app sent, never from fetching the page.
@immutable
class WebLink {
  const WebLink({required this.url, this.title, this.description});

  final String url;
  final String? title;
  final String? description;

  /// `[Title](url "Description")` on its own line, escapes allowed.
  static final card = RegExp(
    r'^\[((?:[^\]\\\n]|\\.)*)\]\((https?://[^\s()]+)'
    r'(?: "((?:[^"\\\n]|\\.)*)")?\)[ \t]*$',
    multiLine: true,
  );

  /// A bare link on its own line.
  static final bare = RegExp(r'^(https?://\S+)[ \t]*$', multiLine: true);

  static final _anyUrl = RegExp(r'https?://[^\s<>"]+');
  static final _escaped = RegExp(r'\\(.)');
  static final _slugWord = RegExp(r'[-_+]+');
  static final _hasLetters = RegExp(r'[a-zA-Zऀ-ॿ]{2,}');
  static final _digits = RegExp(r'\d');

  /// The link written on [line] (a whole line), or null if it isn't one.
  static WebLink? parse(String line) {
    final m = card.firstMatch(line);
    if (m != null) {
      return WebLink(
        url: m.group(2)!,
        title: _clean(_unescape(m.group(1)!)),
        description: _clean(_unescape(m.group(3) ?? '')),
      );
    }
    final b = bare.firstMatch(line);
    return b == null ? null : WebLink(url: b.group(1)!);
  }

  /// The first web address in [text], without trailing punctuation.
  static String? findUrl(String text) {
    final raw = _anyUrl.firstMatch(text)?.group(0);
    return raw?.replaceFirst(RegExp(r'[.,;:!?)\]]+$'), '');
  }

  /// The site, e.g. "youtube.com" for https://www.youtube.com/watch….
  String get site {
    final host = Uri.tryParse(url)?.host ?? '';
    final shown = host.replaceFirst(RegExp(r'^(www|m|mobile)\.'), '');
    return shown.isEmpty ? url : shown;
  }

  /// What a reader sees: the title, else words from the address (e.g.
  /// "How octopuses dream" from …/how-octopuses-dream.html), else the site.
  String get label => title ?? _titleFromPath() ?? site;

  /// The Markdown line for this link.
  String get markdown {
    final safeUrl = url.replaceAll('(', '%28').replaceAll(')', '%29');
    final t = title, d = description;
    if (t == null && d == null) return safeUrl;
    final shown = (t ?? label).replaceAllMapped(
      RegExp(r'[\\\[\]]'),
      (m) => '\\${m[0]}',
    );
    if (d == null) return '[$shown]($safeUrl)';
    final desc = d.replaceAllMapped(RegExp(r'[\\"]'), (m) => '\\${m[0]}');
    return '[$shown]($safeUrl "$desc")';
  }

  String? _titleFromPath() {
    final segments = Uri.tryParse(url)?.pathSegments ?? const <String>[];
    final last = segments.lastWhere((s) => s.isNotEmpty, orElse: () => '');
    final name = Uri.decodeComponent(last).replaceFirst(RegExp(r'\.\w+$'), '');
    if (!name.contains(_slugWord)) return null;
    final words = name.split(_slugWord).where((w) => w.isNotEmpty).toList();
    final wordy = words.where(_hasLetters.hasMatch).length;
    if (words.length < 2 || wordy < 2 || words.any(_looksLikeId)) return null;
    final text = words.join(' ');
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Ids and hashes ("a8f3k29x") mean nothing to a reader.
  static bool _looksLikeId(String w) =>
      w.length > 6 && _digits.allMatches(w).length >= 2;

  static String _unescape(String s) =>
      s.replaceAllMapped(_escaped, (m) => m[1]!);

  static String? _clean(String s) {
    final t = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return t.isEmpty ? null : t;
  }
}
