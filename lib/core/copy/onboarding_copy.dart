/// Onboarding's words (UI spec §4), on a phone and on a laptop. Every
/// claim must be true at launch. Imported through `app_copy.dart`.
abstract final class OnboardingCopy {
  static const onboardingPrivateTitle = 'Notes that stay yours.';
  static const onboardingPrivateBody =
      'Built for privacy. Your notes live on your phone. No account, no '
      'login, no cloud, no one else reading them. The code is open source, '
      'so anyone can check.';
  static const onboardingWhatTitle = 'Just write.';
  static const onboardingWhatBody =
      'Vera N quietly notices when your notes connect and suggests links and '
      'tags, right here on your phone. Nothing changes unless you say yes.';
  static const onboardingHowTitle = 'The thinking happens on your phone.';
  static const onboardingHowBody =
      'Suggestions are worked out on this phone, never sent anywhere. If you '
      'have a laptop, it can help with deeper analysis over your own '
      'devices. We have no servers that see your notes.';
  static const onboardingRemindTitle = 'Reminders, only when you ask.';
  static const onboardingRemindBody =
      'Write “remind me tomorrow at 9 am” in any note and your phone reminds '
      'you then. Only notes that ask, only for a time ahead, and nothing '
      'else ever sends a notification. It all stays on this phone, and you '
      'can turn it off in Settings.';
  static const onboardingNameBody =
      'Only for the greeting. It stays on this phone.';

  // The same pages on a laptop (docs/LAPTOP_PLAN.md): "this computer"
  // and "your devices" instead of "your phone"; no reminders page
  // (reminders are phone-only).
  static const onboardingPrivateBodyDesktop =
      'Built for privacy. Your notes live on your own devices, as plain '
      'files. No account, no login, no cloud, no one else reading them. The '
      'code is open source, so anyone can check.';
  static const onboardingWhatBodyDesktop =
      'Vera N quietly notices when your notes connect and suggests links and '
      'tags, right here on this computer. Nothing changes unless you say yes.';
  static const onboardingHowTitleDesktop =
      'The thinking happens on this computer.';
  static const onboardingHowBodyDesktop =
      'Suggestions are worked out here, never sent anywhere. If you also use '
      'Vera N on your phone, pair them in Settings: your notes then travel '
      'straight between them over your own Wi-Fi. We have no servers that '
      'see your notes.';
  static const onboardingFolderBodyDesktop =
      'Pick a folder for your notes, such as a new “Vera N” in Documents. '
      'Notes are plain files you can open in other apps. Nothing is '
      'uploaded.';
  static const onboardingNameBodyDesktop =
      'Only for the greeting. It stays on your devices.';
  static const privacyLineDesktop =
      'Private · Open\u00A0source · On\u00A0your\u00A0devices · '
      'No\u00A0account · No\u00A0cloud';

  /// On every onboarding page.
  /// Non-breaking spaces inside each item, so a line only breaks between
  /// items, never as "No / cloud".
  static const privacyLine =
      'Private · Open source · On this phone · '
      'No account · No cloud';
  static const onboardingFolderTitle = 'Choose where your notes live.';
  static const onboardingFolderBody =
      'Pick a folder on your phone, or make a new one such as “Vera N” in '
      'Documents. Your notes are saved there '
      'as plain files you can open in other apps, and they stay even if you '
      'remove Vera N. Nothing is uploaded.';
  static const onboardingNameTitle = 'What should we call you?';
  static String onboardingPage(int page, int total) => 'Page $page of $total';
}
