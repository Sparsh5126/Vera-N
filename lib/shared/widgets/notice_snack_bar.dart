import 'package:flutter/material.dart';

import '../../core/styles/app_styles.dart';

/// A brief confirmation with nothing to tap, e.g. "Copied".
abstract final class NoticeSnackBar {
  static void show(ScaffoldMessengerState messenger, String message) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: AppMotion.briefNotice),
      );
  }
}
