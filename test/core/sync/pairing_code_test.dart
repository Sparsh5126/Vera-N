import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/sync/pairing_code.dart';

void main() {
  final list = File('assets/pairing/words_en.txt')
      .readAsLinesSync()
      .where((w) => w.isNotEmpty)
      .toList();
  const laptop =
      'AAAAAAA-BBBBBBB-CCCCCCC-DDDDDDD-EEEEEEE-FFFFFFF-GGGGGGG-HHHHHHH';
  const phone =
      'ZZZZZZZ-YYYYYYY-XXXXXXX-WWWWWWW-VVVVVVV-UUUUUUU-TTTTTTT-SSSSSSS';

  test('six random words from the list', () {
    final code = PairingCode.random(list, random: Random(1));
    expect(code.words, hasLength(6));
    expect(code.words.every(list.contains), isTrue);
  });

  test('typed words: any case, any separator, four-letter starts', () {
    final code = PairingCode.parse(
      'Abandon ZOO, ability-able acou acti',
      list,
    )!;
    expect(code.words, [
      'abandon',
      'zoo',
      'ability',
      'able',
      'acoustic',
      'action',
    ]);
    expect(PairingCode.parse('abandon zoo ability', list), isNull);
    expect(
      PairingCode.parse('abandon zoo ability able acoustic notaword', list),
      isNull,
    );
    expect(
      PairingCode.parse('abandon zoo ability able acoustic ab', list),
      isNull,
    );
  });

  test('the proofs match only with the same words and the same ids', () {
    final a = PairingCode.parse(
      'abandon zoo ability able acoustic action',
      list,
    )!;
    final same = PairingCode.parse('ABANDON zoo abil able acou acti', list)!;
    final other = PairingCode.parse(
      'abandon zoo ability able acoustic actor',
      list,
    )!;
    expect(
      PairingCode.same(a.phoneProof(phone), same.phoneProof(phone)),
      isTrue,
    );
    expect(
      PairingCode.same(a.phoneProof(phone), other.phoneProof(phone)),
      isFalse,
    );
    expect(
      PairingCode.same(a.phoneProof(phone), a.phoneProof(laptop)),
      isFalse,
    );
    expect(a.laptopProof(laptop, phone), isNot(a.laptopProof(phone, laptop)));
    expect(a.findTag, same.findTag);
    expect(a.findTag, isNot(other.findTag));
  });

  test('the QR invite round-trips; anything else is refused', () {
    final invite = PairingInvite(
      code: PairingCode.random(list, random: Random(2)),
      laptopId: laptop,
      addresses: ['192.168.1.5', '10.0.0.2'],
      port: 51234,
    );
    final back = PairingInvite.decode(invite.encode(), list)!;
    expect(back.code.words, invite.code.words);
    expect(back.laptopId, laptop);
    expect(back.addresses, ['192.168.1.5', '10.0.0.2']);
    expect(back.port, 51234);
    expect(PairingInvite.decode('https://example.com', list), isNull);
    expect(
      PairingInvite.decode('veran-pair:1:a-b:$laptop:1.2.3.4:80', list),
      isNull,
    );
    expect(
      PairingInvite.decode(
        invite.encode().replaceFirst('51234', '99999'),
        list,
      ),
      isNull,
    );
  });
}
