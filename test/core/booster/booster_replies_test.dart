import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/booster/booster_prompts.dart';
import 'package:vera_n/core/booster/booster_replies.dart';

void main() {
  group('sentence', () {
    test('first line, without labels or quotes, ending in a stop', () {
      expect(
        BoosterReplies.sentence('Sentence: "Both plan a trek"\nmore chat'),
        'Both plan a trek.',
      );
      expect(
        BoosterReplies.sentence('\n  दोनों में ट्रेक की योजना है।'),
        'दोनों में ट्रेक की योजना है।',
      );
      expect(BoosterReplies.sentence('  \n '), isNull);
    });

    test('a long reply is cut at a word', () {
      final s = BoosterReplies.sentence('word ' * 60)!;
      expect(s.length, lessThanOrEqualTo(161));
      expect(s.endsWith('word.'), isTrue);
    });
  });

  group('tag names', () {
    test('read from a JSON array amid chatter; at most two', () {
      expect(
        BoosterReplies.tagNames('Sure! ["Trek Planning", "#Spring", "x3"]', []),
        ['trek-planning', 'spring'],
      );
      expect(BoosterReplies.tagNames('[]', []), isEmpty);
      expect(BoosterReplies.tagNames('no array here', []), isEmpty);
      expect(BoosterReplies.tagNames('[not json', []), isEmpty);
    });

    test('folded into an existing tag written differently', () {
      expect(BoosterReplies.tagNames('["Treks", "recipe"]', ['trek']), [
        'trek',
        'recipe',
      ]);
      expect(
        BoosterReplies.tagName('trek planning', ['trekplanning']),
        'trekplanning',
      );
    });

    test('Devanagari is kept; junk, long or many-word names are dropped', () {
      expect(BoosterReplies.tagName('यात्रा योजना', []), 'यात्रा-योजना');
      expect(BoosterReplies.tagName('a', []), isNull);
      expect(BoosterReplies.tagName('one two three four', []), isNull);
      expect(BoosterReplies.tagName('x' * 31, []), isNull);
      expect(BoosterReplies.tagName('  --Work!!  ', []), 'work');
    });

    test('topic name from the first line', () {
      expect(
        BoosterReplies.topicName('Trek planning\n(because…)', []),
        'trek-planning',
      );
    });
  });

  group('duplicate', () {
    test('YES with a sentence, NO, or nothing', () {
      final yes = BoosterReplies.duplicate('YES\nBoth are the grocery list.');
      expect(yes.same, isTrue);
      expect(yes.why, 'Both are the grocery list.');
      expect(
        BoosterReplies.duplicate('Yes, both list groceries.').why,
        'both list groceries.',
      );
      expect(
        BoosterReplies.duplicate('Yes. Both list groceries').why,
        'Both list groceries.',
      );
      expect(BoosterReplies.duplicate('NO').same, isFalse);
      expect(BoosterReplies.duplicate('').same, isFalse);
      expect(BoosterReplies.duplicate('Maybe yes').same, isFalse);
    });
  });

  test('prompts cut long notes and list known tags', () {
    final prompt = BoosterPrompts.note('a' * 5000, ['trek', 'work']);
    expect(prompt, contains('Existing tags: trek, work'));
    expect(prompt.length, lessThan(3200));
    expect(BoosterPrompts.note('hi', []), contains('(none)'));
  });
}
