import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/utils/names.dart';

void main() {
  test('tags: no #, spaces become dashes, Hindi kept', () {
    expect(Names.tag('#story'), 'story');
    expect(Names.tag('  time loop '), 'time-loop');
    expect(Names.tag('कहानी'), 'कहानी');
    expect(Names.tag(' # '), isNull);
  });

  test('folders: trimmed segments, nothing hidden or odd', () {
    expect(Names.folder(' Ideas / Story '), 'Ideas/Story');
    expect(Names.folder('विचार'), 'विचार');
    expect(Names.folder('/'), isNull);
    expect(Names.folder('.trash'), isNull);
    expect(Names.folder('a/../b'), isNull);
    expect(Names.folder(r'a\b'), isNull);
    expect(Names.folder('C:'), isNull);
  });
}
