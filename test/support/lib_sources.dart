import 'dart:io';

/// A Dart source file under `lib/`, with its path relative to `lib/`.
class LibSource {
  LibSource(this.path, this.lines);

  /// Forward-slash path relative to `lib/`, e.g. `core/styles/app_styles.dart`.
  final String path;
  final List<String> lines;
}

/// Reads every `.dart` file under `lib/`. Tests run from the project root.
List<LibSource> readLibSources() {
  final root = Directory('lib').absolute.path.replaceAll('\\', '/');
  return Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .map((f) {
        final abs = f.absolute.path.replaceAll('\\', '/');
        return LibSource(abs.substring(root.length + 1), f.readAsLinesSync());
      })
      .toList();
}
