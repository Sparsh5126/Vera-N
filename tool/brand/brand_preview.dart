// Builds docs/brand/preview.html: the mark's construction, both cuts at
// real sizes, the lockup, and the launcher icon on several wallpapers.
import 'dart:math' as math;

import 'brand_preview_style.dart';
import 'brand_preview_sections.dart';
import 'mark_geometry.dart';

class BrandPreview {
  BrandPreview(this.primary, this.icon)
    : primaryIcon = IconPlacement(primary),
      iconIcon = IconPlacement(icon);

  final MarkShape primary;
  final MarkShape icon;
  final IconPlacement primaryIcon;
  final IconPlacement iconIcon;

  String build() {
    final sections = BrandPreviewSections(this);
    return '''
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Vera N mark</title>
<style>$brandPreviewStyle</style>
</head>
<body>
${_defs()}
<main>
<h1>Vera N mark</h1>
<p class="lede">Two strokes, two notes, meeting in one drop of ink. Drawn from
the rules below by <code>tool/brand/make_brand_marks.dart</code>, so it can be
redrawn exactly. It is the app icon on Android and Windows.</p>
${sections.construction()}
${sections.cuts()}
${sections.lockup()}
${sections.canvas()}
${sections.homeScreens()}
${sections.themed()}
${sections.checklist()}
</main>
</body>
</html>
''';
  }

  String _defs() =>
      '''
<svg width="0" height="0" style="position:absolute" aria-hidden="true">
<defs>
<g id="mark-primary">${primary.elements()}</g>
<g id="mark-icon">${icon.elements()}</g>
<g id="fg-primary" transform="${primaryIcon.transform}"><use href="#mark-primary"/></g>
<g id="fg-icon" transform="${iconIcon.transform}"><use href="#mark-icon"/></g>
<clipPath id="clip-circle"><circle cx="54" cy="54" r="36"/></clipPath>
<clipPath id="clip-rounded"><rect x="18" y="18" width="72" height="72" rx="16"/></clipPath>
<clipPath id="clip-squircle"><path d="${_squircle()}"/></clipPath>
</defs>
</svg>''';

  /// A superellipse (n = 4) filling the 72 dp visible square, like the
  /// squircle mask some launchers use.
  static String _squircle() {
    final points = <String>[];
    for (var deg = 0; deg < 360; deg += 3) {
      final t = deg * math.pi / 180;
      final c = math.cos(t);
      final s = math.sin(t);
      final x = 54 + 36 * c.sign * math.sqrt(c.abs());
      final y = 54 + 36 * s.sign * math.sqrt(s.abs());
      points.add('${fmt(x)},${fmt(y)}');
    }
    return 'M${points.join(' L')} Z';
  }
}
