import 'package:flutter/foundation.dart';

/// How Home shows notes (UI spec §11, Layout).
enum NotesLayout { grid, list }

/// Where the app opens when started from its icon (UI spec §11).
enum StartPage { home, newNote }

/// The app's colors: follow the system, or always dark or light.
enum ThemeChoice { system, dark, light }

/// The user's choices from Settings, kept on this device only.
@immutable
class AppPrefs {
  const AppPrefs({
    this.name,
    this.layout = NotesLayout.grid,
    this.startPage = StartPage.home,
    this.theme = ThemeChoice.system,
    this.suggestions = true,
    this.chargingOnly = true,
  });

  /// For the greeting; null when skipped.
  final String? name;
  final NotesLayout layout;
  final StartPage startPage;
  final ThemeChoice theme;

  /// "Suggest connections": off stops analysis and hides every suggestion.
  final bool suggestions;

  /// "Analyze only when charging": off also allows runs while the phone
  /// is idle with enough battery.
  final bool chargingOnly;

  AppPrefs copyWith({
    ValueGetter<String?>? name,
    NotesLayout? layout,
    StartPage? startPage,
    ThemeChoice? theme,
    bool? suggestions,
    bool? chargingOnly,
  }) {
    return AppPrefs(
      name: name == null ? this.name : name(),
      layout: layout ?? this.layout,
      startPage: startPage ?? this.startPage,
      theme: theme ?? this.theme,
      suggestions: suggestions ?? this.suggestions,
      chargingOnly: chargingOnly ?? this.chargingOnly,
    );
  }
}
