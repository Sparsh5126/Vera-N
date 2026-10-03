/// Behavior timings that aren't animation (motion lives in app_styles.dart).
abstract final class AppTimings {
  /// Pause in typing before the text is saved to the database.
  static const saveAfterTyping = Duration(milliseconds: 300);
}
