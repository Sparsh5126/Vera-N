import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/utils/date_label.dart';
import 'package:vera_n/core/utils/greeting.dart';

void main() {
  final now = DateTime(2026, 10, 3, 19);

  test('date labels', () {
    expect(DateLabel.of(DateTime(2026, 10, 3, 1), now), 'Today');
    expect(DateLabel.of(DateTime(2026, 9, 21), now), 'Sep 21');
    expect(DateLabel.of(DateTime(2025, 12, 2), now), 'Dec 2, 2025');
  });

  test('greeting by time of day, name optional', () {
    expect(Greeting.of(DateTime(2026, 1, 1, 8)), 'Good morning');
    expect(Greeting.of(DateTime(2026, 1, 1, 13)), 'Good afternoon');
    expect(Greeting.of(DateTime(2026, 1, 1, 2)), 'Good evening');
    expect(Greeting.of(now, name: 'Asha'), 'Good evening, Asha');
    expect(Greeting.of(now, name: '  '), 'Good evening');
  });
}
