import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/styles/app_styles.dart';
import '../../../core/sync/sync_service.dart';

/// The laptop's pairing window (docs/LAPTOP_PLAN.md, S2): a QR code and
/// the same code as six words, open for five minutes. Closing it ends the
/// window.
class PairPhoneDialog extends StatefulWidget {
  const PairPhoneDialog({super.key, required this.open});

  /// Opens the pairing window ([SyncService.hostPairing]).
  final Future<PairingSession> Function() open;

  static Future<void> show(BuildContext context, SyncService sync) =>
      showDialog<void>(
        context: context,
        builder: (_) => PairPhoneDialog(open: sync.hostPairing),
      );

  @override
  State<PairPhoneDialog> createState() => _PairPhoneDialogState();
}

enum _Stage { opening, waiting, paired, expired, failed }

class _PairPhoneDialogState extends State<PairPhoneDialog> {
  PairingSession? _session;
  var _stage = _Stage.opening;

  @override
  void initState() {
    super.initState();
    unawaited(_open());
  }

  Future<void> _open() async {
    try {
      final session = await widget.open();
      if (!mounted) return unawaited(session.cancel());
      setState(() {
        _session = session;
        _stage = _Stage.waiting;
      });
      final phone = await session.result;
      if (mounted) {
        setState(() => _stage = phone == null ? _Stage.expired : _Stage.paired);
      }
    } on Object {
      if (mounted) setState(() => _stage = _Stage.failed);
    }
  }

  @override
  void dispose() {
    unawaited(_session?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    final session = _session;
    return AlertDialog(
      scrollable: true,
      title: const Text(SyncCopy.pairPhoneTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSize.readableWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpace.m,
          children: [
            const Text(SyncCopy.pairPhoneBody),
            if (session != null && _stage == _Stage.waiting) ...[
              ColoredBox(
                color: AppQrColors.paper,
                child: Padding(
                  padding: AppSpace.card,
                  // A fixed size: the QR widget measures itself with a
                  // LayoutBuilder, which a dialog can't ask in advance.
                  child: SizedBox.square(
                    dimension: AppSize.pairingQr,
                    child: QrImageView(
                      data: session.invite.encode(),
                      size: AppSize.pairingQr,
                      backgroundColor: AppQrColors.paper,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: AppQrColors.ink,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: AppQrColors.ink,
                      ),
                      semanticsLabel: SyncCopy.pairPhoneTitle,
                    ),
                  ),
                ),
              ),
              SelectableText(
                session.invite.code.words.join('  '),
                style: styles.noteTitle,
                textAlign: TextAlign.center,
              ),
            ],
            Text(_message, style: styles.body, textAlign: TextAlign.center),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(_stage == _Stage.paired ? AppCopy.done : AppCopy.close),
        ),
      ],
    );
  }

  String get _message => switch (_stage) {
    _Stage.opening || _Stage.waiting => SyncCopy.waitingForPhone,
    _Stage.paired => SyncCopy.pairedPhone,
    _Stage.expired => SyncCopy.codeExpired,
    _Stage.failed => SyncCopy.problem,
  };
}
