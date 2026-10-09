import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/ai/embedder/onnx_embedder.dart';
import 'package:vera_n/core/ai/matching/vectors.dart';
import 'package:vera_n/core/booster/ai_server_address.dart';
import 'package:vera_n/core/booster/ai_server_client.dart';
import 'package:vera_n/core/booster/booster_prompts.dart';
import 'package:vera_n/core/booster/booster_run.dart';
import 'package:vera_n/core/booster/laptop_booster.dart';
import 'package:vera_n/core/models/booster_prefs.dart';
import 'package:vera_n/core/models/booster_result.dart';
import 'package:vera_n/core/models/chunk_vector.dart';
import 'package:vera_n/core/models/suggestion_draft.dart';
import 'package:vera_n/core/storage/repositories/analysis_repository.dart';
import 'package:vera_n/core/storage/repositories/booster_repository.dart';
import 'package:vera_n/core/storage/repositories/settings_repository.dart';
import 'package:vera_n/core/storage/repositories/suggestions_repository.dart';

import '../../support/fake_ai_server.dart';
import '../../support/storage_harness.dart';

/// A unit vector along [axis], tilted by [tilt] towards [towards].
Float32List direction(int axis, {double tilt = 0, int towards = 7}) {
  final v = Float32List(16);
  v[axis] = cos(tilt);
  v[towards] += sin(tilt);
  return v;
}

const _trekWords =
    'with friends, pack warm clothes, boots and a torch for the cold '
    'nights up there';

