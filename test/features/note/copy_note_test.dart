import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app_harness.dart';

void main() {
  late AppHarness app;
  String? copied;

  setUp(() {
    app = AppHarness();
    copied = null;
  });

  void captureClipboard(WidgetTester tester) {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
  }

  testWidgets('copy puts the note on the clipboard as the user sees it', (
    tester,
  ) async {
    captureClipboard(tester);
    await app.storage.notes.create(
      'Groceries\n- [ ] milk\n- [x] **fresh** eggs\nsee [[n1|Time Loop]]',
    );
    await app.pump(tester);
    await tester.tap(find.text('Groceries'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Copy note'));
    await tester.pumpAndSettle();
    expect(copied, 'Groceries\n☐ milk\n☑ fresh eggs\nsee Time Loop');
    expect(find.text('Copied'), findsOneWidget);
    await app.finish(tester);
  });

  testWidgets('nothing to copy in an empty new note', (tester) async {
    await app.pump(tester);
    await tester.tap(find.text('New note'));
    await tester.pumpAndSettle();
    final button = find.byTooltip('Copy note');
    expect(button, findsOneWidget);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.text('Copied'), findsNothing);
    await app.finish(tester);
  });
}
