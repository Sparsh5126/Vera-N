import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/platform/device_kind.dart';
import '../../../core/platform/reminder_notifications.dart';
import '../../../core/reminders/reminder_providers.dart';
import '../../../core/settings/app_prefs_controller.dart';
import '../../../shared/widgets/setting_row.dart';
import '../state/settings_controller.dart';

/// In SMART SUGGESTIONS, beside the other automatic features: "Reminders
/// from notes" (a note line saying "remind me" with a date and time), and
/// while it is on, whether reminders may come at the exact minute.
class ReminderSettings extends ConsumerWidget {
  const ReminderSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Reminders are a phone-only feature (docs/LAPTOP_PLAN.md).
    if (!DeviceKind.isPhone) return const SizedBox.shrink();
    final on = ref.watch(appPrefsProvider.select((p) => p.reminders));
    final exact = ref.watch(exactRemindersProvider).value ?? true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          title: const Text(AppCopy.remindersSetting),
          subtitle: const Text(AppCopy.remindersSettingHint),
          value: on,
          onChanged: (value) => unawaited(
            ref
                .read(settingsControllerProvider)
                .change((p) => p.copyWith(reminders: value)),
          ),
        ),
        if (on && !exact)
          SettingRow(
            label: AppCopy.onTimeReminders,
            value: AppCopy.onTimeAllow,
            hint: AppCopy.onTimeHint,
            onTap: () => unawaited(_allowExact(ref)),
          ),
      ],
    );
  }

  Future<void> _allowExact(WidgetRef ref) async {
    await ref.read(reminderNotificationsProvider).askExact();
    ref.invalidate(exactRemindersProvider);
  }
}
