import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/models/linked_note.dart';
import '../../../core/styles/app_styles.dart';
import '../../../shared/widgets/note_chip.dart';
import '../../../shared/widgets/section_label.dart';

/// What sits below the note's text when not typing (UI spec §7): Folder,
/// Tags, Linked, and Mentioned in. Empty sections are hidden; a note with
/// no folder or tags shows small "Add to folder" / "Add tag" buttons
/// instead. Suggested links come with the AI stage.
class NoteDetails extends StatelessWidget {
  const NoteDetails({
    super.key,
    required this.folder,
    required this.tags,
    required this.linked,
    required this.mentionedIn,
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
                  NoteChip(label: n.title, onTap: () => onOpenNote(n.ref)),
              ]),
            ),
          if (mentionedIn.isNotEmpty)
            _section(
              AppCopy.mentionedIn,
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final n in mentionedIn)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        n.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyles.body,
                      ),
                      onTap: () => onOpenNote(n.ref),
                    ),
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
    if (folder.isEmpty && tags.isEmpty) {
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
        tags.isEmpty ? null : AppCopy.tags,
        _wrap([
          for (final tag in tags)
            NoteChip(label: AppCopy.tagLabel(tag), onTap: () => onTagTap(tag)),
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
