import 'package:flutter/foundation.dart';
import 'package:vera_n/core/platform/reminder_notifications.dart';

/// [ReminderNotifications] without the phone: keeps what is scheduled.
class FakeReminderNotifications implements ReminderNotifications {
  final scheduled = <int, ScheduledReminder>{};
  bool notificationsAllowed = false;
  bool exact = true;
  var asked = 0;
  ValueChanged<int>? onOpen;

  @override
  Future<void> init(ValueChanged<int> onOpen) async => this.onOpen = onOpen;

  @override
  Future<bool> allowed() async => notificationsAllowed;

  @override
  Future<bool> askToAllow() async {
    asked++;
    return notificationsAllowed = true;
  }

  @override
  Future<bool> exactAllowed() async => exact;

  @override
  Future<void> askExact() async => exact = true;

  @override
  Future<Set<int>> scheduledIds() async => scheduled.keys.toSet();

  @override
  Future<void> schedule(ScheduledReminder r) async => scheduled[r.id] = r;

  @override
  Future<void> cancel(int id) async => scheduled.remove(id);

  @override
  Future<void> cancelAll() async => scheduled.clear();
}
