import 'dart:convert';
import 'dart:math';

import '../db/app_database.dart';

/// Per-device settings, kept in app-private storage (never synced).
class SettingsRepository {
  SettingsRepository(this._db, {Random? random})
    : _random = random ?? Random.secure();

  static const _notesFolder = 'notesFolder';
  static const _deviceId = 'deviceId';
  static const _onboardingDone = 'onboardingDone';
  static const _recentSearches = 'recentSearches';

  /// Recent searches kept, newest first.
  static const recentSearchLimit = 8;

  final AppDatabase _db;
  final Random _random;

  /// URI of the picked notes folder, or null for the in-app holding folder.
  Future<String?> notesFolder() => _get(_notesFolder);

  Future<void> setNotesFolder(String? uri) => _set(_notesFolder, uri);

  Future<bool> onboardingDone() async => await _get(_onboardingDone) == 'true';

  Future<void> setOnboardingDone() => _set(_onboardingDone, 'true');

  /// Searches the user ran recently, newest first. Kept on this device.
  Future<List<String>> recentSearches() async {
    final raw = await _get(_recentSearches);
    if (raw == null) return const [];
    return [for (final q in jsonDecode(raw) as List<dynamic>) q as String];
  }

  /// Puts [query] first, without duplicates (ignoring case and spaces).
  Future<void> addRecentSearch(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    final rest = (await recentSearches()).where(
      (r) => r.toLowerCase() != q.toLowerCase(),
    );
    final list = [q, ...rest].take(recentSearchLimit).toList();
    await _set(_recentSearches, jsonEncode(list));
  }

  Future<void> removeRecentSearch(String query) async {
    final list = (await recentSearches()).where((r) => r != query).toList();
    await _set(_recentSearches, jsonEncode(list));
  }

  /// A random id for this device, made once. Names this device's own
  /// files in `MyNotes/.app/` (for example its rejections file).
  Future<String> deviceId() async {
    final existing = await _get(_deviceId);
    if (existing != null) return existing;
    final id = List.generate(
      8,
      (_) => _random.nextInt(16).toRadixString(16),
    ).join();
    await _set(_deviceId, id);
    return id;
  }

  Future<String?> _get(String key) async {
    final row = await (_db.select(
      _db.settings,
    )..where((s) => s.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> _set(String key, String? value) async {
    if (value == null) {
      await (_db.delete(_db.settings)..where((s) => s.key.equals(key))).go();
      return;
    }
    await _db
        .into(_db.settings)
        .insertOnConflictUpdate(
          SettingsCompanion.insert(key: key, value: value),
        );
  }
}
