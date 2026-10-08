import 'dart:convert';
import 'dart:typed_data';

import 'package:vera_n/core/platform/attachment_capture.dart';

/// [AttachmentCapture] without the device: a tiny photo, and a recording
/// of a few bytes, with the microphone allowed unless [micAllowed] says no.
class FakeAttachmentCapture implements AttachmentCapture {
  /// A real 1×1 PNG, so photo previews decode.
  static final pixel = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA'
    '60e6kgAAAABJRU5ErkJggg==',
  );

  bool micAllowed = true;
  bool recording = false;
  var photos = 0;

  @override
  Future<CapturedPhoto?> photo({required bool camera}) async {
    photos++;
    return (bytes: pixel, extension: '.png');
  }

  @override
  Future<bool> microphoneAllowed() async => micAllowed;

  @override
  Future<void> startRecording() async => recording = true;

  @override
  Future<Uint8List?> stopRecording() async {
    recording = false;
    return Uint8List.fromList([1, 2, 3]);
  }

  @override
  Future<void> cancelRecording() async => recording = false;
}
