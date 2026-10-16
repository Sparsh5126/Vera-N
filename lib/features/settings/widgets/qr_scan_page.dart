import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/styles/app_styles.dart';
import '../../../core/sync/pairing_code.dart';

/// Scans the laptop's pairing QR code (docs/LAPTOP_PLAN.md, S2) with the
/// camera, decoded on the phone (zxing-cpp; nothing leaves the phone).
/// Returns the first Vera N code it sees, or null when closed.
class QrScanPage extends StatelessWidget {
  const QrScanPage({super.key});

  static Future<String?> open(BuildContext context) => Navigator.of(
    context,
    rootNavigator: true,
  ).push<String>(MaterialPageRoute(builder: (_) => const QrScanPage()));

  static const _prefix = 'veran-pair:';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(SyncCopy.scanCode)),
      body: Stack(
        children: [
          ReaderWidget(
            codeFormat: Format.qrCode,
            showGallery: false,
            showToggleCamera: false,
            // A code on a laptop screen: look at most of the picture, try
            // harder, and often, while this page is open.
            cropPercent: PairingInvite.scanShare,
            tryHarder: true,
            scanDelay: PairingInvite.scanEvery,
            scanDelaySuccess: PairingInvite.scanEvery,
            onScan: (code) {
              final text = code.text;
              // Only once: a second read must not close the sheet below.
              final open = ModalRoute.of(context)?.isCurrent ?? false;
              if (open &&
                  code.isValid &&
                  text != null &&
                  text.startsWith(_prefix)) {
                Navigator.of(context).pop(text);
              }
            },
          ),
          SafeArea(
            child: Padding(
              padding: AppSpace.screen,
              child: Text(SyncCopy.pointCamera, style: context.textStyles.body),
            ),
          ),
        ],
      ),
    );
  }
}
