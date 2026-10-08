import 'dart:typed_data';

/// A suggestion the user rejected (product spec §8, §16). Holds note ids
/// and content hashes only, never note text.
class Rejection {
  const Rejection({
    required this.noteA,
    required this.hashA,
    required this.noteB,
    required this.hashB,
    required this.rejectedAt,
    required this.deviceId,
    this.signatureA,
    this.signatureB,
  });

  /// Note ids in sorted order: [noteA] < [noteB].
  final String noteA;
  final String hashA;
  final String noteB;
  final String hashB;
  final DateTime rejectedAt;
  final String deviceId;

  /// Word fingerprints, kept in the private database only.
  final Uint8List? signatureA;
  final Uint8List? signatureB;

  String get pairKey => pairKeyOf(noteA, noteB);

  static String pairKeyOf(String a, String b) =>
      a.compareTo(b) < 0 ? '$a|$b' : '$b|$a';

  /// One line of the rejections file: ids and hashes only.
  Map<String, Object> toFileJson() => {
    'pairKey': pairKey,
    'noteA': noteA,
    'hashA': hashA,
    'noteB': noteB,
    'hashB': hashB,
    'rejectedAt': rejectedAt.toUtc().toIso8601String(),
    'deviceId': deviceId,
  };
}
