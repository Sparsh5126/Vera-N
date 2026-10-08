import 'dart:typed_data';

import 'package:vera_n/core/ai/embedder/embedder.dart';
import 'package:vera_n/core/ai/matching/vectors.dart';

/// A stand-in for the model: each word lights up one of 384 dimensions,
/// so texts sharing most words are similar. Counts what it was asked.
class FakeEmbedder implements Embedder {
  FakeEmbedder({this.model = 'fake@1'});

  @override
  String model;

  int loads = 0;
  int closes = 0;
  final embedded = <String>[];

  static final _word = RegExp(r'[\p{L}\p{N}]+', unicode: true);

  @override
  Future<void> load() async => loads++;

  @override
  Future<void> close() async => closes++;

  @override
  int countTokens(String text) => _word.allMatches(text).length;

  @override
  Future<Float32List> embed(String text) async {
    embedded.add(text);
    final hidden = List<double>.filled(384, 0);
    for (final m in _word.allMatches(text.toLowerCase())) {
      hidden[m.group(0)!.hashCode % 384] += 1;
    }
    return Vectors.meanPool(hidden, 1, 384);
  }
}
