import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ai/scheduler/analysis_scheduler.dart';
import '../../../core/ai/suggestions/suggestion_actions.dart';
import '../../../core/models/app_prefs.dart';
import '../../../core/platform/launch_channel.dart';
import '../../../core/settings/app_prefs_controller.dart';
import '../../../core/storage/storage_providers.dart';
import '../../../core/storage/storage_services.dart';

/// The notes folder's name, or null while notes are only on this phone.
final notesFolderNameProvider = FutureProvider.autoDispose<String?>(
  (ref) => ref.watch(storageProvider).notesFolderName(),
);

/// The installed version, or null where it can't be read.
final appVersionProvider = FutureProvider<String?>(
  (ref) => LaunchChannel.version(),
);

final settingsControllerProvider = Provider<SettingsController>(
  SettingsController.new,
);

/// What the Settings rows do. Choices save at once; the two "Advanced"
/// actions return an [Undo] instead of asking first.
class SettingsController {
  SettingsController(this._ref);

  final Ref _ref;

  StorageServices get _storage => _ref.read(storageProvider);

  Future<void> change(AppPrefs Function(AppPrefs) edit) =>
      _ref.read(appPrefsProvider.notifier).update(edit);

  /// "Suggest connections". Off stops any waiting analysis at once.
  Future<void> setSuggestions(bool on) async {
    await change((p) => p.copyWith(suggestions: on));
    if (!on) await AnalysisScheduler.cancel();
  }

  /// Opens the folder picker; notes move to the chosen folder.
  Future<void> chooseFolder() async {
    if (await _storage.chooseFolder()) {
      _ref.invalidate(notesFolderNameProvider);
    }
  }

  /// Clears waiting suggestions and matches every note again on the next
  /// run. Stored vectors are reused, so this costs little battery.
  Future<Undo> rebuildSuggestions() async {
    final waiting = await _storage.suggestions.pending();
    await _storage.suggestions.clear();
    await _storage.analysis.forgetAll();
    return () async {
      for (final s in waiting) {
        await _storage.suggestions.putBack(s);
      }
    };
  }

  /// Forgets every rejection, so those pairs may be suggested again.
  Future<Undo> resetRejected() async {
    final settings = _storage.settings;
    final rejections = _storage.rejections;
    final kept = await rejections.all();
    await rejections.clear(await settings.deviceId());
    await _storage.analysis.forgetAll();
    return () async {
      for (final r in kept) {
        await rejections.add(r);
      }
    };
  }
}
