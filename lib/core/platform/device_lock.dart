import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

/// How asking for the phone's lock went.
enum UnlockResult { unlocked, cancelled, noScreenLock }

/// The phone's own lock (fingerprint, face, PIN or pattern) through the
/// system prompt, for the Locked folder. An interface, so tests use a
/// fake.
abstract interface class DeviceLock {
  /// Whether the phone has a screen lock at all.
  Future<bool> hasScreenLock();

  Future<UnlockResult> unlock(String reason);
}

final deviceLockProvider = Provider<DeviceLock>((ref) => SystemDeviceLock());

/// [DeviceLock] through Android's system prompt.
class SystemDeviceLock implements DeviceLock {
  final _auth = LocalAuthentication();

  @override
  Future<bool> hasScreenLock() async {
    try {
      return await _auth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<UnlockResult> unlock(String reason) async {
    if (!await hasScreenLock()) return UnlockResult.noScreenLock;
    try {
      final ok = await _auth.authenticate(localizedReason: reason);
      return ok ? UnlockResult.unlocked : UnlockResult.cancelled;
    } on LocalAuthException {
      return UnlockResult.cancelled;
    } on PlatformException {
      return UnlockResult.cancelled;
    }
  }
}
