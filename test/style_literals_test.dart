import 'package:flutter_test/flutter_test.dart';

import 'support/lib_sources.dart';

/// Fails on styling literals outside lib/core/styles/ (CLAUDE.md §4).
void main() {
  final sources = readLibSources()
      .where((s) => !s.path.startsWith('core/styles/'))
      .toList();

  /// Patterns banned everywhere outside the styles file.
  final everywhere = {
    'raw color': RegExp(r'\bColor\(0x|\bColor\.fromA?RGBO?\('),
    'Colors.* constant': RegExp(r'\bColors\.'),
    'TextStyle constructor': RegExp(r'\bTextStyle\('),
    'numeric EdgeInsets': RegExp(r'\bEdgeInsets(Directional)?\.\w+\([^)]*\d'),
    'numeric radius': RegExp(
      r'\bRadius\.circular\(\s*\d|BorderRadius\.circular\(\s*\d',
    ),
    'numeric font size': RegExp(r'\bfontSize:\s*\d'),
    'Curves.* constant': RegExp(r'\bCurves\.'),
  };

  /// Motion durations: UI code only. Product timings such as the 30-day
  /// expiry live in core/ and are not styling.
  final uiOnly = {'Duration literal': RegExp(r'\bDuration\([^)]*\d')};
  bool isUi(String path) =>
      path.startsWith('features/') ||
      path.startsWith('shared/') ||
      path.startsWith('app/');

  test('no styling literals outside app_styles.dart', () {
    final problems = <String>[];
    for (final src in sources) {
      final rules = {...everywhere, if (isUi(src.path)) ...uiOnly};
      for (var i = 0; i < src.lines.length; i++) {
        final line = src.lines[i].trimLeft();
        if (line.startsWith('//')) continue;
        rules.forEach((name, pattern) {
          if (pattern.hasMatch(line)) {
            problems.add('${src.path}:${i + 1} $name: $line');
          }
        });
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  });
}
