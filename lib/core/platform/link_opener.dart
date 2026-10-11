import 'dart:io';

import 'launch_channel.dart';

/// Opens a link card's address in the browser. Vera N never goes online
/// itself: it only hands the address to the system.
abstract final class LinkOpener {
  /// False if [url] isn't a web address or nothing could open it.
  static Future<bool> open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      return false;
    }
    if (Platform.isAndroid) return LaunchChannel.openLink(url);
    // On a laptop, the system's default browser. The address goes as one
    // argument, never through a shell.
    final (command, args) = Platform.isWindows
        ? ('rundll32', ['url.dll,FileProtocolHandler', url])
        : Platform.isMacOS
        ? ('open', [url])
        : ('xdg-open', [url]);
    try {
      await Process.start(command, args, mode: ProcessStartMode.detached);
      return true;
    } on ProcessException {
      return false;
    }
  }
}
