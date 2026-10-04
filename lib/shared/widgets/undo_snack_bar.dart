import 'package:flutter/material.dart';

import '../../core/copy/app_copy.dart';
import '../../core/styles/app_styles.dart';

/// The one way to offer Undo after an action (instead of asking first).
abstract final class UndoSnackBar {
  static void show(
    ScaffoldMessengerState messenger, {
    required String message,
    required VoidCallback onUndo,
  }) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: AppMotion.undoWindow,
          // Flutter keeps a snackbar with an action until dismissed unless
          // told otherwise; Undo should leave on its own.
          persist: false,
          action: SnackBarAction(label: AppCopy.undo, onPressed: onUndo),
        ),
      );
  }
}
