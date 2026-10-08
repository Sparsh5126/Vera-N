import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../copy/app_copy.dart';

/// One reminder to show: when, for which note, and the words to show.
@immutable
class ScheduledReminder {
  const ScheduledReminder({
    required this.id,
    required this.noteRef,
    required this.at,
    required this.body,
  });

  final int id;
  final int noteRef;
  final DateTime at;
  final String body;
}

/// The phone's notifications, for reminders only (product spec §10a). An
/// interface, so tests use a fake.
abstract interface class ReminderNotifications {
  /// Sets up the plugin. [onOpen] gets the note of a reminder the user
  /// tapped, also when the tap started the app.
  Future<void> init(ValueChanged<int> onOpen);

  /// Whether notifications are allowed for the app.
  Future<bool> allowed();

  /// Asks the user (Android's own prompt). True if allowed.
  Future<bool> askToAllow();

  /// Whether reminders can come at the exact minute (Android 14 asks the
  /// user for this in system settings); otherwise they may be minutes late.
  Future<bool> exactAllowed();

  /// Opens the system page that allows exact timing.
  Future<void> askExact();

  Future<Set<int>> scheduledIds();

  Future<void> schedule(ScheduledReminder reminder);

  Future<void> cancel(int id);

  Future<void> cancelAll();
}

final reminderNotificationsProvider = Provider<ReminderNotifications>(
  (ref) => DeviceReminderNotifications(),
);

/// [ReminderNotifications] through `flutter_local_notifications`.
class DeviceReminderNotifications implements ReminderNotifications {
  final _plugin = FlutterLocalNotificationsPlugin();

  static const _channel = 'reminders';
  static const _payloadPrefix = 'note:';

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  Future<void> init(ValueChanged<int> onOpen) async {
    void open(String? payload) {
      final ref = int.tryParse(payload?.replaceFirst(_payloadPrefix, '') ?? '');
      if (ref != null) onOpen(ref);
    }

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (r) => open(r.payload),
    );
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      open(launch!.notificationResponse?.payload);
    }
  }

  @override
  Future<bool> allowed() async =>
      await _android?.areNotificationsEnabled() ?? false;

  @override
  Future<bool> askToAllow() async =>
      await _android?.requestNotificationsPermission() ?? false;

  @override
  Future<bool> exactAllowed() async =>
      await _android?.canScheduleExactNotifications() ?? false;

  @override
  Future<void> askExact() async => _android?.requestExactAlarmsPermission();

  @override
  Future<Set<int>> scheduledIds() async => {
    for (final p in await _plugin.pendingNotificationRequests()) p.id,
  };

  @override
  Future<void> schedule(ScheduledReminder r) async {
    await _plugin.zonedSchedule(
      id: r.id,
      title: AppCopy.reminderTitle,
      body: r.body,
      // An instant in time, so the phone's time zone needs no lookup.
      scheduledDate: tz.TZDateTime.from(r.at.toUtc(), tz.UTC),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channel,
          AppCopy.remindersChannel,
          importance: Importance.high,
          priority: Priority.high,
          // On a locked screen: "Reminder" only, the words hidden.
          visibility: NotificationVisibility.private,
          category: AndroidNotificationCategory.reminder,
        ),
      ),
      androidScheduleMode: await exactAllowed()
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      payload: '$_payloadPrefix${r.noteRef}',
    );
  }

  @override
  Future<void> cancel(int id) => _plugin.cancel(id: id);

  @override
  Future<void> cancelAll() => _plugin.cancelAll();
}
