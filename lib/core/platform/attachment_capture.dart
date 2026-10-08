import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../storage/files/attachment_name.dart';

/// A photo taken or picked, ready to save.
typedef CapturedPhoto = ({Uint8List bytes, String extension});

/// The device side of attachments: camera, gallery and microphone. An
/// interface, so tests use a fake instead of the plugins.
abstract interface class AttachmentCapture {
  /// A photo from the camera or the gallery, shrunk and compressed; null
  /// if the user backed out.
  Future<CapturedPhoto?> photo({required bool camera});

  /// Asks for the microphone the first time; false if refused.
  Future<bool> microphoneAllowed();

  Future<void> startRecording();

  /// The recording so far as a file's bytes (AAC in `.m4a`).
  Future<Uint8List?> stopRecording();

  Future<void> cancelRecording();
}

final attachmentCaptureProvider = Provider<AttachmentCapture>(
  (ref) => DeviceAttachmentCapture(),
);

/// [AttachmentCapture] on the real device.
class DeviceAttachmentCapture implements AttachmentCapture {
  /// Photos are shrunk to this side and re-encoded at this quality
  /// (CLAUDE.md §8: compress attachments): about 0.3–0.8 MB each.
  static const _maxSide = 2048.0;
  static const _quality = 80;

  final _picker = ImagePicker();
  AudioRecorder? _recorder;
  String? _recording;

  @override
  Future<CapturedPhoto?> photo({required bool camera}) async {
    final file = await _picker.pickImage(
      source: camera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: _maxSide,
      maxHeight: _maxSide,
      imageQuality: _quality,
      requestFullMetadata: false,
    );
    if (file == null) return null;
    final extension = p.extension(file.name).toLowerCase();
    final known = AttachmentName.kindOf('x$extension') != null;
    return (
      bytes: await file.readAsBytes(),
      extension: known ? extension : AttachmentName.photoExtension,
    );
  }

  @override
  Future<bool> microphoneAllowed() =>
      (_recorder ??= AudioRecorder()).hasPermission();

  @override
  Future<void> startRecording() async {
    final dir = await getTemporaryDirectory();
    final path = p.join(dir.path, 'recording${AttachmentName.voiceExtension}');
    _recording = path;
    await (_recorder ??= AudioRecorder()).start(
      const RecordConfig(encoder: AudioEncoder.aacLc, numChannels: 1),
      path: path,
    );
  }

  @override
  Future<Uint8List?> stopRecording() async {
    final path = await _recorder?.stop() ?? _recording;
    await _release();
    if (path == null) return null;
    final file = File(path);
    if (!await file.exists()) return null;
    final bytes = await file.readAsBytes();
    await file.delete();
    return bytes;
  }

  @override
  Future<void> cancelRecording() async {
    await _recorder?.cancel();
    await _release();
  }

  /// The microphone is let go as soon as recording ends.
  Future<void> _release() async {
    await _recorder?.dispose();
    _recorder = null;
  }
}
