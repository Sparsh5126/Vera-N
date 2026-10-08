import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/storage/storage_providers.dart';
import '../../../core/styles/app_styles.dart';
import 'embed_missing.dart';
import 'embed_square.dart';

/// A photo in the note, filling a rounded square (cropped to fit).
/// Tapping opens it whole, full screen.
class PhotoEmbed extends ConsumerWidget {
  const PhotoEmbed({super.key, required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bytes = ref.watch(attachmentBytesProvider(name));
    return bytes.when(
      // Read from the device at once: no spinner, just the space.
      loading: () => const SizedBox(height: AppSize.minTapTarget),
      error: (_, _) => const EmbedMissing(),
      data: (data) {
        if (data == null) return const EmbedMissing();
        return Semantics(
          image: true,
          button: true,
          label: AppCopy.photo,
          child: GestureDetector(
            onTap: onTap,
            child: EmbedSquare(
              child: Image(
                image: _small(context, data),
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (_, _, _) => const EmbedMissing(),
              ),
            ),
          ),
        );
      },
    );
  }

  /// The photo decoded small, not at full size: within twice the square,
  /// so the short side of a photo up to 2:1 still covers it sharply.
  static ImageProvider _small(BuildContext context, Uint8List data) {
    final side =
        (AppSize.embedSize * 2 * MediaQuery.devicePixelRatioOf(context))
            .round();
    return ResizeImage(
      MemoryImage(data),
      width: side,
      height: side,
      policy: ResizeImagePolicy.fit,
    );
  }
}
