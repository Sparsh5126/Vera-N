import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/platform/voice_player.dart';
import '../../../core/storage/storage_providers.dart';
import '../../../core/styles/app_styles.dart';
import 'embed_missing.dart';

/// A voice note in the note: a play / pause button, "Voice note", and the
/// time played while it plays. Nothing plays until the user taps.
class VoiceEmbed extends ConsumerStatefulWidget {
  const VoiceEmbed({super.key, required this.name});

  final String name;

  @override
  ConsumerState<VoiceEmbed> createState() => _VoiceEmbedState();
}

class _VoiceEmbedState extends ConsumerState<VoiceEmbed> {
  VoicePlayer? _player;
  bool _playing = false;
  Duration _at = Duration.zero;
  final _subscriptions = <StreamSubscription<Object?>>[];

  VoicePlayer _start() {
    final player = VoicePlayer();
    _subscriptions
      ..add(player.playing.listen((p) => setState(() => _playing = p)))
      ..add(player.position.listen((d) => setState(() => _at = d)));
    return player;
  }

  Future<void> _toggle() async {
    final player = _player ??= _start();
    if (_playing) return player.pause();
    final bytes = await ref.read(attachmentBytesProvider(widget.name).future);
    if (bytes != null && mounted) await player.play(widget.name, bytes);
  }

  @override
  void dispose() {
    for (final s in _subscriptions) {
      unawaited(s.cancel());
    }
    unawaited(_player?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exists = ref.watch(attachmentBytesProvider(widget.name));
    if (exists.hasValue && exists.value == null) return const EmbedMissing();
    final colors = context.colors;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: colors.card,
        shape: StadiumBorder(side: BorderSide(color: colors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(right: AppSpace.m),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => unawaited(_toggle()),
              icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
              tooltip: _playing ? AppCopy.pause : AppCopy.play,
            ),
            Text(AppCopy.voiceNote, style: context.textStyles.label),
            if (_playing || _at > Duration.zero) ...[
              const SizedBox(width: AppSpace.s),
              Text(AppCopy.duration(_at), style: context.textStyles.small),
            ],
          ],
        ),
      ),
    );
  }
}
