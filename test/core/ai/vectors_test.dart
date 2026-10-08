import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/ai/matching/vectors.dart';

void main() {
  Float32List unit(List<double> raw) =>
      Vectors.meanPool([...raw], 1, raw.length);

  double floatCosine(Float32List a, Float32List b) {
    var dot = 0.0;
    for (var i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
    }
    return dot;
  }

  test('meanPool averages tokens and returns a unit vector', () {
    final v = Vectors.meanPool([1, 0, 3, 0], 2, 2);
    expect(v[0], closeTo(1, 1e-6));
    expect(v[1], 0);
  });

  test('int8 vectors take one byte per dimension', () {
    final q = Vectors.quantize(unit(List.filled(384, 1)));
    expect(q.lengthInBytes, 384);
  });

  test('int8 cosine stays close to the float cosine', () {
    final random = Random(7);
    for (var i = 0; i < 20; i++) {
      final a = unit([for (var d = 0; d < 384; d++) random.nextDouble() - .5]);
      final b = unit([for (var d = 0; d < 384; d++) random.nextDouble() - .5]);
      final q = Vectors.cosine(Vectors.quantize(a), Vectors.quantize(b));
      expect(q, closeTo(floatCosine(a, b), 0.02));
    }
  });

  test('a vector matches itself fully; an all-zero vector matches nothing', () {
    final a = Vectors.quantize(unit([3, 4]));
    expect(Vectors.cosine(a, a), closeTo(1, 1e-9));
    expect(Vectors.cosine(a, Uint8List(2)), 0);
  });
}
