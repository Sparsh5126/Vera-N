import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../platform/reminder_notifications.dart';
import '../storage/storage_providers.dart';
import 'reminder_sync.dart';

final reminderSyncProvider = Provider<ReminderSync>((ref) {
  final storage = ref.watch(storageProvider);
  final sync = ReminderSync(
    storage.notes,
    storage.settings,
    ref.watch(reminderNotificationsProvider),
    onAsked: () => ref.read(notificationsRecheckProvider.notifier).recheck(),
  );
  ref.onDispose(sync.dispose);
  return sync;
});

/// Bumped when notification access may have changed: after the prompt was
/// answered, and whenever the app comes back to the front (the user may
/// have changed it in system settings).
final notificationsRecheckProvider =
    NotifierProvider<NotificationsRecheck, int>(NotificationsRecheck.new);

class NotificationsRecheck extends Notifier<int> {
  @override
  int build() => 0;

  void recheck() => state++;
}

/// Whether the app may show notifications (a note's reminder says so when
/// not). Checked again on every [notificationsRecheckProvider] bump.
final notificationsAllowedProvider = FutureProvider.autoDispose<bool>((ref) {
  ref.watch(notificationsRecheckProvider);
  return ref.watch(reminderNotificationsProvider).allowed();
});

/// Whether reminders can come at the exact minute (Settings).
final exactRemindersProvider = FutureProvider.autoDispose<bool>((ref) {
  ref.watch(notificationsRecheckProvider);
  return ref.watch(reminderNotificationsProvider).exactAllowed();
});
