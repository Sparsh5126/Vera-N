/// The laptop helper's words in Settings (docs/LAPTOP_PLAN.md, L4), on
/// both devices. It is optional everywhere: no line may suggest that
/// something is missing without it. Imported through `app_copy.dart`.
abstract final class LaptopCopy {
  // Laptop: AI ON THIS COMPUTER.
  static const section = 'AI ON THIS COMPUTER';
  static const helpSwitch = 'Help from a local AI app';
  static const helpHint =
      'Deeper suggestions from an AI app on this computer, such as LM '
      'Studio, while you’re away and it’s plugged in. Optional: everything '
      'else works without it.';
  static const address = 'Address';
  static const addressHint = 'Where the AI app answers';
  static const ownNetwork = 'Also allow my own network';
  static const ownNetworkHint =
      'For an AI app on another of your computers at home. Never the '
      'internet.';
  static const model = 'Model';
  static const modelAutomatic = 'Automatic';
  static const noModels = 'No models to choose from yet.';
  static const check = 'Check';
  static const checking = 'Checking…';
  static const found = 'Ready. The AI app answered.';
  static const nothing =
      'Not set up. No AI app answered at this address, which is fine.';
  static const notLocal =
      'That address isn’t on this computer, so nothing is sent there.';
  static const notLocalOrNetwork =
      'That address isn’t on this computer or your own network, so nothing '
      'is sent there.';
  static const invalid =
      'That isn’t an address. Try one like '
      'http://localhost:1234/v1';
  static const jobWhy = 'Explain suggested links';
  static const jobTags = 'Suggest new tags';
  static const jobTopics = 'Find topics';
  static const jobCopies = 'Find copies';
  static const lastHelped = 'Last helped';
  static const notYet = 'Not yet';

  // Phone: the Laptop row.
  static const laptop = 'Laptop';
  static const notSetUp = 'Not set up';
  static String lastHelpedOn(String day) => 'Last helped: $day';
  static const explainTitle = 'Help from a laptop';
  static const explain =
      'Vera N on a laptop can add deeper suggestions with an AI app there. '
      'Share your notes folder with it using Syncthing, and its suggestions '
      'appear here. This phone works fine on its own.';
  static const gotIt = 'Got it';
}
