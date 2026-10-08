import 'package:flutter/material.dart';

import '../../core/styles/app_styles.dart';

/// A brief confirmation with nothing to tap, e.g. "Copied". A [long]
/// one stays as long as an Undo would, for a sentence to read. On tab
/// screens without a floating button, pass [aboveNavBar].
abstract final class NoticeSnackBar {
  static void show(
    ScaffoldMessengerState messenger,
    String message, {
    bool long = false,
    bool aboveNavBar = false,
  }) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: long ? AppMotion.undoWindow : AppMotion.briefNotice,
          margin: aboveNavBar ? AppSpace.aboveNavBar : null,
        ),
      );
  }
}
