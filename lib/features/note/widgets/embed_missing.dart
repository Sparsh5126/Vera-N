import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/styles/app_styles.dart';

/// Where an attachment's file isn't (yet) in `Attachments/`, for example
/// still syncing from another device. Said plainly, never as an error.
class EmbedMissing extends StatelessWidget {
  const EmbedMissing({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.image_not_supported_outlined,
          size: AppSize.iconSmall,
          color: colors.textSecondary,
        ),
        const SizedBox(width: AppSpace.s),
        Flexible(
          child: Text(
            AppCopy.attachmentMissing,
            style: context.textStyles.small,
          ),
        ),
      ],
    );
  }
}
