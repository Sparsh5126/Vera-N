import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// What the laptop shows when pairing (docs/LAPTOP_PLAN.md, S2): six words
/// (66 bits, from the 2,048-word BIP-39 English list), and a QR code that
/// also carries the laptop's local addresses. Only someone who has the
/// words can make the proofs both sides check, so a device on the same
/// network can't pair itself in.
class PairingCode {
  PairingCode(this.words)
    : assert(words.length == length, 'six words'),
      _key = sha256
          .convert(utf8.encode('vera-n pairing v1 ${words.join(' ')}'))
          .bytes;

  static const length = 6;

  final List<String> words;
  final List<int> _key;

  /// A new code with words drawn from [list].
  factory PairingCode.random(List<String> list, {Random? random}) {
    final r = random ?? Random.secure();
    return PairingCode([
      for (var i = 0; i < length; i++) list[r.nextInt(list.length)],
    ]);
  }

  /// [typed] read against [list]: words in any case, separated by spaces,
  /// hyphens or commas; each may be cut to its first four letters, which
  /// are unique in the list. Null unless it is exactly six known words.
  static PairingCode? parse(String typed, List<String> list) {
    final parts = typed
        .toLowerCase()
        .split(RegExp(r'[\s,\-]+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (parts.length != length) return null;
    final words = <String>[];
    for (final part in parts) {
      final full = list.contains(part)
          ? part
          : part.length >= 4
          ? list.where((w) => w.startsWith(part)).singleOrNull
          : null;
      if (full == null) return null;
      words.add(full);
    }
    return PairingCode(words);
  }

  /// What the phone puts in its search, so only this laptop answers.
  String get findTag => _mac('find').substring(0, 16);

  /// The phone's proof that it has the words, bound to its own id.
  String phoneProof(String phoneId) => _mac('phone|$phoneId');

  /// The laptop's proof, bound to both ids.
  String laptopProof(String laptopId, String phoneId) =>
      _mac('laptop|$laptopId|$phoneId');

  /// Compares proofs in constant time.
  static bool same(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }

  String _mac(String message) =>
      Hmac(sha256, _key).convert(utf8.encode(message)).toString();

  @override
  String toString() => words.join(' ');
}

/// The laptop's invitation as carried by the QR code. Kept short so the
/// code stays coarse enough for a phone camera to read off a screen: each
/// word as its first four letters (unique in the list), and no device id
/// (the laptop's proof already shows it has the words).
class PairingInvite {
  const PairingInvite({
    required this.code,
    required this.addresses,
    required this.port,
  });

  static const _scheme = 'veran-pair:2:';

  /// How the phone's scanner reads it off a screen: most of the camera
  /// picture, about three times a second (only while scanning).
  static const scanShare = 0.8;
  static const scanEvery = Duration(milliseconds: 300);

  final PairingCode code;

  /// The laptop's local IPv4 addresses, and the pairing port on them.
  final List<String> addresses;
  final int port;

  String encode() {
    final words = [
      for (final w in code.words) w.length > 4 ? w.substring(0, 4) : w,
    ];
    return '$_scheme${words.join('-')}:${addresses.join(',')}:$port';
  }

  /// The invite in a scanned QR code, or null if it isn't one.
  static PairingInvite? decode(String text, List<String> list) {
    if (!text.startsWith(_scheme)) return null;
    final parts = text.substring(_scheme.length).split(':');
    if (parts.length != 3) return null;
    final code = PairingCode.parse(parts[0], list);
    final port = int.tryParse(parts[2]);
    if (code == null || port == null || port <= 0 || port > 65535) return null;
    final addresses = [
      for (final a in parts[1].split(','))
        if (RegExp(r'^\d{1,3}(\.\d{1,3}){3}$').hasMatch(a)) a,
    ];
    if (addresses.isEmpty) return null;
    return PairingInvite(code: code, addresses: addresses, port: port);
  }
}
