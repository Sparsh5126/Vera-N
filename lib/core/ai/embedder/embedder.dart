import 'dart:typed_data';

/// Turns text into a unit-length vector. Loaded only for a batch of work,
/// then closed, so the model isn't kept in memory (CLAUDE.md §8).
abstract class Embedder {
  /// Model name and version, stored with every vector; when it changes,
  /// every note is embedded again (product spec §4).
  String get model;

  Future<void> load();

  /// Tokens [text] takes (without `<s>` and `</s>`), to size chunks.
  int countTokens(String text);

  /// The text's vector; text beyond the model's window is cut off.
  Future<Float32List> embed(String text);

  Future<void> close();
}
