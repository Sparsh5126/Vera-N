import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/platform/launch_channel.dart';
import '../../../shared/widgets/notice_snack_bar.dart';
import '../../../shared/widgets/option_sheet.dart';
import '../../../shared/widgets/setting_row.dart';

enum _Capture { bar, button, tile }

/// "Quick capture: Widget and tile ›" (UI spec §5, §11). Opens a short
/// list using Android's own add prompts; nothing is added automatically
/// and the app never asks on its own. Where the prompt isn't available,
/// a short line says how to add it by hand. Android only.
class QuickCaptureRow extends StatelessWidget {
  const QuickCaptureRow({super.key});

  Future<void> _choose(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final picked = await OptionSheet.show<_Capture>(
      context,
      selected: null,
      options: const [
        SheetOption(_Capture.bar, AppCopy.addQuickNoteBar),
        SheetOption(_Capture.button, AppCopy.addNewNoteButton),
        SheetOption(_Capture.tile, AppCopy.addQuickSettingsTile),
      ],
    );
    final choice = picked?.value;
    if (choice == null) return;
    final asked = switch (choice) {
      _Capture.bar => await LaunchChannel.addWidget(CaptureWidgetKind.bar),
      _Capture.button => await LaunchChannel.addWidget(
        CaptureWidgetKind.button,
      ),
      _Capture.tile => await LaunchChannel.addTile(),
    };
    if (asked) return;
    NoticeSnackBar.show(
      messenger,
      choice == _Capture.tile ? AppCopy.addTileByHand : AppCopy.addWidgetByHand,
      long: true,
      aboveNavBar: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return const SizedBox.shrink();
    }
    return SettingRow(
      label: AppCopy.quickCapture,
      value: AppCopy.quickCaptureValue,
      onTap: () => unawaited(_choose(context)),
    );
  }
}
