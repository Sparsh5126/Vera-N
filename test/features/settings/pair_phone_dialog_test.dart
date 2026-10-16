import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vera_n/core/copy/app_copy.dart';
import 'package:vera_n/core/styles/app_styles.dart';
import 'package:vera_n/core/sync/pairing_code.dart';
import 'package:vera_n/core/sync/pairing_exchange.dart';
import 'package:vera_n/core/sync/sync_service.dart';
import 'package:vera_n/features/settings/widgets/pair_phone_dialog.dart';

void main() {
  const words = ['abandon', 'zoo', 'ability', 'able', 'acoustic', 'action'];
  const id = 'AAAAAAA-BBBBBBB-CCCCCCC-DDDDDDD-EEEEEEE-FFFFFFF-GGGGGGG-HHHHHHH';

  Future<Completer<PairedDevice?>> open(WidgetTester tester) async {
    final result = Completer<PairedDevice?>();
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: PairPhoneDialog(
            open: () async => PairingSession(
              invite: PairingInvite(
                code: PairingCode(words),
                laptopId: id,
                addresses: const ['192.168.1.5'],
                port: 51000,
              ),
              result: result.future,
              cancel: () async {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('shows the QR code and the six words, then "Paired"', (
    tester,
  ) async {
    final result = await open(tester);
    expect(tester.takeException(), isNull);
    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.text(words.join('  ')), findsOneWidget);
    expect(find.text(SyncCopy.waitingForPhone), findsOneWidget);
    result.complete(
      const PairedDevice(
        id: id,
        name: 'Phone',
        address: '192.168.1.9',
        syncPort: 22000,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(SyncCopy.pairedPhone), findsOneWidget);
    expect(find.byType(QrImageView), findsNothing);
  });

  testWidgets('a window that closes unused says the code expired', (
    tester,
  ) async {
    final result = await open(tester);
    result.complete(null);
    await tester.pumpAndSettle();
    expect(find.text(SyncCopy.codeExpired), findsOneWidget);
  });
}
