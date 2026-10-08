import 'dart:typed_data';

/// One stored chunk of a note with its int8 vector.
class ChunkVector {
  const ChunkVector({
    required this.note,
    required this.idx,
    required this.start,
    required this.end,
    required this.hash,
    required this.vector,
  });

  final int note;
  final int idx;
  final int start;
  final int end;

  /// Hash of the chunk's text, to reuse the vector when it didn't change.
  final String hash;
  final Uint8List vector;
}
