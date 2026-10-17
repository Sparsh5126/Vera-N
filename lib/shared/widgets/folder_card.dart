import 'package:flutter/material.dart';

import '../../core/styles/app_styles.dart';

/// A folder as a card: an icon, its name, and optionally the folders it
/// sits in above the name and a quiet line below (how many notes it holds).
/// The same plate as a note card, so folders and notes read as one family.
class FolderCard extends StatelessWidget {
  const FolderCard({
    super.key,
    required this.name,
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
    this.parent,
    this.caption,
  });

  final String name;
  final IconData icon;

  /// What a screen reader hears for the whole card.
  final String semanticLabel;
  final VoidCallback onTap;

  /// Shown small above [name], e.g. "in Ideas".
  final String? parent;

  /// Shown small below [name], e.g. "3 notes".
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: AppSpace.card,
            child: Row(
              children: [
                Icon(icon, size: AppSize.icon, color: context.colors.text),
                const SizedBox(width: AppSpace.m),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (parent != null) _line(parent!, styles.small),
                      _line(name, styles.cardTitle),
                      if (caption != null) _line(caption!, styles.small),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _line(String text, TextStyle style) =>
      Text(text, style: style, maxLines: 1, overflow: TextOverflow.ellipsis);
}
