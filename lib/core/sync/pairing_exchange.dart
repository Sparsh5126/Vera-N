import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'pairing_code.dart';

/// The other device, as pairing found it.
class PairedDevice {
  const PairedDevice({
    required this.id,
    required this.name,
    required this.address,
    required this.syncPort,
  });

  final String id;
  final String name;

  /// Its address on the home network, and the port its engine syncs on.
  final String address;
  final int syncPort;
}

enum PairingProblem { notFound, wrongCode, refused }

class PairingFailed implements Exception {
  const PairingFailed(this.problem);

  final PairingProblem problem;

  @override
  String toString() => 'PairingFailed(${problem.name})';
}

/// The UDP port the phone's search goes to, on the home network only.
const pairingFindPort = 21097;

/// The laptop's side of pairing (docs/LAPTOP_PLAN.md, S2): open for
/// [window], it answers a phone's search tagged with the code and accepts
/// one phone whose proof matches. After [maxTries] wrong proofs it closes.
class PairingHost {
  PairingHost({
    required this.code,
    required this.laptopId,
    required this.name,
    required this.syncPort,
    required this.onPhone,
    this.findPort = pairingFindPort,
    this.window = const Duration(minutes: 5),
  });

  static const maxTries = 5;

  final PairingCode code;
  final String laptopId;
  final String name;
  final int syncPort;

  /// Adds the phone (device and shared folder) before the reply goes out.
  final Future<void> Function(PairedDevice phone) onPhone;
  final int findPort;
  final Duration window;

  HttpServer? _http;
  RawDatagramSocket? _udp;
  Timer? _timer;
  var _wrong = 0;
  final _done = Completer<PairedDevice?>();

  /// Resolves with the phone once paired, or null when the window closed.
  Future<PairedDevice?> get result => _done.future;

  /// Starts listening; returns what the QR code shows.
  Future<PairingInvite> open() async {
    final http = await HttpServer.bind(InternetAddress.anyIPv4, 0);
    _http = http;
    http.listen(_onRequest);
    final udp = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      findPort,
      reuseAddress: true,
    );
    _udp = udp;
    udp.listen((event) {
      if (event == RawSocketEvent.read) _onFind(udp.receive());
    });
    _timer = Timer(window, () => unawaited(close()));
    return PairingInvite(
      code: code,
      laptopId: laptopId,
      addresses: await homeAddresses(),
      port: http.port,
    );
  }

  Future<void> close() async {
    _timer?.cancel();
    _udp?.close();
    await _http?.close(force: true);
    _udp = null;
    _http = null;
    if (!_done.isCompleted) _done.complete(null);
  }

  void _onFind(Datagram? d) {
    if (d == null) return;
    try {
      final json = jsonDecode(utf8.decode(d.data));
      if (json is! Map || json['find'] != code.findTag) return;
      final reply = utf8.encode(
        jsonEncode({'veran': 1, 'here': code.findTag, 'port': _http!.port}),
      );
      _udp?.send(reply, d.address, d.port);
    } on FormatException {
      // Not ours.
    }
  }

  Future<void> _onRequest(HttpRequest request) async {
    final response = request.response;
    try {
      if (request.method != 'POST' || request.uri.path != '/pair') {
        response.statusCode = HttpStatus.notFound;
        return;
      }
      final body = jsonDecode(await utf8.decodeStream(request));
      final id = body is Map ? body['id'] : null;
      final proof = body is Map ? body['proof'] : null;
      final port = body is Map ? body['syncPort'] : null;
      final phoneName = body is Map ? body['name'] : null;
      if (id is! String || proof is! String || port is! int) {
        response.statusCode = HttpStatus.badRequest;
        return;
      }
      if (_done.isCompleted || !PairingCode.same(proof, code.phoneProof(id))) {
        response.statusCode = HttpStatus.forbidden;
        _wrong++;
        return;
      }
      final phone = PairedDevice(
        id: id,
        name: phoneName is String ? phoneName : 'Phone',
        address: request.connectionInfo!.remoteAddress.address,
        syncPort: port,
      );
      await onPhone(phone);
      response.headers.contentType = ContentType.json;
      response.write(
        jsonEncode({
          'id': laptopId,
          'name': name,
          'proof': code.laptopProof(laptopId, id),
          'syncPort': syncPort,
        }),
      );
      _done.complete(phone);
    } on FormatException {
      response.statusCode = HttpStatus.badRequest;
    } finally {
      await response.close();
      // Closed only after the reply went out.
      if (_done.isCompleted || _wrong >= maxTries) unawaited(close());
    }
  }

  /// This computer's addresses on private networks (never the internet).
  static Future<List<String>> homeAddresses() async {
    final out = <String>[];
    for (final i in await NetworkInterface.list(
      type: InternetAddressType.IPv4,
    )) {
      for (final a in i.addresses) {
        final b = a.rawAddress;
        final private =
            b[0] == 10 ||
            (b[0] == 172 && b[1] >= 16 && b[1] <= 31) ||
            (b[0] == 192 && b[1] == 168) ||
            (b[0] == 100 && b[1] >= 64 && b[1] <= 127);
        if (private) out.add(a.address);
      }
    }
    return out;
  }
}

