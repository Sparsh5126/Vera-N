import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/models/note_reminder.dart';
import '../../../core/reminders/reminder_parser.dart';
import '../../../core/reminders/reminder_providers.dart';
import '../../../core/settings/app_prefs_controller.dart';
import '../../../core/styles/app_styles.dart';
import '../../../core/utils/date_label.dart';
import '../../../shared/widgets/section_label.dart';

/// Below the text (never while typing): the reminders this note's
/// "remind me" lines set, or why one isn't set ("Add a time, like 'at
/// 9 am'"), so a reminder never fails silently. Hidden while "Reminders
/// from notes" is off.
class NoteReminders extends ConsumerWidget {
  const NoteReminders({super.key, required this.body, required this.written});

  final String body;

  /// When the note last changed: "tomorrow" counts from then.
  final DateTime written;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(appPrefsProvider.select((p) => p.reminders))) {
      return const SizedBox.shrink();
    }
    final now = DateTime.now();
    final found = ReminderParser.find(body, written, now: now);
    if (found.isEmpty) return const SizedBox.shrink();
    final allowed = ref.watch(notificationsAllowedProvider).value ?? true;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpace.s,
        children: [
          const SectionLabel(AppCopy.remindersHeading),
          for (final r in found) _row(context, r, now),
          if (!allowed && found.any((r) => r.isSet))
            Text(AppCopy.notificationsOff, style: context.textStyles.small),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, NoteReminder r, DateTime now) {
    final colors = context.colors;
    final at = r.at;
    final label = at != null
        ? AppCopy.reminderOn(DateLabel.reminder(at, now))
        : r.issue == ReminderIssue.past
        ? AppCopy.reminderPast
        : AppCopy.reminderNeedsTime;
    return Row(
      spacing: AppSpace.s,
      children: [
        Icon(
          at != null ? Icons.alarm : Icons.alarm_off,
          size: AppSize.iconSmall,
          color: at != null ? colors.text : colors.textSecondary,
        ),
        Expanded(
          child: Text(
            label,
            style: at != null
                ? context.textStyles.body
                : context.textStyles.small,
          ),
        ),
      ],
    );
  }
}
