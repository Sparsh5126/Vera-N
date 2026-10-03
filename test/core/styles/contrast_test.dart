import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/styles/app_styles.dart';

/// WCAG contrast ratio between two opaque colors.
double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  const minText = 4.5;

  for (final (name, p) in [
    ('dark', AppPalette.dark),
    ('light', AppPalette.light),
  ]) {
    group('$name palette text contrast ≥ 4.5:1', () {
      final pairs = {
        'text on background': (p.text, p.background),
        'text on card': (p.text, p.card),
        'secondary on background': (p.textSecondary, p.background),
        'secondary on card': (p.textSecondary, p.card),
        'onAccent on accent': (p.onAccent, p.accent),
        'solid chip label': (p.solidChip.label, p.solidChip.fill),
        'dimmed chip label on card': (p.dimmedChip.label, p.card),
        'dimmed chip label on background': (p.dimmedChip.label, p.background),
      };
      pairs.forEach((label, pair) {
        test(label, () {
          expect(contrast(pair.$1, pair.$2), greaterThanOrEqualTo(minText));
        });
      });
    });
  }

  for (final (name, p) in [
    ('dark', AppPalette.dark),
    ('light', AppPalette.light),
  ]) {
    test('$name accent fills, outlines, icons ≥ 3:1', () {
      expect(contrast(p.accent, p.background), greaterThanOrEqualTo(3));
      expect(contrast(p.accent, p.card), greaterThanOrEqualTo(3));
    });
  }

  test('dimmed chip is marked by more than color', () {
    expect(AppPalette.dark.dimmedChip.dashed, isTrue);
    expect(AppPalette.dark.solidChip.dashed, isFalse);
  });
}
