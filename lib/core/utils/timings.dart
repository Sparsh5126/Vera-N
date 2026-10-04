/// Behavior timings that aren't animation (motion lives in app_styles.dart).
abstract final class AppTimings {
  /// Pause in typing before the text is saved to the database. Leaving the
  /// note or the app saves at once, so a longer pause loses nothing; it
  /// keeps saves (and the work they cause) out of fast typing.
  static const saveAfterTyping = Duration(milliseconds: 1000);
}
