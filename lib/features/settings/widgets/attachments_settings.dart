import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/models/attachment_usage.dart';
import '../../../core/settings/app_prefs_controller.dart';
import '../../../core/storage/storage_providers.dart';
import '../../../shared/widgets/setting_row.dart';
import '../../../shared/widgets/undo_snack_bar.dart';
import '../state/settings_controller.dart';

final _usageProvider = FutureProvider.autoDispose<AttachmentUsage>(
  (ref) => ref.watch(attachmentsRepositoryProvider).usage(),
);

/// Attachments in DATA (decided 2026-10-08, user): the room they take,
/// "Remove unused attachments" with Undo (files go only once the Undo
/// message is gone), and the optional automatic clean-up, off by default.
class AttachmentsSettings extends ConsumerStatefulWidget {
  const AttachmentsSettings({super.key});

  @override
  ConsumerState<AttachmentsSettings> createState() =>
      _AttachmentsSettingsState();
}

class _AttachmentsSettingsState extends ConsumerState<AttachmentsSettings> {
  /// Removed, waiting for the Undo message to go away.
  var _removing = <String>{};

  void _removeUnused(List<String> names) {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _removing = names.toSet());
    UndoSnackBar.show(
      messenger,
      message: AppCopy.unusedRemoved(names.length),
      aboveNavBar: true,
      onUndo: () => setState(() => _removing = {}),
      onExpired: () => unawaited(_deleteForGood(names)),
    );
  }

  Future<void> _deleteForGood(List<String> names) async {
    await ref.read(attachmentsRepositoryProvider).delete(names);
    if (!mounted) return;
    setState(() => _removing = {});
    ref.invalidate(_usageProvider);
  }

  @override
  Widget build(BuildContext context) {
    final usage = ref.watch(_usageProvider).value ?? AttachmentUsage.none;
    final unused = [
      for (final n in usage.unused)
        if (!_removing.contains(n)) n,
    ];
    final auto = ref.watch(appPrefsProvider).cleanAttachments;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingRow(
          label: AppCopy.attachments,
          value: AppCopy.fileSize(usage.bytes),
          hint: unused.isEmpty
              ? AppCopy.attachmentsAllUsed
              : AppCopy.attachmentsUnused(unused.length),
        ),
        if (unused.isNotEmpty)
          SettingRow(
            label: AppCopy.removeUnused,
            onTap: () => _removeUnused(unused),
          ),
        SwitchListTile(
          title: const Text(AppCopy.cleanAttachmentsAuto),
          subtitle: const Text(AppCopy.cleanAttachmentsHint),
          value: auto,
          onChanged: (on) => unawaited(
            ref
                .read(settingsControllerProvider)
                .change((p) => p.copyWith(cleanAttachments: on)),
          ),
        ),
      ],
    );
  }
}
