import 'dart:typed_data';

/// A small fingerprint of a text's words (MinHash, 32 numbers), so the app
/// can tell later how much a note changed without keeping its text.
///
/// Two signatures agree in about the same share of places as the two
/// texts share words (Jaccard similarity of their word sets).
abstract final class WordSignature {
  static const size = 32;
  static final _word = RegExp(r'[\p{L}\p{N}]+', unicode: true);

  static Uint8List of(String text) {
    final mins = Uint32List(size)..fillRange(0, size, 0xFFFFFFFF);
    for (final m in _word.allMatches(text.toLowerCase())) {
      final base = _fnv(m.group(0)!);
      for (var i = 0; i < size; i++) {
        final h = _mix(base ^ (0x9E3779B9 * (i + 1)) & 0xFFFFFFFF);
        if (h < mins[i]) mins[i] = h;
      }
    }
    return mins.buffer.asUint8List();
  }

  /// Share of words the two texts have in common, 0–1 (estimated).
  static double similarity(Uint8List a, Uint8List b) {
    final x = Uint32List.sublistView(a);
    final y = Uint32List.sublistView(b);
    var same = 0;
    for (var i = 0; i < size; i++) {
      if (x[i] == y[i]) same++;
    }
    return same / size;
  }

  static int _fnv(String word) {
    var h = 0x811C9DC5;
    for (final unit in word.codeUnits) {
      h = ((h ^ unit) * 0x01000193) & 0xFFFFFFFF;
    }
    return h;
  }

  /// Spreads the bits of [h] (a 32-bit integer finalizer).
  static int _mix(int h) {
    h = ((h ^ (h >> 16)) * 0x85EBCA6B) & 0xFFFFFFFF;
    h = ((h ^ (h >> 13)) * 0xC2B2AE35) & 0xFFFFFFFF;
    return h ^ (h >> 16);
  }
}
