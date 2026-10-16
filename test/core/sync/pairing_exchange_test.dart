import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/sync/pairing_code.dart';
import 'package:vera_n/core/sync/pairing_exchange.dart';

void main() {
  final list = File('assets/pairing/words_en.txt')
      .readAsLinesSync()
      .where((w) => w.isNotEmpty)
      .toList();
  const laptopId =
      'AAAAAAA-BBBBBBB-CCCCCCC-DDDDDDD-EEEEEEE-FFFFFFF-GGGGGGG-HHHHHHH';
  const phoneId =
      'ZZZZZZZ-YYYYYYY-XXXXXXX-WWWWWWW-VVVVVVV-UUUUUUU-TTTTTTT-SSSSSSS';
  final loopback = InternetAddress.loopbackIPv4;
  var findPort = 23100 + Random().nextInt(500);

  late PairingCode code;
  late List<PairedDevice> added;
  late PairingHost host;

  setUp(() {
    findPort++;
    code = PairingCode.random(list);
    added = [];
    host = PairingHost(
      code: code,
      laptopId: laptopId,
      name: 'Laptop',
      syncPort: 22000,
      findPort: findPort,
      onPhone: (p) async => added.add(p),
    );
  });
  tearDown(() => host.close());

  PairingInvite onLoopback(PairingInvite i) => PairingInvite(
    code: i.code,
    laptopId: i.laptopId,
    addresses: ['127.0.0.1'],
    port: i.port,
  );

  test('with the QR code: each side gets the other, proved', () async {
    final invite = onLoopback(await host.open());
    final laptop = await PairingGuest.join(
      code: invite.code,
      invite: invite,
      phoneId: phoneId,
      name: 'Phone',
      syncPort: 22001,
    );
    expect(laptop.id, laptopId);
    expect(laptop.syncPort, 22000);
    final phone = (await host.result)!;
    expect(phone.id, phoneId);
    expect(phone.syncPort, 22001);
    expect(phone.address, '127.0.0.1');
    expect(added.single.id, phoneId);
  });

  test('with the words: the phone finds the laptop on the network', () async {
    await host.open();
    final typed = PairingCode.parse(code.words.join(' '), list)!;
    final laptop = await PairingGuest.join(
      code: typed,
      phoneId: phoneId,
      name: 'Phone',
      syncPort: 22001,
      findPort: findPort,
      broadcast: loopback,
    );
    expect(laptop.id, laptopId);
    expect(added, hasLength(1));
  });

  test('wrong words: no laptop answers the search, nothing is added', () async {
    await host.open();
    final wrong = PairingCode.random(list);
    await expectLater(
      PairingGuest.join(
        code: wrong,
        phoneId: phoneId,
        name: 'Phone',
        syncPort: 22001,
        findPort: findPort,
        broadcast: loopback,
        searchFor: const Duration(seconds: 2),
      ),
      throwsA(
        isA<PairingFailed>().having(
          (e) => e.problem,
          'problem',
          PairingProblem.notFound,
        ),
      ),
    );
    expect(added, isEmpty);
  });

  test('a wrong proof is refused; after five the window closes', () async {
    final invite = onLoopback(await host.open());
    final wrong = PairingInvite(
      code: PairingCode.random(list),
      laptopId: laptopId,
      addresses: invite.addresses,
      port: invite.port,
    );
    for (var i = 0; i < PairingHost.maxTries; i++) {
      await expectLater(
        PairingGuest.join(
          code: wrong.code,
          invite: wrong,
          phoneId: phoneId,
          name: 'Phone',
          syncPort: 22001,
        ),
        throwsA(isA<PairingFailed>()),
      );
    }
    expect(await host.result, isNull);
    expect(added, isEmpty);
  });
}
