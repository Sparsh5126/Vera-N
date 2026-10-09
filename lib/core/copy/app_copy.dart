export 'onboarding_copy.dart';

/// Every user-facing string in Vera N (UI spec §4–§12), so wording changes
/// are one edit.
///
/// Voice rules: plain language, no technical words, no percentages, and the
/// app never speaks as "Vera".
abstract final class AppCopy {
  static const appName = 'Vera N';

  static const chooseFolder = 'Choose folder';
  static const notNow = 'Not now';
  static const folderError = "Couldn't use that folder. Try another one.";

  /// Suggested name for the new folder in the system folder picker.
  static const suggestedFolderName = 'Vera N';
  static const skip = 'Skip';
  static const next = 'Next';
  static const done = 'Done';

  // A note changed both here and outside the app (product spec §14).
  static const conflictNotice = 'This note was also changed outside Vera N.';
  static const compareVersions = 'Compare';
  static const keepThisVersion = 'Keep this version';
  static const keepOtherVersion = 'Keep the other version';
  static const keepBothVersions = 'Keep both';
  static const otherVersion = 'The other version';
  static const keptThisVersion = 'Kept this version';
  static const keptOtherVersion = 'Kept the other version';
  static const keptBothVersions = 'Saved the other version as a new note';
  static const changedInTwoPlaces = 'Changed in two places';

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
  // No count: a number would turn connections into a pile to clear.
  static const newConnections = 'New connections';
  static const revisit = 'Revisit';
  static const revisitBody = 'You might want to revisit this.';
  static String relatedToRecent(String title) =>
      'Related to your recent note on $title.';
  static const putOff = 'Back in a month';
  static const nothingToRevisit = 'Nothing to revisit right now.';
  static const viewRecent = 'Recent';
  static const viewFolders = 'Folders';
  static const viewTags = 'Tags';
  static const pinned = 'Pinned';
  static const emptyHome = 'Write your first thought.';
  static const loadError = "Couldn't open your notes.";
  static const today = 'Today';
  static const tomorrow = 'Tomorrow';
  static const weekdaysShort = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
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
  static String tagReason(String tag) =>
      'Notes like this one are tagged ${tagLabel(tag)}.';
  static const tagThisNote = 'This note';
  static String tagHasIt(String tag) => 'Has ${tagLabel(tag)}';
  static String suggestedTag(String tag) => 'Suggested tag: ${tagLabel(tag)}';
  static const accept = 'Accept';
  static const reject = 'Reject';
  static const notSure = 'Not sure';
  static const undo = 'Undo';
  static const why = 'Why?';
  static const linked = 'Linked';
  static const reviewNewLabel = 'NEW';
  static const reviewOlderLabel = 'OLDER';

  // The laptop's results (docs/LAPTOP_PLAN.md, L3).
  static String newTagReason(String tag) =>
      'A new tag that could fit: ${tagLabel(tag)}.';
  static const duplicateReason = 'These two notes look like copies.';
  static String mergeKeeps(String title) =>
      'Merge keeps “$title” and adds the lines only the other has.';
  static const merge = 'Merge';
  static const merged = 'Merged';
  static const notCopies = 'Not copies';
  static const removeOne = 'Remove one';
  static String removeThis(String title) => 'Move “$title” to the trash';
  static const allCaughtUp = 'All caught up.';
  // No number, so it never reads as a pile to clear.
  static const reviewMore = 'Review more';
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

  // Attachments (UI spec §7).
  static const attach = 'Attach';
  static const attachPhoto = 'Photo from gallery';
  static const attachCamera = 'Take a photo';
  static const attachVoice = 'Voice note';
  static const attachDrawing = 'Drawing';
  static const photo = 'Photo';
  static const drawing = 'Drawing';
  static const voiceNote = 'Voice note';
  static const play = 'Play';
  static const pause = 'Pause';
  static const recording = 'Recording';
  static const save = 'Save';
  static const cancel = 'Cancel';
  static const undoStroke = 'Undo last line';
  static const clearDrawing = 'Clear';
  static const editDrawing = 'Tap to keep drawing';
  static const attachmentMissing = "This attachment isn't here yet.";
  static const attachFailed = "Couldn't attach that.";
  static const microphoneNeeded =
      'Voice notes need the microphone. You can allow it in Settings.';
  static String duration(Duration d) =>
      '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
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
  static const unarchive = 'Unarchive';
  static const archived = 'Archived';
  static const unarchived = 'Back in its folder';
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

