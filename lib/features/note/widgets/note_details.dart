import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/styles/app_styles.dart';
import '../../../shared/widgets/note_chip.dart';
import '../../../shared/widgets/section_label.dart';

/// What sits below the note's text when not typing (UI spec §7). For now
/// the Tags row; Linked, Suggested links and Mentioned in come with links.
/// With no tags, only a small "Add tag" button shows.
class NoteDetails extends StatelessWidget {
  const NoteDetails({
    super.key,
    required this.tags,
    required this.onAddTag,
    required this.onTagTap,
  });

  final List<String> tags;
  final VoidCallback onAddTag;
  final ValueChanged<String> onTagTap;

  @override
  Widget build(BuildContext context) {
    final addTag = TextButton.icon(
      onPressed: onAddTag,
      icon: const Icon(Icons.add, size: AppSize.iconSmall),
      label: const Text(AppCopy.addTag),
    );
    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.m, bottom: AppSpace.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: context.colors.border),
          const SizedBox(height: AppSpace.m),
          if (tags.isNotEmpty) ...[
            const SectionLabel(AppCopy.tags),
            const SizedBox(height: AppSpace.s),
          ],
          Wrap(
            spacing: AppSpace.s,
            runSpacing: AppSpace.s,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final tag in tags)
                NoteChip(
                  label: AppCopy.tagLabel(tag),
                  onTap: () => onTagTap(tag),
                ),
              addTag,
            ],
          ),
        ],
      ),
    );
  }
}
