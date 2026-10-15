import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/platform/device_kind.dart';
import '../../../core/settings/app_prefs_controller.dart';
import '../../../core/utils/date_label.dart';
import '../../../shared/widgets/setting_row.dart';
import '../state/settings_controller.dart';

/// When suggestions are looked for and when they last were (2026-10-15):
/// without it, "waiting for the charger" and "found nothing" look the same.
/// Plain words, no count.
class AnalysisStatusRow extends ConsumerWidget {
  const AnalysisStatusRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(appPrefsProvider);
    final last = ref.watch(lastAnalysisProvider).value;
    final when = DeviceKind.isDesktop
        ? AppCopy.looksOnLaptop
        : prefs.chargingOnly
        ? AppCopy.looksWhileCharging
        : AppCopy.looksWhileIdle;
    return SettingRow(
      label: when,
      value: last == null
          ? AppCopy.notLookedYet
          : AppCopy.lastLooked(DateLabel.of(last.toLocal(), DateTime.now())),
    );
  }
}
