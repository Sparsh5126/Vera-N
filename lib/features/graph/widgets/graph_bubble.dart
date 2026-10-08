import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/styles/app_styles.dart';

/// One folder of a very large library: an amber circle (the folder
/// color) with the folder's name. Tapping shows that folder's notes.
class GraphBubble extends StatelessWidget {
  const GraphBubble({
    super.key,
    required this.folder,
    required this.count,
    required this.radius,
    required this.onTap,
  });

  final String folder;
  final int count;
  final double radius;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shape = CircleBorder(
      side: BorderSide(color: colors.folder, width: AppSize.graphLine),
    );
    return Semantics(
      button: true,
      label: AppCopy.folderBubble(folder, count),
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: radius * 2,
        child: Material(
          color: colors.folder.withValues(alpha: AppOpacity.bubbleFill),
          shape: shape,
          child: InkWell(
            customBorder: shape,
            onTap: onTap,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpace.xs),
                child: Text(
                  AppCopy.folderName(folder),
                  style: context.textStyles.small.copyWith(color: colors.text),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
