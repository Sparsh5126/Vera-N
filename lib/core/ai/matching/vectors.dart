import 'dart:math';
import 'dart:typed_data';

/// Compact vectors: unit-length float vectors are stored as int8 (one byte
/// per dimension, 384 bytes for this model) and compared in that form.
abstract final class Vectors {
  static const _scale = 127;

  /// [v] (unit length) as int8 bytes.
  static Uint8List quantize(Float32List v) {
    final out = Int8List(v.length);
    for (var i = 0; i < v.length; i++) {
      out[i] = (v[i] * _scale).round().clamp(-_scale, _scale);
    }
    return out.buffer.asUint8List();
  }

  /// Cosine similarity of two quantized unit vectors (about ±0.01).
  static double cosine(Uint8List a, Uint8List b) {
    final x = Int8List.sublistView(a);
    final y = Int8List.sublistView(b);
    var dot = 0;
    var nx = 0;
    var ny = 0;
    for (var i = 0; i < x.length; i++) {
      dot += x[i] * y[i];
      nx += x[i] * x[i];
      ny += y[i] * y[i];
    }
    if (nx == 0 || ny == 0) return 0;
    return dot / sqrt(nx.toDouble() * ny);
  }

  /// Mean of token vectors (rows of [hidden], `tokens × dim`), then scaled
  /// to unit length: one vector for the whole text.
  static Float32List meanPool(List<double> hidden, int tokens, int dim) {
    final out = Float32List(dim);
    for (var t = 0; t < tokens; t++) {
      for (var d = 0; d < dim; d++) {
        out[d] += hidden[t * dim + d];
      }
    }
    var sum = 0.0;
    for (final x in out) {
      sum += x * x;
    }
    final norm = sqrt(sum);
    if (norm == 0) return out;
    for (var d = 0; d < dim; d++) {
      out[d] /= norm;
    }
    return out;
  }
}
