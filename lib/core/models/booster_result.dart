/// A note as a laptop result saw it: its id across devices (the header id,
/// or the path inside `Notes/` for a note without one) and the hash of the
/// text the result was made from.
class NoteStamp {
  const NoteStamp(this.key, this.hash);

  final String key;
  final String hash;

  @override
  bool operator ==(Object other) =>
      other is NoteStamp && other.key == key && other.hash == hash;

  @override
  int get hashCode => Object.hash(key, hash);
}

/// What a laptop job produced (docs/LAPTOP_PLAN.md, L2).
enum BoosterKind {
  /// A written "Why?" for a waiting link: one sentence in [values].
  why,

  /// New tag names for one note, in [values].
  tags,

  /// A topic: its name in [values], its notes in [notes].
  topic,

  /// Two notes that say the same thing; [values] holds one sentence why.
  duplicate,
}

/// One line of `MyNotes/.app/laptop-<deviceid>.jsonl`: note ids and hashes
/// plus the short AI-written text, never the notes' own text.
///
/// Empty [values] records that the job ran and found nothing, so it isn't
/// asked again until a note changes.
class BoosterResult {
  const BoosterResult({
    required this.kind,
    required this.notes,
    required this.values,
    required this.model,
    required this.madeAt,
    required this.deviceId,
  });

  final BoosterKind kind;
  final List<NoteStamp> notes;
  final List<String> values;
  final String model;
  final DateTime madeAt;
  final String deviceId;

  bool get found => values.isNotEmpty;

  /// Which job this answers: the kind and the notes with their hashes. A
  /// newer result for the same job replaces an older one.
  String get jobKey {
    final parts = [for (final n in notes) '${n.key}@${n.hash}']..sort();
    return '${kind.name}|${parts.join('|')}';
  }

  /// Whether every note is still as it was ([current] maps key to hash).
  bool freshIn(Map<String, String> current) =>
      notes.every((n) => current[n.key] == n.hash);

  Map<String, Object> toFileJson() => {
    'kind': kind.name,
    'notes': [
      for (final n in notes) {'id': n.key, 'hash': n.hash},
    ],
    'values': values,
    'model': model,
    'madeAt': madeAt.toUtc().toIso8601String(),
    'deviceId': deviceId,
  };

  /// A line read back, or null if damaged or of a kind this version
  /// doesn't know.
  static BoosterResult? fromFileJson(Map<String, Object?> json) {
    final kind = BoosterKind.values.asNameMap()[json['kind']];
    final notes = json['notes'], values = json['values'];
    final madeAt = DateTime.tryParse('${json['madeAt']}');
    final model = json['model'], device = json['deviceId'];
    if (kind == null || notes is! List || notes.isEmpty) return null;
    if (values is! List || madeAt == null) return null;
    if (model is! String || device is! String) return null;
    final stamps = <NoteStamp>[];
    for (final n in notes) {
      if (n is! Map || n['id'] is! String || n['hash'] is! String) {
        return null;
      }
      stamps.add(NoteStamp(n['id'] as String, n['hash'] as String));
    }
    return BoosterResult(
      kind: kind,
      notes: stamps,
      values: [for (final v in values) '$v'],
      model: model,
      madeAt: madeAt,
      deviceId: device,
    );
  }
}
