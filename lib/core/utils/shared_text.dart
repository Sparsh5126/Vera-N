import '../storage/files/web_link.dart';

/// Turns what another app shares to Vera N (Android "Share") into the text
/// of a new note. A link becomes a link card line, using only what the
/// sharing app sent: its subject as the title (browsers send the page
/// title there), and any other words as the description. Nothing is
/// fetched. Shared text without a link is kept as it is.
abstract final class SharedText {
  static const _maxTitle = 120;
  static const _maxDescription = 300;

  /// The new note's text, ending with an empty line for the user's words;
  /// null if nothing usable was shared.
  static String? toNoteBody({String? text, String? subject}) {
    final body = (text ?? '').trim();
    final heading = _oneLine(subject);
    final url = WebLink.findUrl(body) ?? WebLink.findUrl(heading ?? '');
    if (url == null) {
      if (body.isEmpty) return heading == null ? null : '$heading\n';
      final withHeading = heading == null || body.contains(heading)
          ? body
          : '$heading\n$body';
      return '$withHeading\n';
    }
    final rest = body.replaceFirst(url, '').trim();
    var title = heading == null || heading.contains(url) ? null : heading;
    var description = rest;
    if (title == null && rest.isNotEmpty) {
      final lines = rest.split('\n');
      final first = lines.first.trim();
      if (first.length <= _maxTitle) {
        title = first;
        description = lines.skip(1).join(' ').trim();
      }
    }
    final link = WebLink(
      url: url,
      title: _cap(title, _maxTitle),
      description: description == title
          ? null
          : _cap(_oneLine(description), _maxDescription),
    );
    return '${link.markdown}\n';
  }

  static String? _oneLine(String? s) {
    final t = (s ?? '').replaceAll(RegExp(r'\s+'), ' ').trim();
    return t.isEmpty ? null : t;
  }

  static String? _cap(String? s, int max) {
    if (s == null || s.isEmpty) return null;
    return s.length <= max ? s : '${s.substring(0, max - 1).trimRight()}…';
  }
}
