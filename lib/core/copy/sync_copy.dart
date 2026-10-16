/// Built-in sync's words (docs/LAPTOP_PLAN.md, S4). Plain words: no
/// "device id", "engine" or "Syncthing". Imported through `app_copy.dart`.
abstract final class SyncCopy {
  static const withPhone = 'Sync with your phone';
  static const withLaptop = 'Sync with your laptop';
  static const notPaired = 'Not paired';
  static String waiting(String name) =>
      'Paired with $name. Syncs when both are on the same Wi-Fi.';
  static String inSync(String name) => 'In sync with $name';
  static String lastSynced(String day) => 'Last synced: $day';
  static const problem = 'Sync couldn’t start. Try again later.';
  // Phone, paired, once the laptop's AI has added suggestions.
  static String laptopHelped(String day) => 'Your laptop last helped: $day';
  static const onlyWifi =
      'Only over your own Wi-Fi, straight between your devices. Nothing goes '
      'through the internet.';

  // Laptop: the pairing window.
  static const pairPhoneTitle = 'Pair your phone';
  static const pairPhoneBody =
      'On your phone, open Vera N, go to Settings, then Sync with your '
      'laptop. Scan this code, or type the six words. Both need to be on '
      'the same Wi-Fi.';
  static const waitingForPhone = 'Waiting for your phone…';
  static const pairedPhone =
      'Paired. Your notes now stay in sync on this Wi-Fi.';
  static const codeExpired = 'The code expired. Open it again to pair.';

  // Phone: joining.
  static const pairLaptopTitle = 'Pair with your laptop';
  static const pairLaptopBody =
      'On your laptop, open Vera N, go to Settings, then Sync with your '
      'phone. Then:';
  static const scanCode = 'Scan the code';
  static const typeWords = 'Type the six words';
  static const wordsHint = 'The six words on your laptop';
  static const lookingForLaptop = 'Looking for your laptop…';
  static String pairedWith(String name) => 'Paired with $name.';
  static const notFound =
      'Couldn’t find your laptop. Check that both are on the same Wi-Fi '
      'and the code is still showing.';
  static const wrongCode = 'Those words don’t match. Check them and try again.';
  static const notACode = 'That isn’t a Vera N pairing code.';
  static const pointCamera = 'Point the camera at the code on your laptop.';

  // Both: paired.
  static const unpair = 'Unpair';
  static const unpaired = 'Unpaired. Your notes stay on both devices.';
}
