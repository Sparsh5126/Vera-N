import 'package:flutter/material.dart';

import '../../core/copy/app_copy.dart';
import 'option_sheet.dart';
import 'text_entry_sheet.dart';

/// The folder sheet, used by a note's Folder row and by Home's selection:
/// no folder, every existing folder, or a new one typed (`/` makes
/// subfolders). Returns the picked folder (`''` for none), or null if the
/// user backed out. A typed name goes through [cleanName] (the caller's
/// `Names.folder`), so this widget stays free of storage rules.
abstract final class FolderPicker {
  /// Picked in the sheet to type a new folder name.
  static const _newFolder = '\u0000new';

  static Future<String?> pick(
    BuildContext context, {
    required List<String> folders,
    required String? Function(String typed) cleanName,
    String? current,
  }) async {
    final picked = await OptionSheet.show<String>(
      context,
      selected: current,
      options: [
        const SheetOption('', AppCopy.noFolder),
        for (final f in folders) SheetOption(f, f),
        const SheetOption(_newFolder, AppCopy.newFolder),
      ],
    );
    final folder = picked?.value;
    if (folder != _newFolder) return folder;
    if (!context.mounted) return null;
    return typeNew(context, cleanName: cleanName);
  }

  /// Asks for a new folder's name; null if the user backed out.
  static Future<String?> typeNew(
    BuildContext context, {
    required String? Function(String typed) cleanName,
  }) async {
    final typed = await TextEntrySheet.show(
      context,
      hint: AppCopy.folderNameHint,
    );
    return typed == null ? null : cleanName(typed);
  }
}
