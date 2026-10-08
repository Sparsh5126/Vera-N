import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../copy/app_copy.dart';
import '../models/locked_folder.dart';
import '../platform/device_lock.dart';

/// Whether the Locked folder is open: after the phone's lock, until the
/// app has been away longer than [LockedFolder.relockAfter] (so a quick
/// trip to the camera to attach a photo doesn't lock it again).
final lockedSessionProvider = NotifierProvider<LockedSession, bool>(
  LockedSession.new,
);

class LockedSession extends Notifier<bool> {
  DateTime? _hiddenAt;

  @override
  bool build() {
    final listener = AppLifecycleListener(
      onHide: () => _hiddenAt = DateTime.now(),
      onShow: _back,
    );
    ref.onDispose(listener.dispose);
    return false;
  }

  void _back() {
    final hiddenAt = _hiddenAt;
    _hiddenAt = null;
    if (hiddenAt == null) return;
    if (DateTime.now().difference(hiddenAt) > LockedFolder.relockAfter) {
      state = false;
    }
  }

  /// Asks for the phone's lock unless the folder is already open.
  Future<UnlockResult> open() async {
    if (state) return UnlockResult.unlocked;
    final result = await ref
        .read(deviceLockProvider)
        .unlock(AppCopy.unlockReason);
    if (result == UnlockResult.unlocked) state = true;
    return result;
  }

  /// "Lock now".
  void close() => state = false;
}
