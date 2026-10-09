import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/booster/ai_server_address.dart';
import 'package:vera_n/core/booster/ai_server_client.dart';

import '../../support/fake_ai_server.dart';

void main() {
  group('AiServerAddress', () {
    Future<bool> ok(String a, {bool ownNetwork = false}) async {
      try {
        await AiServerAddress.parse(a, ownNetwork: ownNetwork).resolve();
        return true;
      } on AddressRefused {
        return false;
      }
    }

    test('only http(s) with a host and no login', () {
      for (final bad in ['ftp://localhost', 'localhost:1234', 'http://', '']) {
        expect(
          () => AiServerAddress.parse(bad),
          throwsA(isA<AddressRefused>()),
        );
      }
      expect(
        () => AiServerAddress.parse('http://me:pw@localhost:1234'),
        throwsA(isA<AddressRefused>()),
      );
      expect(
        AiServerAddress.parse('http://localhost:1234/v1/').uri.path,
        '/v1',
      );
    });

    test('this computer is accepted; anywhere else is refused', () async {
      expect(await ok('http://localhost:1234/v1'), isTrue);
      expect(await ok('http://127.0.0.1:1234/v1'), isTrue);
      expect(await ok('http://[::1]:1234/v1'), isTrue);
      expect(await ok('http://8.8.8.8/v1'), isFalse);
      expect(await ok('http://192.168.1.5:1234/v1'), isFalse);
    });

    test('the own network only when allowed, never the internet', () async {
      expect(await ok('http://192.168.1.5/v1', ownNetwork: true), isTrue);
      expect(await ok('http://10.0.0.2/v1', ownNetwork: true), isTrue);
      expect(await ok('http://100.101.1.1/v1', ownNetwork: true), isTrue);
      expect(await ok('http://[fd00::1]/v1', ownNetwork: true), isTrue);
      expect(await ok('http://1.1.1.1/v1', ownNetwork: true), isFalse);
      expect(await ok('http://172.32.0.1/v1', ownNetwork: true), isFalse);
    });
  });

  group('AiServerClient', () {
    late FakeServer server;
    late AiServerClient client;

    setUp(() async {
      server = FakeServer();
      await server.start();
      client = AiServerClient(
        AiServerAddress.parse('http://localhost:${server.port}/v1'),
      );
    });

    tearDown(() async {
      client.close();
      await server.stop();
    });

    test('lists the models', () async {
      server.reply = (_, _) => {
        'data': [
          {'id': 'gemma-4'},
          {'id': 'other'},
        ],
      };
      expect(await client.models(), ['gemma-4', 'other']);
      expect(server.requests.single.$2, '/v1/models');
      expect(server.requests.single.$4, 'localhost');
    });

    test('a chat turn sends the job and returns the reply without '
        'reasoning', () async {
      server.reply = (_, _) => {
        'choices': [
          {
            'message': {
              'content': '<think>let me see</think>\nBoth plan a trek.',
            },
          },
        ],
      };
      final reply = await client.chat(
        model: 'gemma-4',
        system: 'One sentence.',
        user: 'Note text',
      );
      expect(reply, 'Both plan a trek.');
      final (method, path, body, _) = server.requests.single;
      expect(method, 'POST');
      expect(path, '/v1/chat/completions');
      expect(body!['model'], 'gemma-4');
      expect((body['messages'] as List).last['content'], 'Note text');
    });

    test('a redirect is not followed', () async {
      server.redirectTo = 'http://example.com/v1/models';
      await expectLater(client.models(), throwsA(isA<AiServerUnavailable>()));
      expect(server.requests, hasLength(1));
    });

    test('an error status or a bad reply is "unavailable"', () async {
      server.status = 500;
      await expectLater(client.models(), throwsA(isA<AiServerUnavailable>()));
      server.status = 200;
      server.reply = (_, _) => {'data': 'nope'};
      await expectLater(client.models(), throwsA(isA<AiServerUnavailable>()));
    });

    test('no server running: "unavailable", not a crash', () async {
      await server.stop();
      await expectLater(client.models(), throwsA(isA<AiServerUnavailable>()));
    });

    test('a refused address sends nothing', () async {
      final far = AiServerClient(AiServerAddress.parse('http://8.8.8.8/v1'));
      addTearDown(far.close);
      await expectLater(far.models(), throwsA(isA<AddressRefused>()));
    });
  });
}
