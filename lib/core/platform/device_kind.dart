import 'package:flutter/foundation.dart';

/// Phone or laptop, for the few features that differ (docs/LAPTOP_PLAN.md):
/// reminders are a phone-only feature; analysis on a laptop runs inside
/// the app instead of as scheduled background work.
abstract final class DeviceKind {
  static bool get isPhone =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  static bool get isDesktop =>
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux;
}
