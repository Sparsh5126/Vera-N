import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/platform/attachment_capture.dart';
import '../../../core/styles/app_styles.dart';
import '../../../shared/widgets/pill_button.dart';

/// Records a voice note: recording starts when the sheet opens, the time
/// counts up, and Save or Cancel ends it. Asks for the microphone the
/// first time; if refused, says how to allow it. Returns the recording.
class VoiceRecorderSheet extends StatefulWidget {
  const VoiceRecorderSheet({super.key, required this.capture});

  final AttachmentCapture capture;

  static Future<Uint8List?> show(
    BuildContext context,
    AttachmentCapture capture,
  ) {
    return showModalBottomSheet<Uint8List>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => VoiceRecorderSheet(capture: capture),
    );
  }

  @override
  State<VoiceRecorderSheet> createState() => _VoiceRecorderSheetState();
}

class _VoiceRecorderSheetState extends State<VoiceRecorderSheet> {
  final _clock = Stopwatch();
  Timer? _tick;
  bool? _allowed;

  @override
  void initState() {
    super.initState();
    unawaited(_start());
  }

  Future<void> _start() async {
    final allowed = await widget.capture.microphoneAllowed();
    if (!mounted) return;
    setState(() => _allowed = allowed);
    if (!allowed) return;
    await widget.capture.startRecording();
    _clock.start();
    _tick = Timer.periodic(AppMotion.clockTick, (_) => setState(() {}));
  }

  Future<void> _finish({required bool save}) async {
    _tick?.cancel();
    _clock.stop();
    final navigator = Navigator.of(context);
    Uint8List? bytes;
    if (_allowed ?? false) {
      if (save) {
        bytes = await widget.capture.stopRecording();
      } else {
        await widget.capture.cancelRecording();
      }
    }
    navigator.pop(bytes);
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    final allowed = _allowed;
    return SafeArea(
      child: Padding(
        padding: AppSpace.card,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (allowed == false)
              Text(AppCopy.microphoneNeeded, style: styles.body)
            else ...[
              Text(AppCopy.recording, style: styles.label),
              const SizedBox(height: AppSpace.s),
              Text(AppCopy.duration(_clock.elapsed), style: styles.noteTitle),
            ],
            const SizedBox(height: AppSpace.l),
            Row(
              spacing: AppSpace.m,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => unawaited(_finish(save: false)),
                    child: const Text(AppCopy.cancel),
                  ),
                ),
                if (allowed ?? false)
                  Expanded(
                    child: PillButton(
                      label: AppCopy.save,
                      icon: Icons.stop,
                      onPressed: () => unawaited(_finish(save: true)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
