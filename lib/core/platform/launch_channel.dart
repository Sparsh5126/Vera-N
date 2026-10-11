import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Home-screen widgets the app can ask the launcher to add.
enum CaptureWidgetKind { bar, button }

/// Dart side of the Android `vera_n/launch` bridge (`LaunchBridge.kt`):
/// capture and shortcut entry points, the add prompts for widgets and the
/// tile, opening links, startup timing and the app version.
abstract final class LaunchChannel {
  static const _channel = MethodChannel('vera_n/launch');
  static var _typingReadyLogged = false;

  /// Calls [onOpen] with a route when an entry point (shortcut, widget,
  /// tile) is used while the app is already running (a cold start opens
  /// that route directly), and [onWindowFocused] the first time the app's
  /// window gets input focus.
  static void listen({
    required ValueChanged<String> onOpen,
    required VoidCallback onWindowFocused,
  }) {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'open':
          onOpen(call.arguments as String);
        case 'windowFocused':
          onWindowFocused();
      }
    });
  }

  /// Shows the "Review connections" app shortcut only while suggestions
  /// are waiting (UI spec §5).
  static Future<void> setReviewShortcut({required bool waiting}) =>
      _call<void>('setReviewShortcut', waiting);

  /// Asks the launcher to add a widget. False if it can't ask (older
  /// Android, or a launcher without the prompt).
  static Future<bool> addWidget(CaptureWidgetKind kind) async =>
      await _call<bool>('addWidget', kind.name) ?? false;

  /// Asks to add the Quick Settings tile (Android 13+). False otherwise.
  static Future<bool> addTile() async => await _call<bool>('addTile') ?? false;

  /// Logs, once per process, how long it took from process start until a
  /// new note had a typing cursor. Profile and debug builds only; the log
  /// stays on the device (`adb logcat`), nothing is sent anywhere.
  static Future<void> logTypingReady() async {
    if (kReleaseMode || _typingReadyLogged) return;
    _typingReadyLogged = true;
    final ms = await _call<int>('sinceProcessStart');
    if (ms != null) debugPrint('VeraN startup: $ms ms to typing cursor');
  }

  /// Opens a web address in the browser. False if nothing could open it.
  static Future<bool> openLink(String url) async =>
      await _call<bool>('openLink', url) ?? false;

  /// The installed version (e.g. "0.1.0"), or null off Android.
  static Future<String?> version() => _call<String>('versionName');

  /// Null off Android (tests, desktop), where there is no bridge.
  static Future<T?> _call<T>(String method, [Object? arguments]) async {
    try {
      return await _channel.invokeMethod<T>(method, arguments);
    } on MissingPluginException {
      return null;
    }
  }
}
