/// Every user-facing string in Vera N (UI spec §4–§12), so wording changes
/// are one edit.
///
/// Voice rules: plain language, no technical words, no percentages, and the
/// app never speaks as "Vera".
abstract final class AppCopy {
  static const appName = 'Vera N';

  // Onboarding (UI spec §4). Every claim must be true at launch.
  static const onboardingPrivateTitle = 'Notes that stay yours.';
  static const onboardingPrivateBody =
      'Built for privacy. Your notes live on your phone. '
      'No account, no cloud, no one else reading them.';
  static const onboardingWhatTitle = 'Just write.';
  static const onboardingWhatBody =
      'Vera N quietly notices when your notes connect and suggests links and '
      'tags. Nothing changes unless you say yes.';
  static const onboardingHowTitle = 'The thinking happens on your phone.';
  static const onboardingHowBody =
      'If you have a laptop, it can help with deeper analysis over your own '
      'devices. We have no servers that see your notes.';
  static const onboardingFolderTitle = 'Choose where your notes live.';
  static const onboardingFolderBody =
      'Pick a folder on your phone, or make a new one such as "Vera N" in '
      'Documents. Your notes are saved there '
      'as plain files you can open in other apps, and they stay even if you '
      'remove Vera N.';
  static const chooseFolder = 'Choose folder';
  static const notNow = 'Not now';
  static const folderError = "Couldn't use that folder. Try another one.";

  /// Suggested name for the new folder in the system folder picker.
  static const suggestedFolderName = 'Vera N';
  static const onboardingNameTitle = 'What should we call you?';
  static const skip = 'Skip';

  // Navigation (UI spec §3).
  static const navHome = 'Home';
  static const navSearch = 'Search';
  static const navGraph = 'Graph';
  static const navSettings = 'Settings';
  static const newNote = 'New note';

  // Home (UI spec §5).
  static const greetingMorning = 'Good morning';
  static const greetingAfternoon = 'Good afternoon';
  static const greetingEvening = 'Good evening';
  static String greetingWithName(String greeting, String? name) =>
      (name == null || name.trim().isEmpty) ? greeting : '$greeting, $name';
  static String newConnections(int count) =>
      count == 1 ? '1 new connection' : '$count new connections';
  static const revisit = 'Revisit';
  static const revisitBody = 'You might want to revisit this.';
  static const viewRecent = 'Recent';
  static const viewFolders = 'Folders';
  static const viewTags = 'Tags';
  static const pinned = 'Pinned';
  static const emptyHome = 'Write your first thought.';
  static const loadError = "Couldn't open your notes.";
  static const today = 'Today';
  static const monthsShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  // Review and suggestion card (UI spec §6, §8).
  static String suggestionReason(String title) =>
      'Looks related to your note on $title.';
  static const accept = 'Accept';
  static const reject = 'Reject';
  static const notSure = 'Not sure';
  static const undo = 'Undo';
  static const why = 'Why?';
  static const linked = 'Linked';
  static const reviewNewLabel = 'NEW';
  static const reviewOlderLabel = 'OLDER';
  static const allCaughtUp = 'All caught up.';
  static String reviewMore(int batchSize) => 'Review $batchSize more';
  static const close = 'Close';
  static const reviewHintTitle = 'Swipe to decide';
  static const reviewHintRight = 'Right: link them';
  static const reviewHintLeft = 'Left: not related';
  static const reviewHintUp = 'Up: not sure yet';
  static const reviewHintDown = 'Down: undo';
  static const gotIt = 'Got it';
  static String reviewProgress(int done, int total) =>
      'Suggestion ${done + 1} of $total';

  // Note view (UI spec §7).
  static const back = 'Back';
  static const copyNote = 'Copy note';
  static const copied = 'Copied';
  static const pin = 'Pin';
  static const unpin = 'Unpin';
  static const moreOptions = 'More options';
  static const saved = 'Saved';
  static const tags = 'Tags';
  static const suggestedLinks = 'Suggested links';
  static const hasSuggestions = 'Has suggestions';
  static String suggestedLink(String title) => 'Suggested link: $title';
  static const notLinked = 'Not linked';
  static const mentionedIn = 'Mentioned in';
  static const linkPickerHint = 'Link to a note…';
  static const bullet = '•';
  static const checkboxDone = 'Done';
  static const checkboxNotDone = 'Not done';
  static const formatBold = 'Bold';
  static const formatList = 'List';
  static const formatChecklist = 'Checklist';
  static const formatLink = 'Link to a note';
  static const addTag = 'Add tag';
  static const tagNameHint = 'Tag name';
  static String removeTag(String tag) => 'Remove #$tag';
  static const tagRemoved = 'Tag removed';
  static const noFolder = 'No folder';
  static const folderSection = 'Folder';
  static const addToFolder = 'Add to folder';
  static const newFolder = 'New folder';
  static const folderNameHint = 'Folder name';
  static String movedTo(String folder) => 'Moved to $folder';
  static const movedOutOfFolder = 'Moved out of its folder';
  static const archive = 'Archive';
  static const delete = 'Delete';
  static const movedToTrash = 'Moved to trash';
  static const attachments = 'Attachments';

