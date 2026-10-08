import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/settings/app_prefs_controller.dart';
import '../../../core/storage/storage_providers.dart';

final onboardingControllerProvider = Provider<OnboardingController>(
  OnboardingController.new,
);

/// Onboarding decisions (UI spec §4). Every step can be skipped, and the
/// user always ends up able to write. Onboarding counts as done only after
/// the last step, so leaving halfway shows it again next time.
class OnboardingController {
  OnboardingController(this._ref);

  final Ref _ref;

  /// Whether the notes folder step is offered (Android only).
  bool get canChooseFolder => _ref.read(storageProvider).canChooseFolder;

  /// Opens the system folder picker and moves notes there. False if the
  /// user backed out, so they can pick again or choose "Not now".
  Future<bool> chooseFolder() => _ref.read(storageProvider).chooseFolder();

  /// The last step: keeps the name (if any; empty means skipped) for the
  /// greeting, and marks onboarding as done.
  Future<void> finish({String? name}) async {
    final typed = name?.trim();
    if (typed != null && typed.isNotEmpty) {
      await _ref
          .read(appPrefsProvider.notifier)
          .update((p) => p.copyWith(name: () => typed));
    }
    await _ref.read(storageProvider).settings.setOnboardingDone();
  }
}
