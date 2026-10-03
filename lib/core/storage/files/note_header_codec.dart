import 'package:yaml/yaml.dart';

import '../../models/note_header.dart';
import 'note_document.dart';

/// Reads and writes the known header fields (`id`, `created`, `tags`,
/// `pinned`) without disturbing any other header line.
abstract final class NoteHeaderCodec {
  static const _order = ['id', 'created', 'tags', 'pinned'];
  static final _topLevelKey = RegExp(r'^([A-Za-z_][\w-]*)\s*:');

  /// The known fields, or an empty header when there is none or it can't
  /// be read. Never throws on bad input.
  static NoteHeader read(NoteDocument doc) {
    final map = _parseMap(doc.headerLines);
    if (map == null) return const NoteHeader();
    return NoteHeader(
      id: _string(map['id']),
      created: _date(map['created']),
      tags: _tags(map['tags']),
      pinned: map['pinned'] == true,
    );
  }

  /// Returns [doc] with the known fields set to [header].
  ///
  /// Other header lines keep their text and order. A key that wasn't in the
  /// file is only added when it has a value (no empty tags, no `pinned:
  /// false`). If the file starts with `---` but isn't a valid header, that
  /// text is kept as part of the body and a new header is put in front.
  static NoteDocument write(NoteDocument doc, NoteHeader header) {
    var base = doc;
    final lines = doc.headerLines;
    if (lines != null && lines.isNotEmpty && _parseMap(lines) == null) {
      base = NoteDocument(headerLines: null, body: doc.serialize());
    }
    final values = _values(header);
    final out = <String>[];
    final written = <String>{};
    final source = base.headerLines ?? const <String>[];
    for (var i = 0; i < source.length; i++) {
      final key = _topLevelKey.firstMatch(source[i])?.group(1);
      if (key == null || !values.containsKey(key)) {
        out.add(source[i]);
        continue;
      }
      // Skip the old value's continuation lines (block lists, wrapped text).
      while (i + 1 < source.length && _isContinuation(source[i + 1])) {
        i++;
      }
      written.add(key);
      final value = values[key];
      if (value != null) out.add('$key: $value');
    }
    for (final key in _order) {
      final value = values[key];
      if (!written.contains(key) && value != null && _hasValue(key, header)) {
        out.add('$key: $value');
      }
    }
    return base.withHeaderLines(out);
  }

  static Map<String, String?> _values(NoteHeader h) => {
    'id': h.id == null ? null : _quoteIfNeeded(h.id!),
    'created': h.created == null ? null : formatDate(h.created!),
    'tags': '[${h.tags.map(_quoteIfNeeded).join(', ')}]',
    'pinned': '${h.pinned}',
  };

  static bool _hasValue(String key, NoteHeader h) => switch (key) {
    'tags' => h.tags.isNotEmpty,
    'pinned' => h.pinned,
    _ => true,
  };

  static bool _isContinuation(String line) =>
      line.startsWith(' ') || line.startsWith('\t') || line.startsWith('- ');

  static Map<dynamic, dynamic>? _parseMap(List<String>? lines) {
    if (lines == null) return null;
    if (lines.every((l) => l.trim().isEmpty)) return const {};
    try {
      final parsed = loadYaml(lines.join('\n'));
      return parsed is Map ? parsed : null;
    } on YamlException {
      return null;
    }
  }

  static String? _string(Object? v) => v?.toString();

  static DateTime? _date(Object? v) =>
      v == null ? null : DateTime.tryParse(v.toString())?.toLocal();

  static List<String> _tags(Object? v) {
    final raw = switch (v) {
      final List<dynamic> list => list.map((e) => e.toString()),
      final String s => s.split(RegExp(r'[,\s]+')),
      _ => const <String>[],
    };
    return raw
        .map((t) => t.trim().replaceFirst(RegExp('^#'), ''))
        .where((t) => t.isNotEmpty)
        .toList();
  }

  static String _quoteIfNeeded(String tag) {
    if (RegExp(r'^[\w/\-ऀ-ॿ]+$').hasMatch(tag)) return tag;
    final escaped = tag.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
    return '"$escaped"';
  }

  /// ISO 8601 with the local offset, seconds precision:
  /// `2026-10-03T15:32:28+05:30`.
  static String formatDate(DateTime t) {
    final local = t.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    final offset = local.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final minutes = offset.inMinutes.abs();
    return '${local.year.toString().padLeft(4, '0')}-${two(local.month)}-'
        '${two(local.day)}T${two(local.hour)}:${two(local.minute)}:'
        '${two(local.second)}$sign${two(minutes ~/ 60)}:${two(minutes % 60)}';
  }
}
