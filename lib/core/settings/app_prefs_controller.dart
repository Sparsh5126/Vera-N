import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_prefs.dart';
import '../storage/storage_providers.dart';

/// The saved choices, read once at start (`main.dart` overrides this so
/// the first frame already has the right theme and layout).
final initialPrefsProvider = Provider<AppPrefs>((ref) => const AppPrefs());

/// The user's Settings choices. A change shows at once and is saved.
final appPrefsProvider = NotifierProvider<AppPrefsController, AppPrefs>(
  AppPrefsController.new,
);

/// Whether suggestions are on ("Suggest connections"). When off, no
/// suggestion appears anywhere: not on Home, in notes, or in Review.
final suggestionsOnProvider = Provider<bool>(
  (ref) => ref.watch(appPrefsProvider.select((p) => p.suggestions)),
);

class AppPrefsController extends Notifier<AppPrefs> {
  @override
  AppPrefs build() => ref.watch(initialPrefsProvider);

  Future<void> update(AppPrefs Function(AppPrefs) change) async {
    state = change(state);
    await ref.read(settingsRepositoryProvider).savePrefs(state);
  }
}
