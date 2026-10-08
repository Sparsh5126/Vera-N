import 'package:flutter/foundation.dart';

/// How much room attachments take, and which no note uses (Settings).
@immutable
class AttachmentUsage {
  const AttachmentUsage({
    required this.count,
    required this.bytes,
    required this.unused,
    required this.unusedBytes,
  });

  static const none = AttachmentUsage(
    count: 0,
    bytes: 0,
    unused: [],
    unusedBytes: 0,
  );

  final int count;
  final int bytes;

  /// Files in `Attachments/` that no note embeds (notes in the trash or
  /// the archive count as using theirs).
  final List<String> unused;
  final int unusedBytes;
}