void main() {
  late StorageHarness h;
  late FakeServer server;
  late AiServerClient client;
  late AnalysisRepository analysis;
  late SuggestionsRepository suggestions;
  late BoosterRepository booster;
  final model = OnnxEmbedder().model;
  late Map<String, int> notes;

  Future<int> note(String body, Float32List meaning) async {
    final ref = await h.repo.create(body);
    final row = await h.row(ref);
    await analysis.save(ref, row.contentHash, model, [
      ChunkVector(
        note: ref,
        idx: 0,
        start: 0,
        end: row.body.length,
        hash: 'c$ref',
        vector: Vectors.quantize(meaning),
      ),
    ], DateTime(2026, 10, 9));
    return ref;
  }

  setUp(() async {
    h = StorageHarness();
    analysis = AnalysisRepository(h.db);
    suggestions = SuggestionsRepository(h.db);
    booster = BoosterRepository(h.db, h.store);
    server = FakeServer();
    await server.start();
    client = AiServerClient(
      AiServerAddress.parse('http://localhost:${server.port}/v1'),
    );
    server.chatWith(
      (system, user) => switch (system) {
        BoosterPrompts.why => 'Both plan a trek.',
        BoosterPrompts.duplicate => 'YES\nBoth list the same groceries.',
        BoosterPrompts.topic => 'Trek planning',
        _ => '["Trek", "packing"]',
      },
    );
    // Three notes on one topic (none close enough to be copies), two
    // near copies, and one short note.
    notes = {
      't1': await note('Triund trek in spring $_trekWords', direction(0)),
      't2': await note(
        'Kedarkantha trek in winter $_trekWords',
        direction(0, tilt: 0.5),
      ),
      't3': await note(
        'Hampta pass trek in summer $_trekWords',
        direction(0, tilt: 0.5, towards: 8),
      ),
      'd1': await note(
        'Groceries: milk, eggs, bread, rice, dal, onions, tomatoes, salt',
        direction(3),
      ),
      'd2': await note(
        'Groceries: milk, eggs, bread, rice, dal, onion, tomato, salt',
        direction(3, tilt: 0.1),
      ),
      'short': await note('Call the plumber', direction(5)),
    };
    await h.repo.setTags(notes['t1']!, ['trek']);
    await suggestions.add(
      [
        SuggestionDraft(
          kind: 'link',
          noteA: notes['t1']!,
          noteB: notes['t2']!,
          score: .7,
          chunkA: 0,
          chunkB: 0,
        ),
      ],
      DateTime.now(),
      const Duration(days: 30),
    );
  });

  tearDown(() async {
    client.close();
    await server.stop();
    await h.dispose();
  });

  BoosterRun run({bool Function()? stop}) => BoosterRun(
    client: client,
    model: 'gemma-4',
    booster: booster,
    analysis: analysis,
    suggestions: suggestions,
    deviceId: 'laptop1',
    embedderModel: model,
    stopRequested: stop ?? () => false,
  );

  Future<String> key(String name) async =>
      (await h.repo.ensureId(notes[name]!))!;

  Future<List<BoosterResult>> results(BoosterKind kind) async =>
      (await booster.readAll()).where((r) => r.kind == kind).toList();

  test('the four jobs: a "Why?" for the waiting link, the copies, the '
      'topic, and new tag names; each written to the results file', () async {
    expect(await run().run(), isTrue);

    final why = (await results(BoosterKind.why)).single;
    expect(why.values, ['Both plan a trek.']);
    expect(why.notes.map((n) => n.key), [await key('t1'), await key('t2')]);
    // Only the matched passages travel to the server for a "Why?".
    expect(server.chats.first.$2, contains('Passage 1:'));

    final dup = (await results(BoosterKind.duplicate)).single;
    expect(dup.values, ['Both list the same groceries.']);
    expect(dup.notes.map((n) => n.key).toSet(), {
      await key('d1'),
      await key('d2'),
    });

    final topic = (await results(BoosterKind.topic)).single;
    expect(topic.values, ['trek-planning']);
    expect(topic.notes, hasLength(3));

    final tags = {
      for (final r in await results(BoosterKind.tags)) r.notes.single.key: r,
    };
    // Short notes (the plumber, the lists) aren't asked; "Trek" folds into the existing "trek",
    // which t1 already has.
    expect(tags.keys, isNot(contains(await key('short'))));
    expect(tags[await key('t1')]!.values, ['packing']);
    expect(tags[await key('t2')]!.values, ['trek', 'packing']);
    expect(server.chats, hasLength(6));
  });

  test('nothing is asked twice; a changed note is asked again', () async {
    await run().run();
    final before = server.chats.length;
    await run().run();
    expect(server.chats.length, before);

    await h.repo.updateBody(
      notes['t1']!,
      'Triund trek in late spring $_trekWords',
    );
    await run().run();
    final asked = server.chats.skip(before).map((c) => c.$1).toList();
    // Its "Why?", its topic and its tags; the copies are untouched.
    expect(asked, [
      BoosterPrompts.why,
      BoosterPrompts.topic,
      BoosterPrompts.tags,
    ]);
    // The old results for t1 were dropped from the file as stale.
    final file = h.store.appFiles[BoosterRepository.fileName('laptop1')]!;
    expect('\n'.allMatches(file).length, 6);
  });

  test('a key press stops the run between questions', () async {
    var asked = 0;
    server.chatWith((_, _) {
      asked++;
      return 'Both plan a trek.';
    });
    expect(await run(stop: () => asked >= 1).run(), isFalse);
    expect(server.chats, hasLength(1));
  });

  LaptopBooster laptop() => LaptopBooster(
    booster: booster,
    analysis: analysis,
    suggestions: suggestions,
    settings: SettingsRepository(h.db),
  );

  Future<void> prefs(BoosterPrefs p) =>
      SettingsRepository(h.db).saveBoosterPrefs(p);

  String here() => 'http://localhost:${server.port}/v1';

  test(
    'no AI app running: nothing happens and nothing is left to do',
    () async {
      final address = here();
      await server.stop();
      await prefs(BoosterPrefs(address: address));
      expect(await laptop().runOnce(() => false), isTrue);
      expect(await booster.readAll(), isEmpty);
    },
  );

  test('switched off: not even the local check runs', () async {
    await prefs(BoosterPrefs(address: here(), on: false));
    expect(await laptop().runOnce(() => false), isTrue);
    expect(server.requests, isEmpty);
  });

  test('only the jobs switched on run, with the chosen model', () async {
    await prefs(
      BoosterPrefs(address: here(), model: 'gemma-4', jobs: {BoosterKind.why}),
    );
    expect(await laptop().runOnce(() => false), isTrue);
    expect(server.chats.map((c) => c.$1), [BoosterPrompts.why]);
    expect(server.requests.last.$3!['model'], 'gemma-4');
  });

  test('the check in Settings: found with chat models only, nothing, or '
      'refused', () async {
    final found = await LaptopBooster.check(BoosterPrefs(address: here()));
    expect(found.reach, BoosterReach.found);
    expect(found.models, ['gemma-4']);
    expect(
      (await LaptopBooster.check(
        const BoosterPrefs(address: 'http://8.8.8.8/v1'),
      )).reach,
      BoosterReach.notLocal,
    );
    expect(
      (await LaptopBooster.check(const BoosterPrefs(address: 'nonsense')))
          .reach,
      BoosterReach.invalid,
    );
    final address = here();
    await server.stop();
    expect(
      (await LaptopBooster.check(BoosterPrefs(address: address))).reach,
      BoosterReach.nothing,
    );
  });

  test('prefs survive a round trip; damaged ones fall back to defaults', () {
    const p = BoosterPrefs(
      on: false,
      address: 'http://localhost:11434/v1',
      ownNetwork: true,
      model: 'qwen',
      jobs: {BoosterKind.tags},
    );
    final back = BoosterPrefs.fromJson(p.toJson());
    expect(back.on, isFalse);
    expect(back.address, p.address);
    expect(back.ownNetwork, isTrue);
    expect(back.model, 'qwen');
    expect(back.jobs, {BoosterKind.tags});
    final broken = BoosterPrefs.fromJson({'jobs': 'x', 'address': 3});
    expect(broken.address, BoosterPrefs.defaultAddress);
    expect(broken.jobs, BoosterKind.values.toSet());
    expect(BoosterPrefs.fromJson(null).on, isTrue);
  });

  test('the model: the preferred one, else the first chat model', () {
    const ids = ['text-embedding-nomic', 'gemma-4', 'qwen'];
    expect(LaptopBooster.pickModel(ids, 'qwen'), 'qwen');
    expect(LaptopBooster.pickModel(ids, 'gone'), 'gemma-4');
    expect(LaptopBooster.pickModel(ids, null), 'gemma-4');
    expect(LaptopBooster.pickModel(['nomic-embed'], null), isNull);
  });
}
