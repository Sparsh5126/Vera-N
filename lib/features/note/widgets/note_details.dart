import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/models/linked_note.dart';
import '../../../core/styles/app_styles.dart';
import '../../../shared/widgets/note_chip.dart';
import '../../../shared/widgets/section_label.dart';
import '../../../shared/widgets/text_link.dart';

/// What sits below the note's text when not typing (UI spec §7): Folder,
/// Tags, Linked, Suggested links (dimmed chips) and Mentioned in. Empty
/// sections are hidden; a note with no folder or tags shows small "Add to
/// folder" / "Add tag" buttons instead.
class NoteDetails extends StatelessWidget {
  const NoteDetails({
    super.key,
    required this.folder,
    required this.tags,
    required this.linked,
    required this.mentionedIn,
    this.suggested = const [],
    this.onSuggestedTap,
    this.suggestedTags = const [],
    this.onSuggestedTagTap,
    required this.onFolderTap,
    required this.onAddTag,
    required this.onTagTap,
    required this.onOpenNote,
  });

  /// '' when the note isn't in a folder.
  final String folder;
  final List<String> tags;
  final List<LinkedNote> linked;
  final List<LinkedNote> mentionedIn;

  /// Notes the app suggests linking; tapping one opens the suggestion.
  final List<LinkedNote> suggested;
  final ValueChanged<int>? onSuggestedTap;

  /// Tags the app suggests (dimmed, in the Tags row after the confirmed
  /// ones; UI spec §7). Tapping one opens the suggestion.
  final List<String> suggestedTags;
  final ValueChanged<String>? onSuggestedTagTap;

  /// Opens the move-to-folder sheet.
  final VoidCallback onFolderTap;
  final VoidCallback onAddTag;
  final ValueChanged<String> onTagTap;
  final ValueChanged<int> onOpenNote;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.m, bottom: AppSpace.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: context.colors.border),
          ..._folderAndTags(),
          if (linked.isNotEmpty)
            _section(
              AppCopy.linked,
              _wrap([
                for (final n in linked)
                  TextLink(label: n.title, onTap: () => onOpenNote(n.ref)),
              ]),
            ),
          if (suggested.isNotEmpty)
            _section(
              AppCopy.suggestedLinks,
              _wrap([
                for (final n in suggested)
                  NoteChip(
                    label: n.title,
                    dimmed: true,
                    semanticLabel: AppCopy.suggestedLink(n.title),
                    onTap: () => onSuggestedTap?.call(n.ref),
                  ),
              ]),
            ),
          if (mentionedIn.isNotEmpty)
            _section(
              AppCopy.mentionedIn,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final n in mentionedIn)
                    TextLink(label: n.title, onTap: () => onOpenNote(n.ref)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _folderAndTags() {
    final addToFolder = TextButton.icon(
      onPressed: onFolderTap,
      icon: const Icon(
        Icons.create_new_folder_outlined,
        size: AppSize.iconSmall,
      ),
      label: const Text(AppCopy.addToFolder),
    );
    final addTag = TextButton.icon(
      onPressed: onAddTag,
      icon: const Icon(Icons.add, size: AppSize.iconSmall),
      label: const Text(AppCopy.addTag),
    );
    final anyTags = tags.isNotEmpty || suggestedTags.isNotEmpty;
    if (folder.isEmpty && !anyTags) {
      return [
        _section(null, _wrap([addToFolder, addTag])),
      ];
    }
    return [
      _section(
        folder.isEmpty ? null : AppCopy.folderSection,
        folder.isEmpty
            ? addToFolder
            : _wrap([
                NoteChip(
                  label: folder,
                  icon: Icons.folder_outlined,
                  onTap: onFolderTap,
                ),
              ]),
      ),
      _section(
        anyTags ? AppCopy.tags : null,
        _wrap([
          for (final tag in tags)
            NoteChip(label: AppCopy.tagLabel(tag), onTap: () => onTagTap(tag)),
          for (final tag in suggestedTags)
            NoteChip(
              label: AppCopy.tagLabel(tag),
              dimmed: true,
              semanticLabel: AppCopy.suggestedTag(tag),
              onTap: () => onSuggestedTagTap?.call(tag),
            ),
          addTag,
        ]),
      ),
    ];
  }

  Widget _wrap(List<Widget> children) => Wrap(
    spacing: AppSpace.s,
    runSpacing: AppSpace.s,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: children,
  );

  Widget _section(String? label, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            SectionLabel(label),
            const SizedBox(height: AppSpace.s),
          ],
          child,
        ],
      ),
    );
  }
}
