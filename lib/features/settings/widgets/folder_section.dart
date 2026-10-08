import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/storage/storage_providers.dart';
import '../../../shared/widgets/setting_row.dart';
import '../state/settings_controller.dart';
import 'settings_group.dart';

/// SYNC: where notes live. Tapping opens the folder picker; notes move to
/// the chosen folder. Hidden where folders can't be picked (desktop).
class FolderSection extends ConsumerWidget {
  const FolderSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(storageProvider).canChooseFolder) {
      return const SizedBox.shrink();
    }
    final name = ref.watch(notesFolderNameProvider).value;
    final settings = ref.read(settingsControllerProvider);
    return SettingsGroup(
      label: AppCopy.sectionSync,
      children: [
        SettingRow(
          label: AppCopy.notesFolder,
          value: name ?? AppCopy.notesFolderNone,
          hint: name == null ? AppCopy.notesFolderNoneHint : null,
          onTap: () => unawaited(settings.chooseFolder()),
        ),
      ],
    );
  }
}
