import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Dart side of the Android `vera_n/launch` bridge (`LaunchBridge.kt`):
/// capture entry points, startup timing and the app version.
abstract final class LaunchChannel {
  static const _channel = MethodChannel('vera_n/launch');
  static var _typingReadyLogged = false;

  /// Calls [onNewNote] when a capture entry point is used while the app is
  /// already running (a cold start opens the new note route directly), and
  /// [onWindowFocused] the first time the app's window gets input focus.
  static void listen({
    required VoidCallback onNewNote,
    required VoidCallback onWindowFocused,
  }) {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'newNote':
          onNewNote();
        case 'windowFocused':
          onWindowFocused();
      }
    });
  }

  /// Logs, once per process, how long it took from process start until a
  /// new note had a typing cursor. Profile and debug builds only; the log
  /// stays on the device (`adb logcat`), nothing is sent anywhere.
  static Future<void> logTypingReady() async {
    if (kReleaseMode || _typingReadyLogged) return;
    _typingReadyLogged = true;
    try {
      final ms = await _channel.invokeMethod<int>('sinceProcessStart');
      if (ms != null) debugPrint('VeraN startup: $ms ms to typing cursor');
    } on MissingPluginException {
      // Not on Android (tests, desktop): nothing to measure.
    }
  }

  /// The installed version (e.g. "0.1.0"), or null off Android.
  static Future<String?> version() async {
    try {
      return await _channel.invokeMethod<String>('versionName');
    } on MissingPluginException {
      return null;
    }
  }
}
