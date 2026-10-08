import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/storage/storage_providers.dart';
import '../../../core/styles/app_styles.dart';
import 'embed_missing.dart';

/// A photo full screen, with pinch to zoom and a close button.
class PhotoViewer extends ConsumerWidget {
  const PhotoViewer({super.key, required this.name});

  final String name;

  static Future<void> open(BuildContext context, String name) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => PhotoViewer(name: name),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bytes = ref.watch(attachmentBytesProvider(name)).value;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
          tooltip: AppCopy.close,
        ),
        title: const Text(AppCopy.photo),
      ),
      body: Center(
        child: bytes == null
            ? const EmbedMissing()
            : InteractiveViewer(
                maxScale: AppSize.graphMaxZoom,
                child: Image.memory(bytes, fit: BoxFit.contain),
              ),
      ),
    );
  }
}