  // Search (UI spec §9).
  static const searchHint = 'Search notes…';
  static const filterFolder = 'Folder';
  static const filterTag = 'Tag';
  static const filterDate = 'Date';
  static const anyFolder = 'Any folder';
  static const anyTag = 'Any tag';
  static const anyTime = 'Any time';
  static const dateToday = 'Today';
  static const dateLast7Days = 'Last 7 days';
  static const dateLast30Days = 'Last 30 days';
  static const dateThisYear = 'This year';
  static const noFoldersYet = 'No folders yet.';
  static const noTagsYet = 'No tags yet.';
  static String tagLabel(String tag) => '#$tag';
  static const recentSearches = 'Recent searches';
  static const matches = 'Matches';
  static const similarInMeaning = 'Similar in meaning';
  static const emptySearch = 'No notes found.';
  static const clearSearch = 'Clear';
  static const removeRecentSearch = 'Remove';

  // Graph (UI spec §10).
  static const emptyGraph = 'Links between your notes will appear here.';
  static const showSuggestions = 'Show suggestions';
  static const open = 'Open';
  static const focus = 'Focus';
  static const showUnlinked = 'Show unlinked notes';
  static const findNote = 'Find a note';
  static const focusOff = 'Show all';
  static String focusOn(String title) => 'Focus: $title';
  static String hops(int n) => n == 1 ? '1 step' : '$n steps';
  static String suggestedLinkBetween(String a, String b) =>
      'Suggested link: $a and $b';
  static String graphDot(String title, int links) => switch (links) {
    0 => '$title, no links',
    1 => '$title, 1 link',
    _ => '$title, $links links',
  };

  // Settings (UI spec §11).
  static const sectionYou = 'YOU';
  static const sectionApp = 'APP';
  static const sectionSync = 'SYNC';
  static const sectionSmartSuggestions = 'SMART SUGGESTIONS';
  static const sectionData = 'DATA';
  static const sectionAdvanced = 'ADVANCED';
  static const sectionAbout = 'ABOUT';
  static const name = 'Name';
  static const layout = 'Layout';
  static const layoutGrid = 'Grid';
  static const layoutList = 'List';
  static const openAppTo = 'Open app to';
  static const theme = 'Theme';
  static const themeSystem = 'System';
  static const themeDark = 'Dark';
  static const themeLight = 'Light';
  static const quickCapture = 'Quick capture';
  static const quickCaptureValue = 'Widget and tile';
  static const addWidget = 'Add widget';
  static const addQuickSettingsTile = 'Add Quick Settings tile';
  static const notesFolder = 'Notes folder';
  static const notesFolderNone = 'On this phone only';
  static const notesFolderNoneHint =
      'Choose a folder so your notes stay if the app is removed.';
  static const syncStatus = 'Status';
  static const suggestConnections = 'Suggest connections';
  static const analyzeOnlyWhenCharging = 'Analyze only when charging';
  static const laptopConnection = 'Laptop connection';
  static const connected = 'Connected';
  static const notConnected = 'Not connected';
  static const pairLaptop = 'Pair';
  static const testConnection = 'Test connection';
  static const forgetDevice = 'Forget device';
  static const trash = 'Trash';
  static const trashValue = 'Kept 30 days';
  static const exportNotes = 'Export notes';
  static const exportValue = 'Markdown .zip';
  static const rebuildSuggestions = 'Rebuild suggestions';
  static const resetRejected = 'Reset rejected suggestions';
  static const privacy = 'Privacy';
  static const privacyValue = 'Everything stays on your devices.';
  static const version = 'Version';
  static const nameHint = 'Your name';
  static const startHome = 'Home';
  static const startNewNote = 'New note';
  static const suggestionsRebuilt = 'Suggestions will be rebuilt soon.';
  static const rejectedReset = 'Rejected suggestions can come back.';
  static const showAdvanced = 'Show advanced';
  static const hideAdvanced = 'Hide advanced';
  static const licenses = 'Licenses';

  // Capture shortcuts outside the app (UI spec §5).
  static const widgetQuickNoteHint = 'Write a thought…';
  static const shortcutReview = 'Review connections';
}
