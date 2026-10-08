import 'package:flutter/material.dart';

import '../../core/copy/app_copy.dart';
import '../../core/styles/app_styles.dart';

/// The one way to offer Undo after an action (instead of asking first).
/// On tab screens without a floating button, pass [aboveNavBar].
///
/// For an action that can't be taken back once done (deleting a file for
/// good), do it in [onExpired]: it runs when the message goes away without
/// Undo (timed out, swiped away, or replaced by another message).
abstract final class UndoSnackBar {
  static void show(
    ScaffoldMessengerState messenger, {
    required String message,
    required VoidCallback onUndo,
    bool aboveNavBar = false,
    VoidCallback? onExpired,
  }) {
    messenger.hideCurrentSnackBar();
    final shown = messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: AppMotion.undoWindow,
        // Flutter keeps a snackbar with an action until dismissed unless
        // told otherwise; Undo should leave on its own.
        persist: false,
        // Tab screens without a floating button would otherwise show it
        // under the floating nav bar.
        margin: aboveNavBar ? AppSpace.aboveNavBar : null,
        action: SnackBarAction(label: AppCopy.undo, onPressed: onUndo),
      ),
    );
    if (onExpired == null) return;
    shown.closed.then((reason) {
      if (reason != SnackBarClosedReason.action) onExpired();
    });
  }
}
