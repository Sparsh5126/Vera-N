import 'dart:math';
import 'dart:typed_data';

/// One model under test: turns text into a unit-length vector.
abstract class Embedder {
  String get name;

  /// Loads the model and tokenizer (timed by the runner).
  Future<void> load();

  /// Tokenizes [text] (timed separately, as it runs in Dart).
  List<int> tokenize(String text);

  /// Runs the model on token ids and returns a normalized vector.
  Future<Float32List> embedIds(List<int> ids);

  Future<void> close();
}

/// Mean of token vectors (rows of [hidden], `seq x dim`), then L2-normalized.
Float32List meanPool(List<double> hidden, int seq, int dim) {
  final out = Float32List(dim);
  for (var t = 0; t < seq; t++) {
    for (var d = 0; d < dim; d++) {
      out[d] += hidden[t * dim + d];
    }
  }
  for (var d = 0; d < dim; d++) {
    out[d] /= seq;
  }
  return normalize(out);
}

Float32List normalize(Float32List v) {
  var sum = 0.0;
  for (final x in v) {
    sum += x * x;
  }
  final norm = sqrt(sum);
  if (norm == 0) return v;
  for (var i = 0; i < v.length; i++) {
    v[i] = v[i] / norm;
  }
  return v;
}

double cosine(Float32List a, Float32List b) {
  var dot = 0.0;
  for (var i = 0; i < a.length; i++) {
    dot += a[i] * b[i];
  }
  return dot;
}
