import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/storage/storage_providers.dart';
import '../../../core/styles/app_styles.dart';
import 'embed_missing.dart';

/// A photo in the note, up to [AppSize.embedMaxHeight] tall with rounded
/// corners. Tapping opens it full screen.
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
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: AppSize.embedMaxHeight,
              ),
              child: ClipRRect(
                borderRadius: AppRadius.cardBorder,
                child: Image.memory(
                  data,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                  errorBuilder: (_, _, _) => const EmbedMissing(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
