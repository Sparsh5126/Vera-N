import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/ai/matching/note_copies.dart';

void main() {
  const trip = 'Trip\nPack boots, torch and the blue map for Monday.';

  test('the same words are copies, whatever the case or spacing', () {
    expect(
      NoteCopies.alike(
        trip,
        'trip\n\npack BOOTS torch and the blue map '
        'for monday',
      ),
      isTrue,
    );
  });

  test('"Linked notes" is left out: a copy with links is still a copy', () {
    expect(
      NoteCopies.alike(trip, '$trip\n\n## Linked notes\n- [[Gear]]\n'),
      isTrue,
    );
  });

  test('a related note written separately is not a copy', () {
    expect(
      NoteCopies.alike(trip, 'Gear\nBoots and a torch for the Monday walk.'),
      isFalse,
    );
  });

  test('Hindi and English together', () {
    const mixed = 'सफ़र\nजूते, टॉर्च और map रखना है।';
    expect(NoteCopies.alike(mixed, mixed), isTrue);
    expect(NoteCopies.alike(mixed, 'सफ़र\nखाना और पानी'), isFalse);
  });

  test('an empty note is nobody\'s copy', () {
    expect(NoteCopies.alike('', ''), isFalse);
  });
}
