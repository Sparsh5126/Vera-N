import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Plays one voice note. Its bytes go to a temporary file first, since the
/// picked folder has no plain file path. The player is made on the first
/// play and released by [dispose].
class VoicePlayer {
  AudioPlayer? _player;
  final _playing = StreamController<bool>.broadcast();
  final _position = StreamController<Duration>.broadcast();

  Stream<bool> get playing => _playing.stream;
  Stream<Duration> get position => _position.stream;

  Future<void> play(String name, Uint8List bytes) async {
    final player = _player ??= _create();
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, 'voice-$name'));
    if (!await file.exists()) await file.writeAsBytes(bytes, flush: true);
    await player.play(DeviceFileSource(file.path));
  }

  Future<void> pause() async => _player?.pause();

  AudioPlayer _create() {
    final player = AudioPlayer();
    player.onPlayerStateChanged.listen(
      (s) => _playing.add(s == PlayerState.playing),
    );
    player.onPositionChanged.listen(_position.add);
    player.onPlayerComplete.listen((_) => _position.add(Duration.zero));
    return player;
  }

  Future<void> dispose() async {
    await _player?.dispose();
    await _playing.close();
    await _position.close();
  }
}
