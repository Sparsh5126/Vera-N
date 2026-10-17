// Writes the Vera N mark files, their preview, and the Android launcher
// icon's foreground. Then run tool/brand/render_icons.ps1 for the PNG and
// .ico files, which need a browser to draw them.
//
// Usage, from the repository root: dart run tool/brand/make_brand_marks.dart
//
// docs/brand/mark-primary.svg     the mark for large sizes, in ink
// docs/brand/mark-icon.svg        the heavier cut for small sizes, in ink
// docs/brand/icon-foreground.svg  the icon cut on the 108 dp adaptive canvas
// docs/brand/icon-monochrome.svg  the same in black, for themed icons
// docs/brand/icon-tile.svg        the icon as a rounded tile, for PNG and .ico
// docs/brand/preview.html         construction, sizes, masks and wallpapers
// android/.../drawable/ic_launcher_foreground.xml  the adaptive foreground
import 'dart:io';

import 'brand_preview.dart';
import 'mark_geometry.dart';

const _ink = '#16181A';
const _stock = '#F5F4F6';
const _hairline = '#C9C7C4';
const _foreground =
    'android/app/src/main/res/drawable/ic_launcher_foreground.xml';

void main() {
  final root = File.fromUri(Platform.script).parent.parent.parent.path;
  Directory('$root/docs/brand').createSync(recursive: true);
  final primary = MarkShape(MarkCut.primary);
  final icon = MarkShape(MarkCut.icon);
  final placed = IconPlacement(icon);

  void write(String path, String text) {
    File('$root/$path').writeAsStringSync(text);
    stdout.writeln('wrote $path');
  }

  write('docs/brand/mark-primary.svg', _markFile(primary));
  write('docs/brand/mark-icon.svg', _markFile(icon));
  write('docs/brand/icon-foreground.svg', _iconFile(placed, _ink));
  write('docs/brand/icon-monochrome.svg', _iconFile(placed, '#000000'));
  write('docs/brand/icon-tile.svg', _tileFile(placed));
  write('docs/brand/preview.html', BrandPreview(primary, icon).build());
  write(_foreground, _androidVector(placed));
  stdout.writeln(
    'icon cut reaches ${fmt(placed.reach)} dp of the '
    '${fmt(IconPlacement.safeRadius)} dp safe radius',
  );
}

String _markFile(MarkShape s) =>
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="${s.viewBox}" '
    'fill="$_ink">${s.elements()}</svg>\n';

String _iconFile(IconPlacement p, String fill) =>
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 108 108" '
    'width="108" height="108"><g fill="$fill" transform="${p.transform}">'
    '${p.shape.elements()}</g></svg>\n';

/// The 72 dp the launcher shows, as a rounded square with a hairline and a
/// little room around it: for Android 7 launchers and for Windows, which
/// draw an icon as it is, with no mask of their own.
String _tileFile(IconPlacement p) =>
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="16 16 76 76" '
    'width="512" height="512">'
    '<rect x="18.5" y="18.5" width="71" height="71" rx="16" fill="$_stock" '
    'stroke="$_hairline" stroke-width="1"/>'
    '<g fill="$_ink" transform="${p.transform}">${p.shape.elements()}</g>'
    '</svg>\n';

String _androidVector(IconPlacement p) {
  final s = p.shape;
  String path(String d) =>
      '        <path android:fillColor="@color/ic_launcher_mark" '
      'android:pathData="$d" />';
  return '''
<?xml version="1.0" encoding="utf-8"?>
<!-- The Vera N mark (icon cut) on the 108 dp adaptive-icon canvas. Written by
     tool/brand/make_brand_marks.dart: change the rules there, not this file. -->
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="108"
    android:viewportHeight="108">
    <group
        android:scaleX="${fmt(p.scale, 4)}"
        android:scaleY="${fmt(p.scale, 4)}"
        android:translateX="${fmt(p.dx)}"
        android:translateY="${fmt(p.dy)}">
${path(s.strokePath(1))}
${path(s.strokePath(-1))}
${path(s.dropPath())}
    </group>
</vector>
''';
}
