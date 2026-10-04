/// Numbered points for the List button: "1. milk 2. eggs" written on one
/// line become one point per line, numbered in order.
abstract final class NumberedPoints {
  static final _numbered = RegExp(r'^(\d{1,9})\. ');
  static final _inlineFirst = RegExp(r'(^|\s)1\. ');

  /// The selected [lines] as a numbered list, one point per line. Lines
  /// before the first point (e.g. "Plan:") stay as they are; lines after
  /// it become points too. Returns null when there are no numbered points.
  /// A selection that already is such a list loses its numbers instead,
  /// so List works as a toggle.
  static List<String>? asList(List<String> lines) {
    final split = [for (final l in lines) ..._split(l)];
    final firstPoint = split.indexWhere(_numbered.hasMatch);
    if (firstPoint == -1) return null;
    if (split.length == lines.length && _isList(lines)) {
      return [for (final l in lines) l.replaceFirst(_numbered, '')];
    }
    var n = int.parse(_numbered.firstMatch(split[firstPoint])!.group(1)!);
    return [
      for (var i = 0; i < split.length; i++)
        if (i < firstPoint || split[i].trim().isEmpty)
          split[i]
        else
          '${n++}. ${split[i].replaceFirst(_numbered, '')}',
    ];
  }

  /// Every non-empty line numbered, counting up by one.
  static bool _isList(List<String> lines) {
    int? last;
    for (final l in lines) {
      if (l.trim().isEmpty) continue;
      final m = _numbered.firstMatch(l);
      if (m == null) return false;
      final n = int.parse(m.group(1)!);
      if (last != null && n != last + 1) return false;
      last = n;
    }
    return last != null;
  }

  /// Splits one line at its numbered points: at a leading "N. " or an
  /// inline " 1. ", then at " N+1. ", " N+2. ", …. Numbers that don't count
  /// on ("costs 2. something") are left alone.
  static List<String> _split(String line) {
    final lead = _numbered.firstMatch(line);
    final first = lead ?? _inlineFirst.firstMatch(line);
    if (first == null) return [line];
    final parts = <String>[];
    var at = lead == null ? first.end - 3 : 0;
    if (at > 0) parts.add(line.substring(0, at).trim());
    var n = lead == null ? 1 : int.parse(lead.group(1)!);
    while (true) {
      final next = line.indexOf(' ${n + 1}. ', at + 1);
      if (next == -1) break;
      parts.add(line.substring(at, next).trim());
      at = next + 1;
      n++;
    }
    parts.add(line.substring(at).trim());
    return parts;
  }
}
