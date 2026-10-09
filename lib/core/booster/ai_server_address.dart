import 'dart:io';

/// Why an AI server address was refused.
enum AddressProblem {
  /// Not an `http://` or `https://` address with a host.
  invalid,

  /// The name could not be looked up.
  unknownHost,

  /// It leads off this computer (or, when allowed, off the user's own
  /// network): note text would leave the user's devices.
  notLocal,
}

class AddressRefused implements Exception {
  const AddressRefused(this.problem, this.address);

  final AddressProblem problem;
  final String address;

  @override
  String toString() => 'AddressRefused(${problem.name}: $address)';
}

/// The address of the AI server the laptop booster talks to
/// (docs/LAPTOP_PLAN.md, L2). Note text is sent there, so only a server on
/// this computer is accepted; with [ownNetwork], also one on the user's
/// own network (private ranges, Tailscale), never the internet.
///
/// The check is made on the resolved address, not the name, so a name
/// that points somewhere else is refused too.
class AiServerAddress {
  AiServerAddress._(this.uri, this.ownNetwork);

  /// LM Studio's default (product spec §5).
  static const fallback = 'http://localhost:1234/v1';

  final Uri uri;
  final bool ownNetwork;

  /// Parses [text]; throws [AddressRefused] when it isn't an http(s)
  /// address with a host. Whether it is local is checked by [resolve].
  factory AiServerAddress.parse(String text, {bool ownNetwork = false}) {
    final uri = Uri.tryParse(text.trim());
    final ok =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty &&
        uri.userInfo.isEmpty;
    if (!ok) throw AddressRefused(AddressProblem.invalid, text);
    final path = uri.path.endsWith('/')
        ? uri.path.substring(0, uri.path.length - 1)
        : uri.path;
    return AiServerAddress._(
      uri.replace(path: path, query: null, fragment: null),
      ownNetwork,
    );
  }

  /// Looks the host up and returns the address to connect to. Throws
  /// [AddressRefused] unless every address it resolves to is allowed.
  Future<InternetAddress> resolve() async {
    final literal = InternetAddress.tryParse(uri.host);
    final List<InternetAddress> found;
    if (literal != null) {
      found = [literal];
    } else {
      try {
        found = await InternetAddress.lookup(uri.host);
      } on SocketException {
        throw AddressRefused(AddressProblem.unknownHost, '$uri');
      }
    }
    if (found.isEmpty) {
      throw AddressRefused(AddressProblem.unknownHost, '$uri');
    }
    if (!found.every(allowed)) {
      throw AddressRefused(AddressProblem.notLocal, '$uri');
    }
    // LM Studio listens on IPv4 only; "localhost" may list ::1 first.
    return found.firstWhere(
      (a) => a.type == InternetAddressType.IPv4,
      orElse: () => found.first,
    );
  }

  /// Whether [a] may receive note text.
  bool allowed(InternetAddress a) =>
      a.isLoopback || (ownNetwork && isOwnNetwork(a));

  /// Private and link-local ranges, and Tailscale's 100.64.0.0/10.
  static bool isOwnNetwork(InternetAddress a) {
    if (a.isLinkLocal) return true;
    final b = a.rawAddress;
    if (a.type == InternetAddressType.IPv4) {
      return b[0] == 10 ||
          (b[0] == 172 && b[1] >= 16 && b[1] <= 31) ||
          (b[0] == 192 && b[1] == 168) ||
          (b[0] == 100 && b[1] >= 64 && b[1] <= 127);
    }
    // IPv6 unique local addresses, fc00::/7.
    return a.type == InternetAddressType.IPv6 && (b[0] & 0xfe) == 0xfc;
  }
}
