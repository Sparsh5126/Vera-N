import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/ai/matching/word_signature.dart';

void main() {
  final text = List.generate(60, (i) => 'word$i').join(' ');
  double sim(String a, String b) =>
      WordSignature.similarity(WordSignature.of(a), WordSignature.of(b));

  test('the same text is fully similar; signatures are 128 bytes', () {
    expect(sim(text, text), 1);
    expect(WordSignature.of(text).lengthInBytes, 128);
  });

  test('a small edit stays similar; rewriting most words does not', () {
    expect(sim(text, '$text extra words'), greaterThan(2 / 3));
    final rewritten = List.generate(60, (i) => i < 25 ? 'word$i' : 'new$i');
    expect(sim(text, rewritten.join(' ')), lessThan(2 / 3));
  });

  test('works for Hindi words and ignores case and punctuation', () {
    expect(sim('आज बारिश हुई। Hello', 'आज बारिश हुई hello!'), 1);
  });
}
