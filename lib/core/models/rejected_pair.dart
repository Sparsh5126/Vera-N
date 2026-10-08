import 'dart:typed_data';

/// A rejection seen from one note: the other note and both notes' word
/// fingerprints at the time (null when the rejection came from a file).
class RejectedPair {
  const RejectedPair(this.other, this.ownSignature, this.otherSignature);

  final int other;
  final Uint8List? ownSignature;
  final Uint8List? otherSignature;
}
