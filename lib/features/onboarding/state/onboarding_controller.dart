import '../../../core/storage/storage_services.dart';

/// Onboarding decisions. Either way the user ends up able to write:
/// choosing a folder or "Not now" both finish this step.
class OnboardingController {
  OnboardingController(this._storage);

  final StorageServices _storage;

  /// Opens the system folder picker and moves notes there. False if the
  /// user backed out, so they can pick again or choose "Not now".
  Future<bool> chooseFolder() async {
    final chosen = await _storage.chooseFolder();
    if (chosen) await _storage.settings.setOnboardingDone();
    return chosen;
  }

  /// Keep notes inside the app for now; Settings can pick a folder later.
  Future<void> notNow() => _storage.settings.setOnboardingDone();
}
