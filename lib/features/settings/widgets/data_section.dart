import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/navigation/routes.dart';
import '../../../shared/widgets/notice_snack_bar.dart';
import '../../../shared/widgets/setting_row.dart';
import '../state/settings_controller.dart';
import 'attachments_settings.dart';
import 'settings_group.dart';

/// DATA: the trash (kept 30 days), attachments and their clean-up, and
/// exporting every note as a Markdown .zip, saved where the user picks
/// (Android).
class DataSection extends ConsumerStatefulWidget {
  const DataSection({super.key});

  @override
  ConsumerState<DataSection> createState() => _DataSectionState();
}

class _DataSectionState extends ConsumerState<DataSection> {
  var _exporting = false;

  Future<void> _export() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _exporting = true);
    final outcome = await ref.read(settingsControllerProvider).exportNotes();
    if (mounted) setState(() => _exporting = false);
    final message = switch (outcome) {
      ExportOutcome.saved => AppCopy.exportSaved,
      ExportOutcome.failed => AppCopy.exportFailed,
      ExportOutcome.cancelled => null,
    };
    if (message != null) {
      NoticeSnackBar.show(messenger, message, aboveNavBar: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final android = defaultTargetPlatform == TargetPlatform.android;
    return SettingsGroup(
      label: AppCopy.sectionData,
      children: [
        SettingRow(
          label: AppCopy.trash,
          value: AppCopy.trashValue,
          onTap: () => context.push(Routes.trash),
        ),
        const AttachmentsSettings(),
        if (android)
          SettingRow(
            label: AppCopy.exportNotes,
            value: _exporting ? AppCopy.exporting : AppCopy.exportValue,
            onTap: _exporting ? null : () => unawaited(_export()),
          ),
      ],
    );
  }
}
