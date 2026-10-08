import 'package:flutter/services.dart';

/// Dart side of the Android `vera_n/export` bridge (`ExportBridge.kt`):
/// saves a file where the user picks, with Android's "save as" screen.
abstract final class ExportChannel {
  static const _channel = MethodChannel('vera_n/export');

  /// True once saved, false if the user backed out, null where saving
  /// this way isn't available (desktop, tests). Throws [PlatformException]
  /// if writing failed.
  static Future<bool?> save({
    required String filePath,
    required String name,
    required String mime,
  }) async {
    try {
      return await _channel.invokeMethod<bool>('save', {
        'file': filePath,
        'name': name,
        'mime': mime,
      });
    } on MissingPluginException {
      return null;
    }
  }
}
