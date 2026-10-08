import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// The bundled model (ARCHITECTURE.md §8). ONNX Runtime reads the model
/// from a file, so it is copied out of the app once, under a versioned
/// name: a new model version gets a new file, and old ones are removed.
abstract final class ModelFiles {
  static const name = 'minilm-l12-en-hi';
  static const version = 1;
  static const _asset = 'assets/models/minilm-l12-en-hi';
  static const tokenizerAsset = '$_asset/tokenizer.json';

  /// Shows the model's Apache-2.0 license with the app's other licenses.
  static void registerLicense() {
    LicenseRegistry.addLicense(() async* {
      final text = await rootBundle.loadString('$_asset/LICENSE');
      yield LicenseEntryWithLineBreaks(const [name], text);
    });
  }

  /// The model file on disk, copied from the app on first use.
  static Future<String> modelPath() async {
    final support = await getApplicationSupportDirectory();
    final dir = Directory(p.join(support.path, 'models'));
    final file = File(p.join(dir.path, '$name-v$version.onnx'));
    if (file.existsSync()) return file.path;
    await dir.create(recursive: true);
    for (final old in dir.listSync()) {
      old.deleteSync();
    }
    final data = await rootBundle.load('$_asset/model_int8.onnx');
    // Written under a temporary name and renamed, so a copy cut short
    // (app closed) is never mistaken for a complete model.
    final partial = File('${file.path}.part');
    await partial.writeAsBytes(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      flush: true,
    );
    await partial.rename(file.path);
    return file.path;
  }
}
