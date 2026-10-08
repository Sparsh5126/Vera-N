import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/models/app_prefs.dart';
import '../../../core/settings/app_prefs_controller.dart';
import '../../../shared/widgets/setting_choice.dart';
import '../../../shared/widgets/setting_row.dart';
import '../../../shared/widgets/text_entry_sheet.dart';
import '../state/settings_controller.dart';
import 'quick_capture_row.dart';
import 'settings_group.dart';

/// YOU and APP: name, layout, where the app opens, theme, and quick
/// capture (widgets and tile).
class AppSection extends ConsumerWidget {
  const AppSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(appPrefsProvider);
    final settings = ref.read(settingsControllerProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsGroup(
          label: AppCopy.sectionYou,
          children: [
            SettingRow(
              label: AppCopy.name,
              value: prefs.name,
              onTap: () => unawaited(_editName(context, settings, prefs.name)),
            ),
          ],
        ),
        SettingsGroup(
          label: AppCopy.sectionApp,
          children: [
            SettingChoice<NotesLayout>(
              label: AppCopy.layout,
              options: const {
                NotesLayout.grid: AppCopy.layoutGrid,
                NotesLayout.list: AppCopy.layoutList,
              },
              selected: prefs.layout,
              onChanged: (v) => settings.change((p) => p.copyWith(layout: v)),
            ),
            SettingChoice<StartPage>(
              label: AppCopy.openAppTo,
              options: const {
                StartPage.home: AppCopy.startHome,
                StartPage.newNote: AppCopy.startNewNote,
              },
              selected: prefs.startPage,
              onChanged: (v) =>
                  settings.change((p) => p.copyWith(startPage: v)),
            ),
            SettingChoice<ThemeChoice>(
              label: AppCopy.theme,
              options: const {
                ThemeChoice.system: AppCopy.themeSystem,
                ThemeChoice.dark: AppCopy.themeDark,
                ThemeChoice.light: AppCopy.themeLight,
              },
              selected: prefs.theme,
              onChanged: (v) => settings.change((p) => p.copyWith(theme: v)),
            ),
            const QuickCaptureRow(),
          ],
        ),
      ],
    );
  }

  Future<void> _editName(
    BuildContext context,
    SettingsController settings,
    String? current,
  ) async {
    final typed = await TextEntrySheet.show(
      context,
      hint: AppCopy.nameHint,
      initial: current ?? '',
      allowEmpty: true,
    );
    if (typed == null) return;
    await settings.change((p) => p.copyWith(name: () => typed));
  }
}