  /// A folder bubble's name; notes outside any folder share one.
  static String folderName(String folder) => folder.isEmpty ? noFolder : folder;
  static String folderBubble(String folder, int count) =>
      '${folderName(folder)}, ${count == 1 ? '1 note' : '$count notes'}';
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
  static const addQuickNoteBar = 'Add quick note bar';
  static const addNewNoteButton = 'Add New note button';
  static const addQuickSettingsTile = 'Add Quick Settings tile';
  static const addWidgetByHand =
      'Long-press your home screen, choose Widgets, and find Vera N.';
  static const addTileByHand =
      'Open Quick Settings, choose Edit, and drag New note in.';
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
  static const trashHint =
      'Deleted notes stay here for 30 days, then are removed for good.';
  static const emptyTrash = 'Nothing in the trash.';
  static const restore = 'Restore';
  static const restored = 'Restored';
  static const deleteForever = 'Delete forever';
  static const deletedForever = 'Deleted for good';
  static String deletedOn(String date) => 'Deleted $date';
  static const attachmentsAllUsed = 'All used in notes';
  static String attachmentsUnused(int n) =>
      n == 1 ? '1 not used in any note' : '$n not used in any note';
  static const removeUnused = 'Remove unused attachments';
  static String unusedRemoved(int n) =>
      n == 1 ? '1 attachment removed' : '$n attachments removed';
  static const cleanAttachmentsAuto = 'Remove unused attachments on their own';
  static const cleanAttachmentsHint = 'After 30 days in no note';
  static String fileSize(int bytes) {
    const mb = 1024 * 1024;
    if (bytes == 0) return 'None';
    if (bytes < mb) return '${(bytes / 1024).ceil()} KB';
    return '${(bytes / mb).toStringAsFixed(1)} MB';
  }

  // Laptop layout (docs/LAPTOP_PLAN.md, L1).
  static const pickANote = 'Pick a note, or start a new one.';

  // Reminders (decided 2026-10-08).
  static const reminderTitle = 'Reminder';
  static const remindersChannel = 'Reminders';
  static const lockedReminder = 'A note in your Locked folder';
  static const remindersSetting = 'Reminders from notes';
  static const remindersSettingHint =
      'When a note says “remind me” with a date and time';
  static const onTimeReminders = 'On-time reminders';
  static const onTimeAllowed = 'Allowed';
  static const onTimeAllow = 'Allow';
  static const onTimeHint =
      'Without this, a reminder may come a few minutes late';
  static const reminderNeedsTime = 'Add a time, like “at 9 am”';
  static const reminderPast = 'This time has passed';
  static const notificationsOff = 'Notifications are off for this app';
  static const remindersHeading = 'Reminders';
  static String reminderOn(String when) => 'Reminder: $when';

  // Locked folder (decided 2026-10-08).
  static const lockedFolder = 'Locked';
  static const unlockReason = 'Open the Locked folder';
  static const lockedNoteHint = 'This note is in the Locked folder.';
  static const lockedFolderHint = "Notes here open with your phone's lock.";
  static const unlock = 'Unlock';
  static const lockNow = 'Lock now';
  static const moveToLocked = 'Move to Locked folder';
  static const moveOutOfLocked = 'Take out of Locked folder';
  static const movedToLocked = 'Moved to Locked folder';
  static const movedOutOfLocked = 'Taken out of Locked folder';
  static const lockedTrashNote = 'Locked note';
  static const needScreenLock =
      'Set a screen lock on your phone first, then the Locked folder works.';

  static const exportNotes = 'Export notes';
  static const exportValue = 'Markdown .zip';
  static const exporting = 'Making the .zip…';
  static const exportSaved = 'Notes saved.';
  static const exportFailed = "Couldn't save the notes. Try again.";
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
