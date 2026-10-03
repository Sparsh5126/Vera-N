import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/models/note_summary.dart';
import '../../../core/styles/app_styles.dart';
import '../../../shared/widgets/empty_state.dart';

/// Pick a note to link to: type to narrow by title. Pops with the note's
/// ref, or null if dismissed (the typed `[[` then stays as text).
class NotePickerSheet extends StatefulWidget {
  const NotePickerSheet({super.key, required this.notes});

  /// Shows the sheet above everything else.
  static Future<int?> show(BuildContext context, List<NoteSummary> notes) {
    return showModalBottomSheet<int>(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) => NotePickerSheet(notes: notes),
    );
  }

  final List<NoteSummary> notes;

  @override
  State<NotePickerSheet> createState() => _NotePickerSheetState();
}

class _NotePickerSheetState extends State<NotePickerSheet> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.text.trim().toLowerCase();
    final matches = [
      for (final n in widget.notes)
        if (n.title.isNotEmpty && n.title.toLowerCase().contains(q)) n,
    ];
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpace.m,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: AppSpace.screen,
            child: TextField(
              controller: _query,
              autofocus: true,
              style: context.textStyles.body,
              decoration: const InputDecoration(
                hintText: AppCopy.linkPickerHint,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Flexible(
            child: matches.isEmpty
                ? const EmptyState(message: AppCopy.emptySearch)
                : ListView(
                    shrinkWrap: true,
                    children: [
                      for (final n in matches)
                        ListTile(
                          title: Text(n.title, style: context.textStyles.body),
                          subtitle: n.folder.isEmpty
                              ? null
                              : Text(n.folder, style: context.textStyles.small),
                          onTap: () => Navigator.of(context).pop(n.ref),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
