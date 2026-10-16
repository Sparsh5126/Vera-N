import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/storage/storage_providers.dart';
import '../../../shared/widgets/setting_row.dart';
import '../state/settings_controller.dart';
import 'settings_group.dart';
import 'sync_row.dart';

/// SYNC: where notes live (tapping opens the folder picker; notes move to
/// the chosen folder), and built-in sync with the other device.
class FolderSection extends ConsumerWidget {
  const FolderSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canChoose = ref.watch(storageProvider).canChooseFolder;
    final name = ref.watch(notesFolderNameProvider).value;
    final settings = ref.read(settingsControllerProvider);
    return SettingsGroup(
      label: AppCopy.sectionSync,
      children: [
        if (canChoose)
          SettingRow(
            label: AppCopy.notesFolder,
            value: name ?? AppCopy.notesFolderNone,
            hint: name == null ? AppCopy.notesFolderNoneHint : null,
            onTap: () => unawaited(settings.chooseFolder()),
          ),
        const SyncRow(),
      ],
    );
  }
}
