import 'package:flutter_test/flutter_test.dart';

import 'support/lib_sources.dart';

/// Enforces the dependency rules in docs/ARCHITECTURE.md §5 (rules 1–4).
void main() {
  final sources = readLibSources();
  final importPattern = RegExp(r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''');

  /// Resolves an import to a path relative to lib/, or null if external.
  String? resolve(String fromPath, String uri) {
    if (uri.startsWith('package:vera_n/')) {
      return uri.substring('package:vera_n/'.length);
    }
    if (uri.contains(':')) return null;
    final parts = fromPath.split('/')..removeLast();
    for (final seg in uri.split('/')) {
      if (seg == '..') {
        parts.removeLast();
      } else if (seg != '.') {
        parts.add(seg);
      }
    }
    return parts.join('/');
  }

  String? violation(String from, String to) {
    if (from.startsWith('core/') &&
        (to.startsWith('features/') ||
            to.startsWith('shared/') ||
            to.startsWith('app/'))) {
      return 'core must not import features, shared, or app';
    }
    if (from.startsWith('features/') && to.startsWith('features/')) {
      if (from.split('/')[1] != to.split('/')[1]) {
        return 'features must not import other features';
      }
    }
    if (from.startsWith('shared/')) {
      const allowed = [
        'shared/',
        'core/styles/',
        'core/copy/',
        'core/feedback/',
        'core/models/',
      ];
      if (!allowed.any(to.startsWith)) {
        return 'shared widgets may only import styles, copy, feedback, models';
      }
    }
    if (to.startsWith('core/storage/db/')) {
      const allowed = [
        'core/storage/db/',
        'core/storage/repositories/',
        'core/storage/indexer/',
        'core/storage/storage_services.dart',
      ];
      if (!allowed.any(from.startsWith)) {
        return 'only repositories and the indexer may use the database';
      }
    }
    return null;
  }

  test('lib/ imports follow the layer rules', () {
    final problems = <String>[];
    for (final src in sources) {
      for (var i = 0; i < src.lines.length; i++) {
        final match = importPattern.firstMatch(src.lines[i]);
        if (match == null) continue;
        final to = resolve(src.path, match.group(1)!);
        if (to == null) continue;
        final why = violation(src.path, to);
        if (why != null) problems.add('${src.path}:${i + 1} → $to ($why)');
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  });
}
