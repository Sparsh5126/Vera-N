import 'package:flutter/services.dart';

/// Dart side of the Android `vera_n/notes_folder` bridge
/// (`NotesFolderBridge.kt`): the system folder picker and file access
/// inside the picked folder.
class NotesFolderChannel {
  const NotesFolderChannel();

  static const _channel = MethodChannel('vera_n/notes_folder');

  /// Opens Android's folder picker. Returns the folder's URI, or null if
  /// the user backed out. Permission is kept across restarts.
  Future<String?> pick() => _channel.invokeMethod<String>('pick');

  Future<bool> hasAccess(String tree) async =>
      await call<bool>('hasAccess', tree) ?? false;

  Future<String?> displayName(String tree) => call<String>('displayName', tree);

  Future<T?> call<T>(
    String method,
    String tree, {
    String path = '',
    Map<String, Object?> extra = const {},
  }) {
    return _channel.invokeMethod<T>(method, {
      'tree': tree,
      'path': path,
      ...extra,
    });
  }
}
