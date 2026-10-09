import 'dart:math';
import 'dart:typed_data';

import '../models/chunk_vector.dart';
import 'booster_settings.dart';

/// Whole-note meanings for the booster's topic and duplicate jobs
/// (docs/LAPTOP_PLAN.md, L2): each note's chunks averaged into one unit
/// vector, then compared note to note.
abstract final class NoteGroups {
  /// One unit vector per note: the mean of its chunk vectors.
  static Map<int, Float32List> meanings(Iterable<ChunkVector> chunks) {
    final sums = <int, Float32List>{};
    for (final c in chunks) {
      final v = Int8List.sublistView(c.vector);
      final sum = sums.putIfAbsent(c.note, () => Float32List(v.length));
      if (sum.length != v.length) continue;
      for (var i = 0; i < v.length; i++) {
        sum[i] += v[i];
      }
    }
    return sums.map((note, sum) => MapEntry(note, _unit(sum)));
  }

  static double similarity(Float32List a, Float32List b) {
    var dot = 0.0;
    for (var i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
    }
    return dot;
  }

  /// Groups of notes that are all close to one note of the group: at
  /// least [BoosterSettings.topicMin], the closest
  /// [BoosterSettings.topicMax] kept. Each note is in one group at most.
  static List<List<int>> topics(Map<int, Float32List> meanings) {
    final notes = meanings.keys.toList()..sort();
    final taken = <int>{};
    final groups = <List<int>>[];
    for (final seed in notes) {
      if (taken.contains(seed)) continue;
      final near = <(int, double)>[
        for (final other in notes)
          if (other != seed && !taken.contains(other))
            (other, similarity(meanings[seed]!, meanings[other]!)),
      ].where((p) => p.$2 >= BoosterSettings.topicSimilarity).toList();
      if (near.length + 1 < BoosterSettings.topicMin) continue;
      near.sort((a, b) => b.$2.compareTo(a.$2));
      final group = [
        seed,
        for (final p in near.take(BoosterSettings.topicMax - 1)) p.$1,
      ]..sort();
      taken.addAll(group);
      groups.add(group);
    }
    return groups;
  }

  /// Pairs close enough to be copies of each other, of similar length
  /// ([lengths]: note to text length), most alike first.
  static List<(int, int)> duplicateCandidates(
    Map<int, Float32List> meanings,
    Map<int, int> lengths,
  ) {
    final notes = meanings.keys.toList()..sort();
    final found = <(int, int, double)>[];
    for (var i = 0; i < notes.length; i++) {
      for (var j = i + 1; j < notes.length; j++) {
        final a = notes[i], b = notes[j];
        final s = similarity(meanings[a]!, meanings[b]!);
        if (s < BoosterSettings.duplicateSimilarity) continue;
        final la = lengths[a] ?? 0, lb = lengths[b] ?? 0;
        if (min(la, lb) < max(la, lb) * BoosterSettings.duplicateLengthRatio) {
          continue;
        }
        found.add((a, b, s));
      }
    }
    found.sort((x, y) => y.$3.compareTo(x.$3));
    return [for (final f in found) (f.$1, f.$2)];
  }

  static Float32List _unit(Float32List v) {
    var sum = 0.0;
    for (final x in v) {
      sum += x * x;
    }
    final norm = sqrt(sum);
    if (norm == 0) return v;
    for (var i = 0; i < v.length; i++) {
      v[i] /= norm;
    }
    return v;
  }
}
