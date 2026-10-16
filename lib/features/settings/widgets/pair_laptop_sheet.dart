import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/styles/app_styles.dart';
import '../../../core/sync/pairing_code.dart';
import '../../../core/sync/pairing_exchange.dart';
import '../../../core/sync/sync_service.dart';
import '../../../shared/widgets/pill_button.dart';
import '../../../shared/widgets/text_entry_sheet.dart';
import 'qr_scan_page.dart';

/// The phone's side of pairing (docs/LAPTOP_PLAN.md, S2): scan the
/// laptop's code, or type its six words.
class PairLaptopSheet extends StatefulWidget {
  const PairLaptopSheet({super.key, required this.sync});

  final SyncService sync;

  static Future<void> show(BuildContext context, SyncService sync) =>
      showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => PairLaptopSheet(sync: sync),
      );

  @override
  State<PairLaptopSheet> createState() => _PairLaptopSheetState();
}

class _PairLaptopSheetState extends State<PairLaptopSheet> {
  String? _message;
  var _busy = false;
  var _done = false;

  Future<void> _scan() async {
    final text = await QrScanPage.open(context);
    if (text == null || !mounted) return;
    final invite = PairingInvite.decode(text, await widget.sync.wordList());
    if (invite == null) return setState(() => _message = SyncCopy.notACode);
    await _join(invite: invite);
  }

  Future<void> _type() async {
    final typed = await TextEntrySheet.show(context, hint: SyncCopy.wordsHint);
    if (typed == null || !mounted) return;
    final code = PairingCode.parse(typed, await widget.sync.wordList());
    if (code == null) return setState(() => _message = SyncCopy.wrongCode);
    await _join(code: code);
  }

  Future<void> _join({PairingCode? code, PairingInvite? invite}) async {
    setState(() {
      _busy = true;
      _message = SyncCopy.lookingForLaptop;
    });
    try {
      final laptop = await widget.sync.join(code: code, invite: invite);
      _done = true;
      _message = SyncCopy.pairedWith(laptop.name);
    } on PairingFailed catch (e) {
      _message = e.problem == PairingProblem.wrongCode
          ? SyncCopy.wrongCode
          : SyncCopy.notFound;
    } on Object {
      _message = SyncCopy.problem;
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    final message = _message;
    return SafeArea(
      child: Padding(
        padding: AppSpace.screen,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpace.m,
          children: [
            Text(SyncCopy.pairLaptopTitle, style: styles.noteTitle),
            if (!_done) ...[
              const Text(SyncCopy.pairLaptopBody),
              PillButton(
                label: SyncCopy.scanCode,
                icon: Icons.qr_code_scanner,
                onPressed: _busy ? null : () => unawaited(_scan()),
              ),
              OutlinedButton(
                onPressed: _busy ? null : () => unawaited(_type()),
                child: const Text(SyncCopy.typeWords),
              ),
            ],
            if (message != null)
              Text(message, style: styles.body, textAlign: TextAlign.center),
            Text(
              SyncCopy.onlyWifi,
              style: styles.small.copyWith(color: context.colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
