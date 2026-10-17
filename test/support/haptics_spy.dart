import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records the haptics the app plays. They reach the platform as
/// `HapticFeedback.vibrate` calls carrying the type, for example
/// `HapticFeedbackType.selectionClick`.
class HapticsSpy {
  static const selectionClick = 'HapticFeedbackType.selectionClick';

  final played = <String>[];

  void attach(WidgetTester tester) {
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') {
        played.add(call.arguments as String);
      }
      return null;
    });
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );
  }
}