/// The phone's side: with the QR [invite] it goes straight to the laptop;
/// with typed words it first finds it on the home network. Throws
/// [PairingFailed] when no laptop answers, the code is wrong, or the reply
/// doesn't prove the laptop has the code.
abstract final class PairingGuest {
  static Future<PairedDevice> join({
    required PairingCode code,
    required String phoneId,
    required String name,
    required int syncPort,
    PairingInvite? invite,
    int findPort = pairingFindPort,
    InternetAddress? broadcast,
    Duration searchFor = const Duration(seconds: 15),
  }) async {
    final targets = invite != null
        ? [for (final a in invite.addresses) (a, invite.port)]
        : [await _find(code, findPort, broadcast, searchFor)];
    var problem = PairingProblem.notFound;
    for (final (address, port) in targets) {
      try {
        final reply = await _post(address, port, {
          'id': phoneId,
          'name': name,
          'proof': code.phoneProof(phoneId),
          'syncPort': syncPort,
        });
        final id = reply['id'], proof = reply['proof'];
        final laptopPort = reply['syncPort'];
        if (id is! String || proof is! String || laptopPort is! int) {
          throw const PairingFailed(PairingProblem.refused);
        }
        final expected = code.laptopProof(id, phoneId);
        if (!PairingCode.same(proof, expected) ||
            (invite != null && invite.laptopId != id)) {
          throw const PairingFailed(PairingProblem.refused);
        }
        final laptopName = reply['name'];
        return PairedDevice(
          id: id,
          name: laptopName is String ? laptopName : 'Laptop',
          address: address,
          syncPort: laptopPort,
        );
      } on PairingFailed catch (e) {
        problem = e.problem;
      } on SocketException {
        // Try the next address.
      } on HttpException {
        // The laptop closed the connection: try the next address.
      } on TimeoutException {
        // Try the next address.
      }
    }
    throw PairingFailed(problem);
  }

  static Future<(String, int)> _find(
    PairingCode code,
    int findPort,
    InternetAddress? broadcast,
    Duration searchFor,
  ) async {
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    socket.broadcastEnabled = true;
    final found = Completer<(String, int)>();
    socket.listen((event) {
      if (event != RawSocketEvent.read) return;
      final d = socket.receive();
      if (d == null || found.isCompleted) return;
      try {
        final json = jsonDecode(utf8.decode(d.data));
        final port = json is Map ? json['port'] : null;
        if (json is Map && json['here'] == code.findTag && port is int) {
          found.complete((d.address.address, port));
        }
      } on FormatException {
        // Not ours.
      }
    });
    final ask = utf8.encode(jsonEncode({'veran': 1, 'find': code.findTag}));
    final to = broadcast ?? InternetAddress('255.255.255.255');
    final timer = Timer.periodic(const Duration(seconds: 1), (_) {
      socket.send(ask, to, findPort);
    });
    socket.send(ask, to, findPort);
    try {
      return await found.future.timeout(searchFor);
    } on TimeoutException {
      throw const PairingFailed(PairingProblem.notFound);
    } finally {
      timer.cancel();
      socket.close();
    }
  }

  static Future<Map<String, Object?>> _post(
    String address,
    int port,
    Map<String, Object?> body,
  ) async {
    final http = HttpClient()
      ..connectionTimeout = const Duration(seconds: 5)
      ..findProxy = ((_) => 'DIRECT');
    try {
      final request = await http.post(address, port, '/pair');
      request.headers.contentType = ContentType.json;
      request.add(utf8.encode(jsonEncode(body)));
      final response = await request.close().timeout(
        const Duration(seconds: 15),
      );
      final text = await utf8.decodeStream(response);
      if (response.statusCode == HttpStatus.forbidden) {
        throw const PairingFailed(PairingProblem.wrongCode);
      }
      if (response.statusCode != HttpStatus.ok) {
        throw const PairingFailed(PairingProblem.refused);
      }
      final json = jsonDecode(text);
      if (json is! Map) throw const PairingFailed(PairingProblem.refused);
      return json.cast<String, Object?>();
    } on FormatException {
      throw const PairingFailed(PairingProblem.refused);
    } finally {
      http.close(force: true);
    }
  }
}
