import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/models/suggestion_view.dart';

/// "Remove one" for copies: which of the two notes goes to the trash.
/// Returns its ref, or null if the sheet was closed.
abstract final class RemoveOneSheet {
  static Future<int?> show(BuildContext context, SuggestionView view) {
    return showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final note in [view.newer, view.older])
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(AppCopy.removeThis(note.title)),
                onTap: () => Navigator.pop(sheet, note.ref),
              ),
          ],
        ),
      ),
    );
  }
}
