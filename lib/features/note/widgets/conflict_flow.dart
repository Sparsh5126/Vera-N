import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/storage/repositories/conflict_resolver.dart';
import '../../../core/styles/app_styles.dart';
import '../../../shared/widgets/notice_snack_bar.dart';
import '../../../shared/widgets/undo_snack_bar.dart';

/// What the conflict notice's buttons do in the open note. The editor's
/// unsaved typing is saved first ([beforeChange]) and the text reloaded
/// after ([afterChange]), as for accepting a suggestion.
class ConflictFlow {
  ConflictFlow({
    required this.resolver,
    required this.beforeChange,
    required this.afterChange,
  });

  final ConflictResolver resolver;
  final Future<void> Function() beforeChange;
  final Future<void> Function() afterChange;

  /// Compare: the other version in a sheet, read-only.
  Future<void> compare(BuildContext context, int ref) async {
    final other = await resolver.otherVersion(ref);
    if (other == null || !context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheet) => SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: AppSpace.m,
          right: AppSpace.m,
          bottom: AppSpace.l,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppCopy.otherVersion, style: sheet.textStyles.sectionLabel),
            const SizedBox(height: AppSpace.s),
            SelectableText(other, style: sheet.textStyles.body),
          ],
        ),
      ),
    );
  }

  Future<void> keepThis(BuildContext context, int ref) =>
      _withUndo(context, () => resolver.keepThis(ref), AppCopy.keptThisVersion);

  Future<void> keepOther(BuildContext context, int ref) => _withUndo(
    context,
    () => resolver.keepOther(ref),
    AppCopy.keptOtherVersion,
  );

  /// Keep both: nothing to undo, both versions stay as notes.
  Future<void> keepBoth(BuildContext context, int ref) async {
    final messenger = ScaffoldMessenger.of(context);
    await beforeChange();
    await resolver.keepBoth(ref);
    await afterChange();
    NoticeSnackBar.show(messenger, AppCopy.keptBothVersions, long: true);
  }

  Future<void> _withUndo(
    BuildContext context,
    Future<Future<void> Function()> Function() choose,
    String message,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    await beforeChange();
    final undo = await choose();
    await afterChange();
    UndoSnackBar.show(
      messenger,
      message: message,
      onUndo: () => unawaited(_undo(undo)),
    );
  }

  Future<void> _undo(Future<void> Function() undo) async {
    await beforeChange();
    await undo();
    await afterChange();
  }
}
