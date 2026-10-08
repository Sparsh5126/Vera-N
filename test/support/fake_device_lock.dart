import 'package:vera_n/core/platform/device_lock.dart';

/// [DeviceLock] without the system prompt: the phone has a screen lock and
/// the user unlocks, unless the test says otherwise.
class FakeDeviceLock implements DeviceLock {
  bool screenLock = true;
  bool accept = true;
  var prompts = 0;

  @override
  Future<bool> hasScreenLock() async => screenLock;

  @override
  Future<UnlockResult> unlock(String reason) async {
    if (!screenLock) return UnlockResult.noScreenLock;
    prompts++;
    return accept ? UnlockResult.unlocked : UnlockResult.cancelled;
  }
}
