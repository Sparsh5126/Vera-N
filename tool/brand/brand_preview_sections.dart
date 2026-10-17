// The sections of docs/brand/preview.html.
import 'brand_preview.dart';
import 'mark_geometry.dart';

const _stock = '#F5F4F6';
const _ink = '#16181A';
const _guide = '#5C5E66';

class BrandPreviewSections {
  BrandPreviewSections(this.p);

  final BrandPreview p;

  String construction() {
    final s = p.primary;
    final cut = s.cut;
    final r = MarkShape.corner(-1);
    final terminal1 = (MarkShape.corner(1).x + s.innerTop(1).x) / 2;
    final terminal2 = (r.x + s.innerTop(-1).x) / 2;
    final dropY = s.bottom + 2;
    final cx = s.dropCentre.x;
    final rad = cut.dropRadius;
    return '''
<h2>Construction</h2>
<div class="row">
<div class="plate"><svg viewBox="0 4 124 114" class="mark" role="img" aria-label="The mark with its construction lines">
<use href="#mark-primary" fill="currentColor"/>
<g fill="none" stroke="$_guide" stroke-width="0.35" stroke-dasharray="1.6 1.2">
<line x1="4" y1="${fmt(s.top)}" x2="118" y2="${fmt(s.top)}"/>
${_side(1)}${_side(-1)}
<line x1="60" y1="8" x2="60" y2="116"/>
<path d="M${fmt(r.x + 9)},${fmt(r.y)} A9 9 0 0 0 ${fmt(r.x + 4.5)},${fmt(r.y - 7.79)}"/>
</g>
<g stroke="$_guide" stroke-width="0.35">
<line x1="${fmt(cx - rad)}" y1="${fmt(dropY)}" x2="${fmt(cx + rad)}" y2="${fmt(dropY)}"/>
<line x1="${fmt(cx - rad)}" y1="${fmt(dropY - 1)}" x2="${fmt(cx - rad)}" y2="${fmt(dropY + 1)}"/>
<line x1="${fmt(cx + rad)}" y1="${fmt(dropY - 1)}" x2="${fmt(cx + rad)}" y2="${fmt(dropY + 1)}"/>
</g>
<g fill="$_guide" font-size="3.6" font-family="Inter, sans-serif" text-anchor="middle">
<text x="${fmt(r.x + 11.3)}" y="${fmt(r.y - 5)}">60°</text>
<text x="${fmt(terminal1)}" y="16">${fmt(cut.heavyWidth)}</text>
<text x="${fmt(terminal2)}" y="16">${fmt(cut.lightWidth)}</text>
<text x="${fmt(cx)}" y="${fmt(dropY + 5)}">⌀ ${fmt(rad * 2)}</text>
</g>
</svg></div>
<div class="plate">
<ol class="rules">
<li>The outer contour is an inverted <strong>equilateral triangle</strong>, so both strokes run at 60° to the baseline.</li>
<li>Terminals are cut flat, on the triangle's top edge.</li>
<li>The left stroke is the heavy one, <strong>4 : 3</strong> against the right, like a pen's down-stroke and up-stroke.</li>
<li>Each stroke keeps its weight down most of its length, then narrows to a neck where the two meet.</li>
<li>The <strong>drop's diameter is the light stroke's width</strong>. It hangs just below the apex.</li>
</ol>
<p class="cap">Widths are measured across the stroke, in units of a mark 80 tall from terminals to apex.</p>
</div>
</div>''';
  }

  /// A triangle side on [side], drawn past both of its ends.
  String _side(int side) {
    final c = MarkShape.corner(side);
    const a = MarkShape.apex;
    final len = a.distanceTo(c);
    final ux = (c.x - a.x) / len;
    final uy = (c.y - a.y) / len;
    return '<line x1="${fmt(a.x - ux * 6)}" y1="${fmt(a.y - uy * 6)}" '
        'x2="${fmt(c.x + ux * 10)}" y2="${fmt(c.y + uy * 10)}"/>';
  }

  String cuts() =>
      '''
<h2>Two cuts</h2>
<div class="row">
${_cutPlate(p.primary, 'Primary', 'For about 96 px and up: the wordmark, print, the splash screen.')}
${_cutPlate(p.icon, 'Icon cut', 'For the launcher icon and anything smaller: heavier, with a neck wide enough for 24 px.')}
</div>
<div class="plate" style="margin-top:16px">
${_ladder(p.primary, 'Primary')}
${_ladder(p.icon, 'Icon cut')}
<p class="cap">Watch the neck above the drop as the size falls.</p>
</div>''';

  String _cutPlate(MarkShape s, String title, String use) {
    final c = s.cut;
    return '<div class="plate"><div class="big">${mark(s, 200)}</div>'
        '<p><strong>$title.</strong> $use</p>'
        '<p class="cap">Heavy ${fmt(c.heavyWidth)} · light ${fmt(c.lightWidth)}'
        ' · neck ${fmt(c.neck)} · fullness ${fmt(c.fullness)} · drop ⌀ '
        '${fmt(c.dropRadius * 2)}</p></div>';
  }

  String _ladder(MarkShape s, String title) {
    final items = [96, 64, 48, 32, 24, 16]
        .map((h) => '<figure>${mark(s, h)}<figcaption>$h</figcaption></figure>')
        .join();
    return '<div class="ladder"><figure><figcaption>$title</figcaption></figure>'
        '$items</div>';
  }

  static String mark(MarkShape s, num height) {
    final width = height * s.width / s.height;
    return '<svg class="mark" viewBox="${s.viewBox}" width="${fmt(width.toDouble())}" '
        'height="$height" fill="currentColor" role="img" aria-label="Vera N mark">'
        '<use href="#mark-${s.cut.name}"/></svg>';
  }

  String lockup() =>
      '''
<h2>Lockup</h2>
<div class="row">
<div class="lockup light">${mark(p.primary, 72)}<span>Vera N</span></div>
<div class="lockup dark">${mark(p.primary, 72)}<span>Vera N</span></div>
</div>
<p class="cap">The wordmark is the real Instrument Serif from <code>assets/fonts/</code>. A final lockup file needs the text turned into outlines.</p>''';

  String canvas() {
    final grid = StringBuffer();
    for (var v = 6; v < 108; v += 6) {
      grid.write(
        '<line x1="$v" y1="0" x2="$v" y2="108"/>'
        '<line x1="0" y1="$v" x2="108" y2="$v"/>',
      );
    }
    return '''
<h2>Adaptive icon</h2>
<div class="plate">
<div class="canvas"><svg viewBox="0 0 108 108" role="img" aria-label="The icon cut on the 108 dp adaptive-icon canvas">
<rect width="108" height="108" fill="$_stock"/>
<g stroke="$_ink" stroke-opacity="0.07" stroke-width="0.2">$grid</g>
<g fill="none" stroke="$_guide" stroke-width="0.3" stroke-dasharray="1.2 1">
<rect x="18" y="18" width="72" height="72"/><circle cx="54" cy="54" r="33"/>
</g>
<use href="#fg-icon" fill="$_ink"/>
<g fill="$_guide" font-size="3" font-family="Inter, sans-serif">
<text x="3" y="6">108 dp canvas</text><text x="18" y="16">72 dp shown</text>
<text x="54" y="96" text-anchor="middle">66 dp safe circle</text>
</g>
</svg></div>
<p class="cap">Icon cut, ${fmt(IconPlacement.markWidth)} dp wide, on stock $_stock. It reaches ${fmt(p.iconIcon.reach)} dp from the centre (the limit is 33). The point ${(IconPlacement.opticalCentre * 100).round()}% down the mark sits on the centre, since a V carries its weight high.</p>
</div>''';
  }

  String homeScreens() =>
      '''
<h2>On a home screen</h2>
${_wall('wall-light', 'Light wallpaper')}
${_wall('wall-dark', 'Dark wallpaper')}
${_wall('wall-busy', 'Photo wallpaper')}
<p class="cap">Sizes are CSS pixels. A laptop at 100% shows about a third of the pixels a phone gives a 48 dp icon, so this is a harsher test than the phone.</p>''';

  String _wall(String kind, String label) =>
      '''
<div class="wall $kind" aria-label="$label">
${icon('primary', 'circle', 48, _stock, _ink, 'Primary · 48')}
${icon('icon', 'circle', 48, _stock, _ink, 'Icon cut · 48')}
${icon('primary', 'circle', 24, _stock, _ink, 'Primary · 24')}
${icon('icon', 'circle', 24, _stock, _ink, 'Icon cut · 24')}
<span class="gap"></span>
${icon('icon', 'circle', 48, _stock, _ink, 'Circle')}
${icon('icon', 'squircle', 48, _stock, _ink, 'Squircle')}
${icon('icon', 'rounded', 48, _stock, _ink, 'Rounded square')}
</div>''';

  String themed() =>
      '''
<h2>Themed icon (Android 13 and later)</h2>
<div class="wall wall-themed-light">
${icon('icon', 'circle', 48, '#D3E4F5', '#0E3A5C', 'Light · 48')}
${icon('icon', 'circle', 24, '#D3E4F5', '#0E3A5C', 'Light · 24')}
${icon('icon', 'squircle', 48, '#D3E4F5', '#0E3A5C', 'Squircle')}
</div>
<div class="wall wall-themed-dark">
${icon('icon', 'circle', 48, '#1F3242', '#B8D3EE', 'Dark · 48')}
${icon('icon', 'circle', 24, '#1F3242', '#B8D3EE', 'Dark · 24')}
${icon('icon', 'squircle', 48, '#1F3242', '#B8D3EE', 'Squircle')}
</div>
<p class="cap">The system tints the monochrome layer (<code>icon-monochrome.svg</code>) with the wallpaper's colours. These two tints are examples.</p>''';

  static String icon(
    String cut,
    String mask,
    int size,
    String bg,
    String fg,
    String label,
  ) =>
      '<figure><svg viewBox="18 18 72 72" width="$size" height="$size" '
      'role="img" aria-label="$label"><g clip-path="url(#clip-$mask)">'
      '<rect width="108" height="108" fill="$bg"/>'
      '<use href="#fg-$cut" fill="$fg"/></g></svg>'
      '<figcaption>$label</figcaption></figure>';

  String checklist() => '''
<h2>What to look for</h2>
<div class="plate"><ul>
<li>At 24, does the primary's neck vanish while the icon cut's holds?</li>
<li>Does the V look centred in the circle, or does it sit low?</li>
<li>On the photo wallpaper, does the pale plate keep it clear?</li>
<li>Then install it on the phone: the real test is a 48 dp icon among your other apps.</li>
</ul></div>''';
}
