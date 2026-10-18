# Changelog

All notable changes to Vera N are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- **The README shows the launch video and the Play Store screenshots** (user, 2026-10-18). `docs/media/` holds the 22-second launch video (made with /brag from the real app's captures; GitHub plays it from the poster link, since a README can't embed a repo video) and the five framed screenshots in the studio design the user chose (`goldie/goldie.design.json`, now committed so `goldie frame` rebuilds the same set). About 3.2 MB, in plain git (LFS covers only the model).
- `.gitignore`: `/brag-output*/` (video renders and work files) and `/appstore-assets.zip` (the studio's export); the finished files live in `docs/media/`. `.impeccable/config.json` (the design checker's shared settings) is committed.

### Changed
- **Selecting a note card or a Graph dot: a stronger highlight and a light tick** (user, 2026-10-17; chose both).
  - **Haptic:** a new `HapticEvent.select` in `core/feedback/haptics.dart`, Android's own "selection changed" tick (the lightest). On Home it plays when a hold registers, so a hold that turns into a drag ticks once, not twice, and on each tap that adds or removes a card while selecting. In the Graph, on picking a new dot only. Skipped when touch feedback is off, like every haptic.
  - **Highlight:** one ink wash (`AppOpacity.selectedWash`, 0.08) for both: behind a selected card (with its outline and ✓) and as a halo under the picked dot, which also grows 1.4× (`AppSize.graphPickedScale`) in an ink ring that now keeps its width at any zoom. No dimming of the rest: dimmed means an AI suggestion. Checked on the phone in light mode.
  - Tests: a hold ticks once and each tap after it once; a selected card has the wash; a drag ticks once; a new dot ticks, the same dot again does not (4); `HapticsSpy` in `test/support` records what reaches the platform.
  - CLAUDE.md §7's haptic mapping now lists `select` (user, 2026-10-17).
- **Holding a note on Home selects it; act on several at once** (user, 2026-10-17: hold should offer add to folder, lock and archive, and several notes at once; chose "hold and let go selects, hold and move drags"). Replaces the long-press sheet (Pin, Delete).
  - **Selecting:** a selected card has an ink outline and a ✓; while selecting, a tap adds or removes a card. "✕ · 2 selected" over the header; the actions float above the nav bar in its plate: Folder, Lock, Archive, Pin or Unpin, Delete. Each acts on all, ends selecting and, when it moves notes, offers one Undo for the batch. ✕ or the back gesture stops selecting, before an opened folder closes. Right-click selects on a laptop.
  - **Core:** `NoteBatch` (move, archive, lock, putBack, pin, trash, restore) returns each note's old folder for the one Undo. Archive leaves locked notes locked (it would otherwise move them out of `Locked/`); Lock needs a screen lock, as in a note.
  - **Shared:** the folder sheet moved from the note screen to `FolderPicker` (`shared/widgets/`), used by both. `HomeNoteMenu` is gone.
  - **Found by the tests:** the action bar first stretched over the whole screen in the floating-button slot, invisibly covering the cards; it now has the nav bar's fixed height.
  - New token `AppBorder.selected` (2). UI spec §5 and the laptop note updated.
  - Tests: selecting, tapping, ✕ and back; Delete, Folder, Archive and Lock with one Undo; Lock without a screen lock; Pin and Unpin (8, replacing 3); `NoteBatch` (5).
- **Drag notes onto folders; resting on one opens it** (user, 2026-10-17: "dragging it to folder chip and holding there opens the folder view and the user can drop it inside the folder"). Holding a card and moving lifts it (or every selected note, with a count); a tray of folder chips floats above the nav bar, plus No folder, Locked, Archive and New folder. Resting 0.7 s (`AppMotion.springOpen`) on a folder chip opens that folder under the finger; dropping on its notes, or straight on a chip, moves them, with one Undo.
  - **One gesture, two meanings:** `LongPressDraggable` starts on the hold; if the finger lets go without moving it counts as a hold and selects. The tray shows only once the finger moves, so a hold never flashes it. Its own haptic is off (haptics go through `core/feedback` only), and a screen reader's long press still selects.
  - **The drag outlives its card:** opening a folder under the finger takes the card off the screen, so the card's drag callbacks use nothing it owns after the drag starts.
  - **Found on the phone:** after a drop into a folder opened under the finger, the tray stayed up. The removed card never reports the drag's end, so the drop layer now ends it itself when the finger lifts (a global pointer route, which runs after the drop is taken). The test that covers it failed before the fix.
  - **Found on the phone:** the cards had lost their screen-reader long press (the hold now belongs to the drag); `NoteCard.onSemanticLongPress` puts it back on the card's own node. Test: a screen reader's long press selects.
  - **Checked on the phone (2026-10-17, test app):** hold selects; hold and move lifts the card and shows the tray; resting on Study and on Projects opened each and the drop moved the note in, with Undo.
  - **Layer rule kept:** `FolderPicker` (shared) takes the folder-name cleaner as a callback instead of importing `core/utils`, which the architecture test caught.
  - Tests: a hold never shows the tray; dropping on a chip; resting opens the folder and dropping inside moves; a selected batch moves together; dropping on Locked locks (5).
- **Home's Folders view shows folder cards instead of pills** (user, 2026-10-17; chose a flat list with a note count). Every folder, subfolders included, is a card (`FolderCard`, shared) in the Grid or List layout: icon, name, "in Ideas" for a subfolder, and "3 notes". Tapping one opens it: a back arrow ("All folders") and the folder's name, then its notes; the back arrow or the phone's back gesture returns to the cards. Locked is a card with no count. Tags keep their pills.
  - **The count is what opening the folder lists:** subfolders included, letter case ignored, archived notes only inside the archive, the trash left out (`SearchRepository.watchFolderSummaries`, one grouped query). A test checks every card's count against the list it opens.
  - `GroupView` is split into `FolderView` (with `FolderCards`, `FolderHeader`) and `TagView`; copy in the new `HomeCopy`, exported by `app_copy.dart` (which is near its 400-line limit); new token `AppSize.folderCardHeight` (104). UI spec §5 updated.
  - Tests: cards, counts and opening a folder; the back gesture; counts against what opening lists (3).
- **Review's first-time gesture tip is the card itself, moving** (user, 2026-10-17: "the gesture control onboarding needs an animated onboarding"; chose nudging the real card over a demo card). Instead of an overlay covering the card, the first card leans right (the ✓ shows), settles, leans left (the ✕), settles, once, about 2.3 s, with a finger icon on it. It is the same offset, tilt and marks as a real drag (`SwipeCard.nudge`), so only transform and opacity change. The four gestures are named in a quiet strip under the card with Got it; the first decision also puts it away. Touching the card stops the nudge; with reduce motion the card doesn't move.
  - New motion tokens: `AppMotion.nudgeLean` (0.22 of the card's width), `nudgeStep` (450 ms), `nudgeHold` (250 ms), `nudgeSettleCurve`. UI spec §5–6 updated.
  - Tests: the card moves right then left and comes back; with reduce motion it stays still; the first decision dismisses the labels (3, replacing 1).
- **Onboarding pages open with a line illustration** (user, 2026-10-17: "main onboarding needs images"; chose drawings in code over app screenshots or supplied artwork). One per page, in ink on the note plate: a note with a padlock, two notes joined by a dashed seal line (a suggestion), a phone (or laptop) with linked notes, a note with a bell, a folder with notes, a greeting being written. Drawn by `OnboardingArtPainter` in theme colours, so they follow light and dark, are sharp at any size and add no image files. Screen readers skip them; they take at most 22% of a short screen's height and step aside while the keyboard is up.
  - **Found by the test:** the Scaffold takes the keyboard out of the MediaQuery its body sees (it shrinks the body instead), so the page reads the keyboard from the view, inside a LayoutBuilder that rebuilds as the body shrinks.
  - New tokens `AppSize.onboardingArtHeight` (160) and `artStroke` (2). Checked in light and dark by rendering all seven. UI spec §4 updated.
  - Tests: each page shows its own illustration; the name page drops it while typing (2).

### Fixed
- **Linked notes were suggested with each other because of their "Linked notes" footers** (user, 2026-10-17: after linking notes from suggestions, new suggestions appeared that matched only on "Linked"). The analysis read the whole note, including the footer the app adds when a suggestion is accepted. Its heading and the linked titles became one passage, near-identical in every note linked to the same notes, so those notes matched each other.
  - **Now the AI reads only the user's words above the footer** (`NoteFooter.strip`), in the chunker and in the laptop helper's prompts, copy check and passages. Links written inside the text are the user's words and are still read.
  - **Waiting suggestions that matched on a footer are removed** when their note is analysed again (`SuggestionsRepository.dropFooterMatches`, just before the note's passages are replaced). Accepted links, rejections and laptop suggestions are not touched; real suggestions keep their "Not sure" state and expiry date.
  - **Every note is analysed once more**: `NoteChunker.version` is 3. As with the last bump, notes have no suggestions until re-analysed, only while charging, in batches of 200.
  - Tests: the footer left out of passages, two unrelated notes linked to the same notes not suggested together (both fail without the fix), and the clean-up removes only footer matches (2).

### Added
- **Google Play store assets with goldie** (user, 2026-10-17: Google Play only, since iPhone captures need a Mac). Five framed 1080×1920 screenshots and a portrait preview video, rendered from the real test app on a Pixel 9 Pro emulator. They live in `goldie/out/` (git-ignored); `goldie/goldie.config.ts` holds the scenes, copy and theme (DESIGN.md colours, Inter).
  - **Real suggestions, made-up notes:** every flow starts with `.argent/flows/store-setup.yaml`. It clears the test app (`com.example.vera_n.perf`), seeds 13 fictional notes (`goldie/seed/notes`, English, Hindi and mixed, with folders, tags, checklists and links, dated over six weeks), goes through onboarding, then runs the on-device analysis on demand (`goldie/seed/run-analysis.mjs` forces the queued WorkManager job). So the suggestions, the tag suggestion and the Hindi-to-English "Similar in meaning" result on screen are the model's own. No real notes are involved.
  - **Scenes:** Home with New connections, a Review card (the two DBMS notes), a Hindi search ("पौधे को पानी कब दें") finding the English soil-sensor note, the mixed Hindi/English grocery note with a suggested tag, and writing a new note. Preview, in two segments: accept a connection, then the Hindi search and open the note.
  - **Checked:** `goldie verify` passes: five 1080×1920 PNGs, and the preview at 1080×2400, H.264 30 fps, AAC, 4.1 MB, **42.9 s**. Each clip opens with 5–8 s of still screen while recording starts, so four segments ran 64 s; two run 43 s. Play has no length limit (the video goes on YouTube). The status-bar clock isn't held during recording: it shows 9:41, then the emulator's real time.
  - **Seen in the app while making them (not changed here):** Search shows "No notes found." for a moment before "Similar in meaning" results arrive, with no loading state. After the DBMS pair, Review offers "ESP32 deep sleep notes" ↔ "Morning routine", which share only the word "wake": a weak match above the 0.60 bar. Each Review passage quotes the note's own title first (“DBMS exam revision).
  - **No invented ratings:** the studio's store page shows "No ratings yet".
  - **Tools, not app dependencies:** goldie (global npm), argent flows in `.argent/flows/`, and `.argent/flags.json` turns off argent's video watermark for this project. No app size or battery change.
  - **Found on Windows:** argent finds ffmpeg by running `/bin/sh -c "command -v ffmpeg"`, which fails on Windows, then falls back to macOS/Linux paths. Its screen recording works here only with a copy of `ffmpeg.exe` (and an empty `ffmpeg` placeholder) in `D:\usr\local\bin`. Gboard on the emulator showed a stylus toolbar until `settings put secure stylus_handwriting_enabled 0`.

### Changed
- **The V mark is now the app icon** (user, 2026-10-17: "make it the logo"; chose the light icon as previewed over the spec's dark square with an amber dot). It replaces Flutter's default icon.
  - **Android 8+:** an adaptive icon (`mipmap-anydpi-v26/ic_launcher.xml`) with a stock background, the icon cut as a vector foreground (written by the generator), and a monochrome layer for themed icons. Its colours (`ic_launcher_background`, `ic_launcher_mark`) have no night twin, so the icon is the same in both themes.
  - **Android 7:** the mipmap PNGs (48–192 px), a rounded tile with a hairline.
  - **Windows:** `app_icon.ico` (16–256 px), used by the window, the taskbar and the installer.
  - **The Android 12+ launch screen stays plain** (`windowSplashScreenAnimatedIcon` transparent). Android 12 and later would otherwise draw the launcher icon there, which the Flutter logo already did. The ink V would also be nearly invisible on the dark launch screen, and `launch_background.xml` already says "no logo, so capture feels instant".
  - **New script:** `tool/brand/render_icons.ps1` draws the PNGs and the `.ico` with Edge and Windows' own image code. No new dependency.
  - **Size, measured:** the five Android PNGs grow from 4.2 KB to 24.2 KB in all (Flutter's were flat shapes that compress well), plus a 1 KB vector foreground: about 21 KB on a 70 MB APK. The Windows `.ico` shrinks from 33.8 KB to 21.4 KB. No battery change.
  - **Checked:** the debug APK packs the adaptive icon with all three layers (`aapt2 dump`). The Windows release `.exe` carries the new icon. Every PNG was looked at on light and dark backgrounds. **Not yet checked on the phone**, which wasn't connected.
  - Spec §21–22 and DESIGN.md (new Mark section, the Ink Mark Rule) record the decision.
- **README lists every feature** (user, 2026-10-17): capture, writing, organizing, finding, smart suggestions, data, laptop, sync and accessibility, plus status, building and licenses. Taken from what this changelog records as built; no behavior change.

### Added
- **A mark for Vera N, drawn from rules (not in the app yet)** (user, 2026-10-17, from an AI-made brand board: a V of two strokes meeting in a drop of ink). The launcher icon is still Flutter's default.
  - **The rules:** the outer contour is an inverted equilateral triangle (strokes at 60°), terminals are cut flat on its top edge, the left stroke is heavier (4 : 3), each stroke keeps its weight and then narrows to a neck, and the drop's diameter is the light stroke's width.
  - **Two cuts:** a primary one for about 96 px and up, and a heavier icon cut (neck 4.5 against 1.4) whose neck still shows at 24 px.
  - **Adaptive icon:** the icon cut is 48 dp wide on the 108 dp canvas, on stock `#F5F4F6`, and reaches 30.7 dp from the centre (the safe circle is 33 dp). There is also a monochrome layer for themed icons.
  - **Files:** `tool/brand/make_brand_marks.dart` (plain Dart, no new package) writes `docs/brand/` (`mark-primary.svg`, `mark-icon.svg`, `icon-foreground.svg`, `icon-monochrome.svg`, `preview.html`). The preview shows the construction, both cuts from 96 to 16 px, the lockup in the real Instrument Serif, and the icon in circle, squircle and rounded-square masks on light, dark and photo wallpapers, plus themed tints. It was checked in Edge in light and dark mode.
  - Not checked on the phone yet. Nothing in `android/` changed, and no app size or battery change.
- **Built-in sync, part 2: the mirror, the service and the screens (built; checked on the devices, see Checked)** (docs/LAPTOP_PLAN.md, S).
  - **Settings, SYNC:** "Sync with your phone" (laptop) / "Sync with your laptop" (phone): "Not paired", "In sync with …", "Last synced: …", and Unpair. Hidden in builds without the engine.
  - **Laptop pairing window:** the QR code (black on white in both themes, for scanners) and the six words, open 5 minutes; "Waiting for your phone…", then "Paired".
  - **Phone:** "Scan the code" (camera, decoded on the phone by zxing-cpp) or "Type the six words"; clear messages when the laptop isn't found or the words don't match.
  - **The service** (`SyncService`): runs the engine only while paired (or pairing). On the phone it stops a minute after leaving the app; on the laptop it runs while Vera N runs and quits with it.
  - **Phone mirror** (`MirrorBridge`): the engine shares a private copy; every 20 s while open (and on leaving) changes are copied both ways between it and the user's folder. A note changed on both sides keeps the folder's version and saves the other as a conflict copy for Compare / Keep. What arrives is indexed at once and laptop results are offered.
  - **Words:** onboarding (laptop) and the phone's Laptop row now say "pair them in Settings" instead of naming Syncthing.
  - **Permissions (Android):** network (INTERNET), needed for any connection, even on one's own Wi-Fi; the engine's internet relays and discovery are off. Camera, asked only when scanning. Windows asks once to allow Vera N through the firewall.
  - **New packages:** `qr_flutter` 4.1.0 (draws the code; pure Dart), `flutter_zxing` 3.1.0 (scans; zxing-cpp, no Google services; 2.0 MB packed per CPU on Android, 5.9 MB on Windows). `archive` raised to 4.5.2 (the new `image` needs it).
  - **Size:** the engine adds about 12 MB packed per CPU type to the APK (27.5 MB installed on arm64) and 27.4 MB to Windows.
  - Tests: the mirror (6), two real engines paired and syncing both ways (1).
- **Built-in sync, part 1: the engine and pairing core (in progress; not yet in the app's screens)** (docs/LAPTOP_PLAN.md, S; user, 2026-10-16: "for him it should be just the vera n app settings not another app"; chose Syncthing inside Vera N, QR code and word code, and a mirror copy on the phone).
  - **The engine** (`core/sync/sync_engine.dart`): Vera N starts Syncthing (MPL-2.0) itself, in its own folder, with a random API key and its page on 127.0.0.1 only. Internet relays, global discovery, NAT port opening, usage and crash reports and upgrades are off; only local discovery stays on. It picks free ports, so another Syncthing on the same computer is left alone. `SyncthingApi` drives it through that local API.
  - **Shipping it:** `tool/fetch_sync_engine.ps1` downloads the official Windows build and the Android build from Syncthing-Fork 2.1.6.0 and checks pinned SHA-256 hashes; the binaries stay out of git. Windows installs `syncthing.exe` next to the app; Android packs `libsyncthingnative.so` as a native library, unpacked at install so it can run (`useLegacyPackaging`).
  - **Pairing** (`pairing_code.dart`, `pairing_exchange.dart`): six words from the BIP-39 English list (66 bits; any case, four-letter starts accepted) and a QR invite carrying the laptop's id, its home-network addresses and a port. The phone finds the laptop with a home-network broadcast that only a device with the words can answer; both prove they have the words (HMAC-SHA256, bound to their ids) before either adds the other. Five wrong tries close the 5-minute window.
  - **Word list:** `assets/pairing/words_en.txt`, the BIP-39 English list (2,048 words, SHA-256 2f5eed53…, from the bitcoin/bips repository, BSD-2-Clause).
  - Tests: the real engine on Windows (1, skipped where it isn't fetched), the code and invite (4), pairing over loopback (4).

### Fixed
- **The phone couldn't read the pairing QR code (user, 2026-10-16: "qr isnt working").** The camera opened, but nothing was ever read. The code held about 150 characters (the laptop's 63-character id, the six full words, two addresses), so it was a dense 45×45 grid in a 240-point box, and the scanner looked only at the middle half of the picture, once a second.
  - **Shorter code:** no laptop id (the laptop's proof already shows it has the words) and each word as its first four letters: about 75 characters, a 33×33 grid. The QR text is now `veran-pair:2:…`; the old form is refused.
  - **Scanner:** most of the camera picture, zxing's "try harder", about three times a second (only while the scan page is open), and it closes once even if the code is read twice.
  - **The right address first:** the phone tries the laptop's address on its own Wi-Fi before others (a virtual machine's adapter cost a 5-second wait).
  - Test: 1 (the code stays short). Not yet re-checked with the phone's camera.
- **Built-in sync, found on the devices (2026-10-16):**
  - **"Couldn't find your laptop" on the phone.** The phone's search went only to 255.255.255.255, which many Android builds drop. It now also goes to each home network's own broadcast address (x.y.z.255).
  - **The engine could start twice** (pairing and the app resuming at the same moment), and the second copy failed on the first one's lock. Starts are now shared, an old process ending no longer clears the new one's state, and the engine stays up while a pairing window is open, even before a device is paired.
  - **The laptop closing the connection** during pairing made the phone stop instead of trying its next address.
  - **The QR code broke the pairing window's layout** ("LayoutBuilder does not support intrinsic dimensions"). It now sits in a fixed 240-point box in a scrolling dialog. Test: 2.
  - **A closed engine connection** could still be called; it now fails at once with a clear error. Test: 1 (two starts share one engine).
- **The laptop helper got empty answers from thinking models (found 2026-10-15 with Qwen 3.5 9B in LM Studio).** The model spent the whole 200-token reply budget on hidden reasoning (`finish_reason: length`, all tokens reasoning) and answered nothing after about 20 s. Requests now ask for no reasoning (`reasoning_effort: "none"`): answers in about 1 s. A server that rejects the field gets the request again without it, and never sees it again. (`/no_think` and the chat-template switch were tried and had no effect in LM Studio.) Test: 1.
- **New tag names copied the prompt's example.** The tag and topic prompts gave "trek-planning" as an example, and the model put it, and unrelated existing tags, on unrelated notes (a soil-sensor note got "trek-planning, dbms"; a mutual-funds note "trek, fitness"). The prompts now have no example name and use an existing tag only when the note is clearly about it.

### Checked
- **Built-in sync between the phone and the laptop (2026-10-16, test folders only, test app `com.example.vera_n.perf`).** Both on the same home Wi-Fi, no other sync app running. Paired by typing the six words on the phone: "Paired with SparshLaptop". A note written on the laptop reached the phone's private copy in 5 s and its notes folder and Home 18 s later; a note written in the phone app reached the laptop folder and its Home in about 30 s. Both Settings rows then read "In sync with …". Not yet checked: scanning the QR code with the phone's camera, and laptop AI results reaching the phone this way.
- **Syncthing between the phone and the laptop (2026-10-16, test folders only).** Syncthing 2.1.6 on Windows (official release, checksum verified) and Syncthing-Fork 2.1.6.0 on the phone, paired and sharing one folder: the phone's `Documents/VeraPerfTest` and the laptop's `VeraSyncTest`. The phone was on mobile data, so the two were connected over the USB cable (`adb reverse`), not the internet. All 15 test notes reached the laptop, and a note written on the laptop reached the phone within seconds. Not yet checked: the laptop app's AI results reaching the phone through the folder (the AI app was closed).
- **The four laptop jobs with a real model (2026-10-15, Qwen 3.5 9B, LM Studio, the matching set's test notes):**
  - "Why?": 5 of 5 sentences right, 1.0–1.6 s each (for example "Both notes discuss using a capacitive sensor for a long-lasting soil moisture monitoring project.").
  - Copies: the near copy found, with a sentence; two notes only on the same topic correctly not copies. 0.5–1.9 s.
  - Topics: "kedarkantha-trek", "gym-routine-diet".
  - New tags, after the prompt fix: 5 of 5 fit ("soil-moisture, esp32-sensors", "mutual-funds, index-funds", "winter-trek, fitness").
  - **Memory:** LM Studio loaded the model with a very large context and reserved 18.9 GB, leaving the 16 GB laptop almost no memory (other programs crashed). Reloaded with a 4,096-token context it reserved 7.0 GB. Vera N's prompts need at most about 1,500 tokens.

### Changed
- **The phone's separate "Laptop" row is gone (user, 2026-10-16).** It came from before built-in sync, repeated the "Sync with your laptop" row, and could read "Not set up" while the two were in sync. Once paired and the laptop's AI has added suggestions, the sync row's grey text now starts with "Your laptop last helped: Today". The laptop's own Settings are unchanged. Tests: 3 (replacing 2).
- **One very close note is enough to suggest its tag (user, 2026-10-15).** The phone suggested a tag only when at least 2 close notes shared it, which was rare: most people tag few notes, and the user saw no tag suggestions. Now a tag on a single note at similarity 0.70 or more (well above the 0.60 link bar) is suggested too. Still only existing tags, still dimmed until approved. Tests: 2.
- **Merge keeps the larger note: confirmed** by the user (2026-10-15); no change.

### Removed
- **Three permissions added by libraries, unused by Vera N** (minimum permissions, CLAUDE.md §9): `ACCESS_NETWORK_STATE` (analysis never waits for a network), `FOREGROUND_SERVICE` and `FOREGROUND_SERVICE_SHORT_SERVICE` (nothing starts a foreground service). Removed with `tools:node="remove"`, as `WAKE_LOCK` was. The release app now asks for: record audio (voice notes), notifications and exact alarms (reminders), boot completed (keeps reminders and scheduled analysis after a restart), biometrics (locked folder) and vibrate (haptics). It still has no internet permission.
  - **Checked on the phone (2026-10-15, test app only):** with these removed, leaving the app while charging requested analysis, and the run finished about 30 s later.

### Changed
- **Release APKs are built per CPU type** (`flutter build apk --release --split-per-abi`): arm64 70.2 MB, armeabi-v7a 62.8 MB, x86_64 75.3 MB, against 104.6 MB for one APK holding all three (measured 2026-10-15). Install the arm64 one on a modern phone.

### Checked
- **Cold start meets the one-second capture target (2026-10-15, phone, test app):** from a stopped app to the typing cursor of a new note, 735 and 683 ms; 1,249 ms on the first start after installing. Android's own measure (`am start -W`): 827, 777 and 1,454 ms.
- **Long notes on the phone (2026-10-15, test app, the 15 notes of the matching set in a test folder):** after one background run, the long notes (DBMS notes, trek plan, journal) had suggestions, all five in the first Review batch were right (matched on the paragraph or title that fits), "similar in meaning" search found the related DBMS note, and Settings read "Last looked: Today". No tag was suggested: the rule needs two close notes sharing a tag, and only one did (open question for the user).

### Fixed
- **Search showed a note without the line that matched** (backlog, found 2026-10-09). The card shows three lines of the snippet, and a match further down ("दाल" in a grocery list under its title) was cut off. The snippet now starts at the first line with a match. Test: 1.

### Added
- **When suggestions are looked for, in Settings (2026-10-15).** Under SMART SUGGESTIONS: "Looks for connections while charging" and "Last looked: Today" (or "Not yet"). A user saw no connections and couldn't tell whether the phone was waiting for the charger or had found nothing. Each analysis run records its end time in the private settings table. Tests: 2.

### Fixed
- **Long notes got almost no suggestions (user, 2026-10-15).** Chunks were packed up to 126 tokens across paragraphs, so a long note's chunks mixed several subjects and their meaning blurred below the match bar. A new chunk now starts at each new line: on a phone a thought often ends with one Enter, not a blank line (measured: with blank-line paragraphs only, notes typed that way still found 4 of 13). The items of a list (bullets, checkboxes, numbers) stay together, since a list is one subject. Text under 4 words (a date, "Tuesday") stays with the next line, and a longer title stands alone, which helps: it says what the note is about.
  - **Measured with the real model on Windows** (`integration_test/long_note_matching_test.dart`, a hand-written set of 13 related and 78 unrelated pairs, long notes in English and Hindi; indicative only):
    - before: 4 of 13 related pairs found;
    - after: 10 of 13;
    - unrelated pairs over the bar: 0 of 78 both times, but the closest unrelated pair is at 0.58, close to the 0.60 bar.
    - the same notes typed with one Enter between thoughts: also 10 of 13;
    - packing smaller (64 / 48 / 32 tokens) found 6 / 7 / 9, and 32 let one unrelated pair over the bar;
    - whole-note averages found less (5 of 13), so they are not used.
  - **Cost:** about 2.4 times as many chunks for long notes (25 → 59 on this set), but each is shorter. On this phone a chunk costs about 13 ms plus about 0.35 ms per token (embedding benchmark, 2026-10-04: 15 tokens 13 ms, 52 tokens 26 ms, 128 tokens 57 ms), so a long note takes roughly a quarter more time, not 2.4 times. Only while charging; short notes are unchanged. (Estimated from the benchmark, not timed in the app: the phone's own Vera N is outside the main profile, and a test install under the real app id could reach it.)
  - **Every note is analysed once more** after the update: `NoteChunker.version` is now part of the analysis model id. Until a note is re-analysed it has no suggestions and isn't found by "similar in meaning" search. Batches of 200 notes, only while charging.
  - The phone's tag suggestions use the same matching (a tag already on at least 2 close notes), so they benefit too.
  - **Still to measure:** time per long note on the phone.
  - **New dev dependency:** `integration_test` (Flutter SDK, tests only; no app size or battery impact).

### Added
- **Laptop, phase L5 (start): the window opens where it was closed** (docs/LAPTOP_PLAN.md). The Windows runner saves the size, position and maximized state on close and restores them on start (`window_placement.cpp`).
  - Kept in `HKCU\Software\Vera N\Window`: it is per-computer state, so it stays out of the synced notes folder.
  - A spot no monitor shows any more falls back to the default.
  - No new dependency: about 50 lines of Win32 instead of a window package.
  - Checked on Windows: moved and resized, maximized, and off-screen.
- **Laptop, phase L5: Windows setup .exe** (user chose Inno Setup, 2026-10-11). Run `tool/build_windows_installer.ps1` to get `build/installer/VeraN-Setup-<version>.exe` (42.6 MB). The version comes from `pubspec.yaml`.
  - It installs for the current user, with no admin prompt. It adds a Start menu entry, and a desktop icon only if ticked.
  - Uninstalling never touches the notes or the database.
  - Unsigned for now, so SmartScreen warns on first run.
  - **New build tool:** Inno Setup 6, installed with winget on the build machine only. It isn't an app dependency, so app size and battery are unchanged.
  - The exe's file description now reads "Vera N", as shown in Task Manager and SmartScreen. Company and product names are unchanged, because they decide where the app keeps its data.
- **Measured: Windows release size.** 92.4 MB unpacked, 47.9 MB zipped. Of that, the model is 42.8 MB, `flutter_windows.dll` 20.3 MB, `onnxruntime.dll` 11.8 MB, and app code 8.6 MB.

### Fixed
- **Screen readers heard the note's Markdown** (UI spec §7). TalkBack read a link card as `[Octopus - Wikipedia](https://…)` and links, bold and checkboxes with their symbols. Each piece of the editor's text now carries what should be heard (`MarkupSemantics`). The spoken text keeps the same length as the text, so the cursor position read out still matches. Checked on the phone: the field now reads "Link: Octopus - Wikipedia, en.wikipedia.org", then "☐ Milk and eggs". Tests: spoken text (8).
- **A bare link on its own line crashed the note's markup scan.** `NoteMarkup.find` asked a one-group match for group 2, which throws. Any note with a pasted address on its own line would fail to open in the editor. Found by the new screen-reader tests; added a regression test (1).

### Changed
- **Empty notes are deleted on leaving** (UI spec §7; user request 2026-10-11). Clearing a note and leaving it (or typing in a new note, then deleting it all) used to leave an empty note behind. Now `NotesRepository.deleteIfEmpty` removes the file and the row for good when the editor closes.
  - **Why for good, not Trash:** there is nothing to restore, and the trash would fill with untitled entries.
  - **Why only on leaving, not a sweep:** an empty `.md` may be a file Syncthing is still copying, or one made in another app; those are never touched. The saved text is checked again before deleting.
  - Tests: cleared new and old notes go, an unchanged note stays, attachment- or link-only notes stay, text from sync wins, trashed notes are left alone (6).

### Added
- **Share to Vera N, and link cards** (UI spec §5 and §7, product spec §3; decided by the user 2026-10-10: offline cards only, option A of three).
  - **Why offline:** fetching a page's title would need the internet permission (the release app has none, which anyone can check), and would tell the website which link was saved and when. Options B (the laptop fetches) and C (a per-link "Get preview" tap) were set aside.
  - **Share in:** Vera N is in Android's Share menu for text and links (`ShareActivity`, no screen of its own). It forwards to the running app like the widgets do, so the database is only ever opened once. The new note holds the link card, with the cursor on the line below, and saves at once.
  - **The card:** a link on its own line, `[Title](https://… "Description")` or a bare address, is drawn as a card with the title, the description, and the site. Tapping it opens the browser through an Android intent (`openLink` on the launch channel; on a laptop, the system browser). Title and description come only from what the sharing app sent; with neither, words from the address or the site name.
  - **Editing:** the card is one piece, like an attachment (`MarkupSpan.isBlock`). Copies keep the address on the line under the title.
  - No new dependency.
  - Tests: link format, offline labels, and display (11); shared text to note (8); editing around a card (4).
- **Laptop, phase L4: Settings for the laptop helper** (docs/LAPTOP_PLAN.md).
  - **Laptop, AI ON THIS COMPUTER:**
    - "Help from a local AI app" (on by default, described as optional);
    - a status line with Check: ready, "Not set up" (a normal state), or why the address is refused;
    - the address, and "Also allow my own network";
    - the model (Automatic, or one the AI app offers; embedding models left out);
    - one switch per job, and "Last helped".
    - Off hides the rest, and then not even the local check runs.
  - **Phone, SMART SUGGESTIONS:** a "Laptop" row: "Last helped: Today", or "Not set up". Tapping it explains Syncthing in two lines.
  - The helper reads these settings before every run (`BoosterPrefs`, one JSON value in the private settings table). The check is a local request only.
  - The laptop copy lives in `LaptopCopy`, exported by `app_copy.dart`.
  - Tests: settings on both devices (3); the helper with prefs: off, jobs, model, the check, prefs round trip (5).

### Added
- **Laptop, phase L3: the laptop's results in the app (phone and laptop)** (docs/LAPTOP_PLAN.md).
  - **Import** (`LaptopResultsImport`): on start, on resume, when the folder changes, and on the laptop after each booster run. Only results whose notes are unchanged are used; with no laptop results nothing happens.
    - The written "Why?" goes on the waiting link between the same two notes, under the reason on the card.
    - New tag names and topics become tag suggestions (a new name shows one note: "A new tag that could fit: #name.").
    - Copies become a new suggestion kind, `duplicate`.
    - Each result is offered once: one that expired or was rejected never comes back.
  - **Copies in Review:** "These two notes look like copies." with the laptop's sentence and which note Merge keeps.
    - ✓ is **Merge**: the note with more text gains the other's missing lines (lines in both appear once, nothing rewritten, new lines above "Linked notes", the two footers joined), and the other goes to the trash.
    - ✕ is **Not copies**, remembered in the rejections file as (id, `=other id`), so it never blocks a link.
    - **Remove one** asks which note goes to the trash.
    - Each has Undo.
  - **Schema 7:** `suggestions.detail`, `suggestions.fromLaptop`, and an `imported_results` table. Upgrades from every earlier version are tested (versions 1–5 get the columns when the table is built or rebuilt, version 6 by adding them).
  - **Laptop suggestions don't move this device's learned match bars**: they never passed them. This differs from the plan's "learned from per kind"; recorded there.
  - **Chosen without asking, to confirm:** Merge keeps the note with more text (the older one if equal).
  - Tests: import (5), merge text and duplicate actions (7), Review with laptop results (4), migration 6 → 7.

### Added
- **Laptop, phase L2: the booster engine (code; tested with a fake server, not yet with a real model)** (`core/booster/`, docs/LAPTOP_PLAN.md).
  - **A local AI server only.** `AiServerAddress` accepts an address only if it resolves to this computer (or, when allowed later in Settings, to the user's own network: private ranges and Tailscale), and refuses cloud addresses. `AiServerClient` speaks the OpenAI-compatible API with `dart:io` (no new package). It connects to the checked IP, uses no proxy and follows no redirects, so note text can't be carried elsewhere. It prefers IPv4 because LM Studio listens on 127.0.0.1 only, and drops a model's `<think>` reasoning from replies.
  - **The four jobs** (`BoosterRun`), in order, at most 12 questions per idle spell, stopping at the next key press or click:
    1. a one-sentence "Why?" for each waiting link, from the two matched passages only;
    2. duplicates: pairs whose whole-note meanings are 0.93 or closer and of similar length, confirmed by the model;
    3. topics: groups of 3–8 notes at 0.70 or closer, named by the model as a tag (decided 2026-10-09: topics become tag suggestions);
    4. up to two tag names for notes of 12 words or more, folded into an existing tag when it is the same name written differently, and leaving out tags the note already has.
  - **Results file** (`BoosterRepository`): one line per job in `.app/laptop-<deviceid>.jsonl`, holding note ids and text hashes plus the short AI-written text, never note text. "Nothing found" is recorded too, so nothing is asked twice; a changed note gets new jobs. The file is compacted each run (stale and superseded lines dropped). Notes are matched across devices by header id, or by path for a note without one, so the booster never writes ids into note files.
  - **When it runs:** on the laptop, after the on-device analysis, in the same idle-and-on-mains-power window (`DesktopAnalysis.boost`). With no AI server running it does nothing and stays silent (one refused local connection per idle spell). The phone is unchanged; showing the results is L3.
  - **Model:** the first chat model the server lists (embedding models skipped) until Settings (L4) lets the user choose.
  - Tests: 31 (address rules, client against a fake server including redirect and no server, reply parsing including Hindi, grouping maths, the results file, and the four jobs end to end).

### Changed
- **Every kind of user (user, 2026-10-09):** the app must work for phone-only and laptop-only users, and on laptops with no local AI or too weak to run one. Recorded in docs/LAPTOP_PLAN.md, with the rules for L3 and L4. The laptop onboarding no longer assumes a phone: "The thinking happens on this computer.", and Syncthing is mentioned only "if you also use Vera N on your phone".
- **Onboarding copy moved to `OnboardingCopy`** (`core/copy/onboarding_copy.dart`, exported by `app_copy.dart`, so there is still one import point): `app_copy.dart` had grown to 412 lines, past the 400-line limit (CLAUDE.md §3). Wording unchanged.

### Added
- **First run on Windows (2026-10-09): L0 and L1 checked in the real window** (Windows 11, Visual Studio Community 2026, debug build, a throwaway test folder; no real notes).
  - **Checked:** onboarding (5 pages on a laptop), picking the folder with the system dialog, Home in two panes, opening a note beside the list, Ctrl+N and Ctrl+F, Graph, Settings, keyword search in Hindi, and the folder watcher (a file written by another program appeared in the list within about a second). Devanagari renders cleanly in cards and the editor.
  - **Window:** titled "Vera N" (was "vera_n"), and no smaller than 400×600 (scaled for the screen), so the phone layout below the wide breakpoint always fits (`windows/runner`).
  - **Onboarding on a laptop** speaks of "this computer" and "your devices", not "your phone", and has no reminders page (reminders are phone-only). New copy in `AppCopy` (`…Desktop`); the phone's pages are unchanged. On a wide window the pages sit in a readable column (680 px) instead of running across the screen.
  - **Build fix, `local_auth_windows` under Visual Studio 2026:** the plugin (2.0.2) uses the old `/await` coroutine switch, which VS 2026 rejects, and a plain `return` inside a coroutine. A patched copy lives in `third_party/local_auth_windows` (two lines changed, recorded in its `VERA_N_PATCH.md`) and is used through `dependency_overrides`; `third_party/` is excluded from analysis. Drop it when the plugin publishes a fix. No size or battery change.
  - Test: Ctrl+N still starts a new note while typing in an open note (6 wide-window tests).

### Fixed
- **Wide window:** the sidebar wordmark and "Pick a note…" were drawn with Flutter's yellow debug underline and the empty right pane was black, because the sidebar and panes had no Material surface behind them. The wide shell now has one, in the app background colour.
- **Wide window:** "Vera N" showed twice (sidebar and Home); Home now shows only the greeting there. Phones are unchanged.
- **Wide window:** Settings rows ran across the full width (label and value about 1,200 px apart); they now sit in the readable column, and the whole pane still scrolls.

### Added
- **Laptop, phase L1: desktop layout (code; tested in a wide window, not yet run on Windows)** (docs/LAPTOP_PLAN.md).
  - **A sidebar from 900 px wide** (`SideNav`, shared): the wordmark, New note, and the four places with their names, the current one on the ink plate. It replaces the floating pill bar and the floating New note button. Narrower windows and phones are unchanged.
  - **Home in two panes** (`app/home_tab.dart`, so features still don't import each other): the notes list on the left (400 px) and the open note on the right. Clicking a card opens it there, and Back, Delete or Archive close it there. With nothing open: "Pick a note, or start a new one." The open note is shared state in `core/navigation/open_note.dart`.
  - **Keyboard:**
    - anywhere in the app: Ctrl+N new note, Ctrl+F Search;
    - in a note: Ctrl+B bold, Ctrl+K link to a note;
    - in Review: Ctrl+Enter accept, Delete reject, Ctrl+U not sure, Ctrl+Z undo.
    These sit beside the same buttons, never instead of them.
  - **Mouse:** right-click on a note card opens the same menu as a long press. Hover states come from the existing ink wells.
  - **Tidy-up:** the note screen's attachment wiring moved to `NoteAttachments`, so the screen stays under 400 lines (now 373).
  - **New tokens:** `AppSize.wideLayout` (900), `sidebarWidth` (240), `listPaneWidth` (400), and the `AppBreakpoints.wide` helper.
  - **Still to do on Windows:** a minimum window size and remembering the window's size and place (needs the Windows build).
  - Tests: 5 widget tests in a 1400×900 window (sidebar, two panes, Ctrl+N / Ctrl+F, right-click, Review by keyboard); the phone layout is unchanged.

### Added
- **Laptop, phase L0 (code; not yet run on Windows)** (docs/LAPTOP_PLAN.md).
  - **Syncthing conflict copies** (`x.sync-conflict-<date>-<device>.md`) are no longer indexed as notes.
    - A copy marks its note as in conflict, and the existing Compare / Keep this / Keep the other / Keep both use the copy as the other version, then delete it.
    - The note stays in conflict while another copy remains.
    - A copy whose note is gone is kept as a note, so no text is lost.
    - Nothing new is stored: the copy on disk is the record. This works on the phone too, if Syncthing runs there.
  - **The notes folder on a laptop** (`DesktopFolderAccess`): picked with the system folder dialog (`file_selector`) as a plain path. Notes are in its `Notes/` subfolder, as on the phone.
  - **Folder watching** (`FolderWatcher`): while the app is open on a laptop, changes in the folder are picked up about a second after the burst settles (re-index and import other devices' rejections).
    - Syncthing's `.stfolder`, `.stversions` and temporary files are ignored, and `.app/` is watched.
    - No polling. Nothing on the phone, which rescans on resume.
  - **Analysis on a laptop** (`DesktopAnalysis`): there is no WorkManager on Windows, so analysis runs inside the open app.
    - It runs only on mains power (`battery_plus`; a computer without a battery counts as mains) and only after 3 minutes without a key press or click.
    - It stops at the next key or click, and carries on in batches while still idle.
    - The run itself is now one shared function (`runAnalysisOnce`) for the phone's background task and the laptop.
  - **Reminders are phone-only** (user, 2026-10-09): the laptop never schedules them and shows neither the note's reminders section nor the Settings switch (`DeviceKind`).
  - **New packages:**
    - `file_selector` (official; folder dialog);
    - `battery_plus` (power state; reads it only when about to analyse, so no battery cost);
    - `fake_async` (test only).
  - **Not yet run on Windows:** Visual Studio, with the "Desktop development with C++" workload, isn't installed, and Flutter needs it to build Windows apps.
  - The Android build is unchanged in behaviour and still compiles.
  - Tests: 6 Syncthing conflict, 5 laptop runner and watcher rules, 2 real-folder (watching on this machine, and the folder layout).

### Added
- **Laptop version plan** (`docs/LAPTOP_PLAN.md`), with the user's decisions of 2026-10-08:
  - Syncthing first; full notes app plus the AI booster; all four first AI jobs (written "Why?", new tag names, topics, duplicates); Windows first; local AI server only (LM Studio by default).
  - Six phases: L0 foundation, L1 desktop layout, L2 booster engine, L3 phone shows laptop results, L4 settings, L5 packaging.
  - Five open questions, to decide before the phase that needs them.
  - Nothing is built yet.

### Fixed
- **Onboarding privacy line wrapped as "No / cloud"** (seen on the phone, 2026-10-08). Each item now uses non-breaking spaces, so the line breaks only between items. The reminders page's example uses curly quotes.
- **All six onboarding pages checked on the phone (test app), after the fix:**
  - The privacy line now wraps as "… · No account · / No cloud".
  - Every page shows it, including the name page above the keyboard.
  - Not now on the folder page and Skip on the name page lead Home.
  - The folder page's example name now uses curly quotes like the rest.

### Added
- **Reminders a note asks for** (product spec §10a; decided by the user 2026-10-08).
  - **Only when asked:** a line saying "remind me" with a future date and time schedules a notification.
    - It understands times ("at 9 am", "17:00", "noon", "tonight"), dates ("tomorrow", "Friday", "next Monday", "12 Oct", "12/10" day first) and spans ("in 2 hours").
    - A date with no time, or a past time, sets nothing, and the note says why.
    - Month and day words must be real names, so "market 5" or "sun cream" aren't dates.
  - **Kept in sync:** `ReminderSync` follows the notes that contain "remind me" and schedules, moves or cancels to match. Trashed notes never remind.
  - **Fixed during the phone test:** relative words counted from "now" at every sync, so "in 2 minutes" kept slipping a minute later. They now count from when the note last changed.
  - **Privacy:**
    - The lock screen shows only "Reminder".
    - A Locked-folder note's words never reach the notification.
    - Tapping a reminder opens its note.
  - **Permissions:**
    - `POST_NOTIFICATIONS` is back, asked once and only when a note first has a reminder.
    - `SCHEDULE_EXACT_ALARM` is declared but needs the user's grant: Settings shows "On-time reminders · Allow" until it is allowed. Without it, Android may deliver a reminder a few minutes late.
    - The plugin's boot receiver uses the existing `RECEIVE_BOOT_COMPLETED`.
    - The "Notifications are off" hint re-checks after the prompt and whenever the app comes back.
  - **Settings:** "Reminders from notes" in Smart Suggestions, on by default; off cancels all.
  - **Note view:** a "Reminders" section below the text shows each line's state.
  - **Checked on the phone (test app):**
    - "remind me in 2 minutes" showed "Reminder: Today, 9:00 pm".
    - Android's notification prompt appeared at that moment.
    - The notification arrived titled "Reminder", with the line as its text, as an inexact alarm because exact timing wasn't granted.
    - Afterwards the note read "This time has passed".
  - **New packages:**
    - `flutter_local_notifications`: needs core-library desugaring, now enabled in Gradle (`desugar_jdk_libs` 2.1.4).
    - `timezone`: reminders are scheduled as UTC instants, so no time-zone lookup is needed.
    - Release size wasn't re-measured this time (the build was stopped); these are small Java/Dart packages.
  - Tests: 9 parser, 4 sync, 3 widget.
- **Onboarding says it's private on every page** (user, 2026-10-08).
  - The same line ends each page: "Private · Open source · On this phone · No account · No cloud".
  - A new reminders page explains reminders before anyone meets them.
  - The other pages' copy now mentions on-device, no login and open source.
  - Tests check the line on every page.

### Changed
- **Formatting buttons always shown while editing** (user, 2026-10-08): Bold, List, Checklist, Link and Attach sit together above the keyboard, not only while text is selected.
  - With nothing selected, Bold bolds the word at the cursor. A Devanagari word counts as one word, vowel signs included, and nothing happens between words.
  - List, Checklist and Link already worked at the cursor.
  - Tests: Bold at the cursor (English, Hindi, between words), and the bar shows every button.
- **Photos and drawings show in a rounded square** (user, 2026-10-08): 220 on a side, on a plate with a hairline (`EmbedSquare`).
  - A photo fills the square, cropped to fit. It is decoded within twice the square, not at full size, which saves memory while a photo up to 2:1 stays sharp. Tapping still opens the whole photo.
  - A drawing is framed to the area its lines cover, so a sketch made on a tall canvas isn't tiny.
  - `AppSize.embedMaxHeight` (280) is replaced by `AppSize.embedSize` (220).

### Fixed
- **Cursor 7–8 lines too low after attaching a photo or drawing** (found by the user).
  - **Cause, measured:** on an empty *last* line, Flutter places the cursor from the line above; under a tall picture it lands about half the picture's height too low. An empty line that has another below it is placed correctly, which is why typing a character fixed it. Voice notes are short, so they were unaffected.
  - **Fix:** `AttachmentInsert.roomAfter` keeps the cursor off the final line under a picture. Attaching at the end leaves the cursor on a new line with one more below, and a tap below a note that ends in an attachment does the same. The file just ends with a trailing line break.
  - Checked on the phone: a drawing attached at the end, the typed letter lands right under it, and the line doesn't move.
  - A widget test checks that the cursor sits right under a 200 px picture.

### Fixed
- **Photo and drawing previews spilled over the lines above them** (found on the phone, 2026-10-08). A drawing showed on top of the note's title and reached into the status bar.
  - **Cause:** Flutter's text field forces every line to the same height by default (`forceStrutHeight`), so a tall inline preview got no room and was centred on a one-line slot.
  - **Fix:** the note editor turns that off (`strutStyle: StrutStyle.disabled`), so each line takes its content's height.
  - A widget test now checks that a 200 px preview gets its own room below the title. Without the fix, the editor stays 88 px tall.
- **Checked on the phone (2026-10-08, test app):**
  - The app starts with the new fragment activity.
  - The paperclip shows above the keyboard and its sheet lists the four choices.
  - A drawing is drawn, saved as `.drawing.svg` and embedded.
- **Rest of the phone check (2026-10-08, test app, after the fix):**
  - **Drawing:** it now sits on its own line under the title, and text after it starts right below. A large gap under a drawing that was the last line showed once, then not again after reopening; the layout test covers that case.
  - **Gallery:** the Android photo picker opens with no permission, and backing out inserts nothing.
  - **Camera:** the system camera opens with no camera permission, and its ✕ cancels cleanly. No photo was taken, to avoid capturing the room; the save path is the same as the gallery's and is covered by tests.
  - **Voice:** the microphone prompt appears on first use. Recording counts up, Save embeds a "Voice note" pill, and Play plays with the time shown. The microphone indicator goes off after saving.
  - **Locked folder:**
    - Locking left Home with Undo, and the Locked pill appeared with its icon.
    - The system `BiometricPrompt` showed (the screen is blank to captures, as Android protects it) and unlocked with the user's fingerprint.
    - Lock now shows the lock.
    - The database held no passages, analysis or suggestions for the locked note.
  - **Drawings saved as SVG:** the file holds one path per line and a light plate.
  - **Settings → Attachments:**
    - The row shows the space used.
    - A dummy unused file showed as "1 not used in any note".
    - Remove unused deleted it once Undo expired, and kept the files in use.
  - **Background analysis without `WAKE_LOCK`:** forced with `cmd jobscheduler run -f -n androidx.work.systemjobscheduler`, it finished (`run finished, all done: true`) with no security error. Unforced, it waited for "charging", as designed: the phone was on power but not counted as charging.

### Added
- **Locked folder** (product spec §15, UI spec §5 and §7). Decided 2026-10-08 (user): an app lock (not encryption), opened with the phone's own lock, one folder.
  - **Locking:** ⋮ → Move to Locked folder moves the note into `Notes/Locked/`, keeping its folder inside like Archive, and leaves it with Undo. It needs a screen lock on the phone, so a note can't get stuck.
  - **The AI never touches it:** locking deletes the note's passages, vectors, analysis record and suggestions, and each analysis run first forgets anything found in `Locked/`. Queries leave locked notes out of analysis, pending suggestions and the matching pool.
  - **Hidden** from Home, Search, the Graph, the folder and tag lists, the link picker, and the links lists of open notes. The trash shows it as "Locked note".
  - **Opening:** the Folders view ends with a Locked pill (lock icon) that opens with the phone's lock and offers Lock now. A locked note asks right away, and shows a lock with Unlock while closed. The folder closes after 30 s away (a camera trip doesn't relock), or with Lock now.
  - **New pieces:** `SpecialFolder` (shared by Archive and Locked), `LockedFolder`, `DeviceLock` with `FakeDeviceLock` in tests, `LockedSession`, and `LockedGate` (shared widget). `MainActivity` is now a `FlutterFragmentActivity`, which the system prompt needs.
  - **New package:** `local_auth` (official Flutter plugin; adds `USE_BIOMETRIC`, an install-time permission with no prompt). No battery cost: it runs only when asked.
  - Tests: 5 rule/query tests and 3 widget tests.
  - Not yet checked on the phone (fingerprint / PIN prompt).
- **Attachment clean-up in Settings → DATA** (user, 2026-10-08).
  - **Attachments** shows the room they take and how many no note uses. Notes in the trash or archive count, so restoring one brings its attachments back.
  - **Remove unused attachments** removes them at once with Undo. The files are deleted only when the Undo message goes away, and one a note uses again by then is kept.
  - **Remove unused attachments on their own** is off by default. When on, files in no note for 30 days are deleted at start; when each was first seen unused is kept in this device's settings.
  - **New in every file store:** list and delete attachments; the Android bridge gains `files`.
  - Tests: 3 rule tests (usage, re-used files kept, 30-day sweep) and 2 widget tests. The settings test now scrolls to the row it needs, since DATA grew.

### Changed
- **Removed two permissions WorkManager added** (user, 2026-10-08): `POST_NOTIFICATIONS` (the app sends none) and `WAKE_LOCK`. The minimum Android is 7 (API 24), where WorkManager runs on the system job scheduler, which holds the wake lock itself; the app schedules no expedited or foreground work. Removed in the manifest with `tools:node="remove"`.
  - Release permissions are now `RECORD_AUDIO` (voice notes, asked on first use), plus `RECEIVE_BOOT_COMPLETED`, `FOREGROUND_SERVICE(_SHORT_SERVICE)` and `ACCESS_NETWORK_STATE` from WorkManager.
  - **To check on the phone:** a background analysis run still completes.
- **Drawings are vector (SVG)** (user, 2026-10-08: "vector, so it never blurs"). A drawing is now one file, `<id>.drawing.svg`, with each line a path.
  - It stays sharp at any size and opens in any app, printed in light ink on a light plate.
  - The app reads its own SVG back to keep drawing, so the separate strokes file and the PNG are gone.
  - SVGs from other apps (curves, shapes) can't be drawn on and show as "This attachment isn't here yet."
  - Saving no longer renders an image, so it is instant.
  - Tests: an SVG round trip (lines, a tap as a dot, foreign SVGs refused).

### Added
- **Attachments, part 1: storage and the embed** (product spec §2–3, UI spec §7). Decided 2026-10-08 (user):
  - Three kinds: photo, drawing and voice.
  - Each sits inline at the cursor, on its own line.
  - An attach row above the keyboard while editing.
  - Drawings stay editable.
  - Photos come from the camera or the gallery.
  - **Files:** `MyNotes/Attachments/<id>.<ext>`, beside `Notes/`. A drawing is `<id>.drawing.png`, which any app can open, plus `<id>.drawing.json` with its strokes. Every file store (local files, the picked Android folder, the test store) reads and writes them; the Android bridge gains `readBytes` / `writeBytes`.
  - **In the note:** a standard Markdown embed `![](Attachments/<name>)` on its own line, the path from `MyNotes/`, so other apps find it.
  - **Editing:**
    - The editor draws a preview in place of the line.
    - The cursor never rests on that line.
    - Deleting into it, or backspace at the start of the next line, removes the whole embed, so the markup never shows half-deleted.
  - **Readers and the AI:** titles, card previews, copies and the AI's text leave embeds out. A note's title is its first line with words.
  - **Moving notes:** when they move into a picked folder, the attachments they embed are copied too. The originals stay in the app's private folder for now.
  - **New packages:** `image_picker` (official; camera through the system camera app, so no camera permission), `record` (microphone), `audioplayers` (playback). Their sizes are logged with the finished feature.
  - Tests: 10.
- **Attachments, part 2: attach, previews, photo, drawing, voice.**
  - **Attach:** a paperclip in the slim row above the keyboard whenever the note is being edited; bold, list, checklist and link join it while text is selected. Also **Attach** in the ⋮ menu. It offers Photo from gallery, Take a photo, Voice note and Drawing, and the result goes in at the cursor on its own line.
  - **Photo:** shrunk to 2048 px and saved as JPEG at quality 80 (CLAUDE.md §8). In the note it shows up to 280 tall; tapping opens it full screen with pinch to zoom.
  - **Drawing:** a full-screen canvas with one ink, Undo last line, Clear and Save. In the note it is drawn from its strokes in the theme's ink, so it reads in light and dark. Tapping reopens it for more drawing; Save writes the picture and strokes again. The PNG for other apps is printed light (ink on the light plate).
  - **Voice:** a sheet starts recording (AAC, mono) with the time counting up; Save or Cancel ends it, and the microphone is released at once. In the note: play / pause, "Voice note", and the time played. Nothing plays until tapped.
  - **Permissions:** the microphone is asked for on first use only. If refused, the sheet says how to allow it. `RECORD_AUDIO` is the only new permission; the camera goes through the system camera app, and the gallery through Android's photo picker.
  - **Trouble:** device trouble (no camera app, storage full) reads "Couldn't attach that." A missing file (still syncing) reads "This attachment isn't here yet."
  - **Code:** `AttachmentCapture` (core/platform) wraps the plugins behind one interface, so widget tests use `FakeAttachmentCapture`. The note's details moved into `NoteDetailsSection` to keep the note screen small.
  - **Size, measured:** release arm64 APK 104.4 MB before → 104.6 MB after (+0.2 MB for `image_picker`, `record` and `audioplayers`). No battery cost when idle: the recorder and player are created on use and released after.
  - **Size, found while measuring:** the 104.4 MB baseline is not the 71.3 MB measured on 2026-10-04. The ONNX runtime now ships its x86_64 and armeabi-v7a libraries too (about 37 MB), even in an arm64 build. This is a release-packaging item (BACKLOG).
  - Tests: 1 drawing-model test and 4 widget tests (photo, voice, microphone refused, drawing). The format-bar test now expects Attach while editing.

- **Graph: grouped bubbles for very large libraries** (UI spec §10, the last Graph item).
  - Past 200 notes, the whole-library Graph shows one bubble per top-level folder instead of dots. This applies only with no Folder or Tag filter and no Focus.
  - A bubble's area grows with its note count. Notes at the top level share a "No folder" bubble. A solid line joins two folders whose notes link.
  - Tapping a bubble sets the Folder filter, which shows that folder's notes as dots; the Folder pill reads "No folder" for the top level.
  - Finding a note opens its folder and centres on it. The dots canvas now also centres on a picked note when it first appears.
  - Only the bubbles are laid out (a few nodes), so a large library opens without laying out hundreds of dots; the bubbles layout is cached like the dots layout.
  - Bubbles use the folder amber (outline plus a 16% wash) with ink names; DESIGN.md's Folder Amber note is updated.
  - New pieces: `GraphBubbles` (grouping rule), `GraphBubble` and `GraphBubbleView` widgets, `GraphNode.folder`. New tokens: `AppSize.graphBubbleMin`/`Max`/`Spacing`, `AppOpacity.bubbleFill`.
  - Tests: 1 rule test and 2 widget tests.
  - Checked on the phone (2026-10-08) with 213 seeded notes in the test app.

### Changed
These three changes were asked for by the user on 2026-10-08.
- **Revisit looks like Review.** It shows one old note at a time in a centred card, with **Not now** and **Open** below in thumb reach. Open, or tapping the card, opens the note, and the next one takes its place.
  - New `RevisitButtons` widget; `RevisitCard` no longer has its own Not now.
- **Home's connections card shows no number.** It reads "New connections" however many wait, because a count creates urgency. `AppCopy.newConnections` is now a constant.
- **Graph shows unlinked notes by default.** They are drawn quieter, and the toggle hides them. A new library's Graph, or a folder picked from a bubble, is no longer empty. The empty message now shows only when there are no notes.
- **"Review 5 more" now reads "Review more"** (user, 2026-10-08). The button stays, as the UI spec says, and still loads the next batch of 5. It just shows no number.
- Tests updated, plus 1 new Graph test. UI spec §5, §6 and §10 and product spec §5 are updated.

### Fixed
- **Graph bubbles cut off at the edge.** On the phone, bubbles near the edge lost part of their circle. The bubble area now leaves room for the largest bubble on every side.
- **Home's top row on a phone.** "5 new connections" broke mid-word ("connection / s") in the half-width card, and the two cards had different heights. The gap after the icon is now smaller and the chevron uses the small icon size, so the word fits. Both cards also share the taller one's height.
- **Phone check (2026-10-08, test app only, seeded notes):**
  - Revisit offered the 40-day-old trek note for the new Triund note; Not now and Undo work.
  - The dashed #cooking tag suggestion appeared on an untagged recipe note.
  - Rejecting a link wrote `.app/rejections-<device>.jsonl`.
  - Similar in meaning answered within about 2.5 s with the real model, including its first load.
  - Bubbles: tapping "No folder" filters to the top-level notes. The view comes up empty until "Show unlinked notes" is on, because those notes have no links.
- **Revisit** (product spec §10, UI spec §5). Decided 2026-10-08 (user): old notes related to recent ones.
  - Background analysis compares each note changed in the last 7 days with notes untouched for 30 days or more. The best strong match at the learned link bar becomes a `resurface` suggestion (`noteA` = the old note, `noteB` = the recent note), unless the two are already linked or it was already offered. No new table; no schema change.
  - Home's top row shows a Revisit card beside "N new connections" when something is waiting. It has no count; either card takes the full width when it is alone. The **Revisit screen** lists up to 5 old notes with when they changed and which recent note they relate to. Opening one counts as revisited; **Not now** snoozes it for 30 days (new `snoozed` status) with Undo.
  - Revisits stay apart from Review: no batches, no Home dot, no suggested-link chips and no Graph dashes. The pending queries now filter by kind.
  - Tests: 3 analysis/snooze, 4 widget.
- **Tag suggestions** (product spec §11, UI spec §6–7). Decided 2026-10-08 (user): on the phone, suggest only **existing** tags; new tag names come later with the laptop layer.
  - Rule (`TagSuggester`): among a changed note's closest notes (strong matches at the learned `tag` bar, up to 10), a tag at least 2 of them share, which the note lacks and which was never rejected for it, is suggested; at most 2 per note, best first. Tags are compared ignoring letter case and keep the existing spelling, so no near-duplicates.
  - Shown as dimmed chips (dashed seal outline) after the confirmed tags in the note's Tags row, read out as "Suggested tag: #music", and as tag cards in Review. The card shows this note, then the closest note that already has the tag, with "Notes like this one are tagged #music."
  - Accept adds the tag to the note's header (an approved addition); Undo removes it unless the tags changed since. Reject is remembered as the pair (note id, `#tag`) in the same rejections file and database, so it never returns for that note. Accept / reject count toward the `tag` kind's own bar.
  - Schema 6: suggestions get a `tag` column (empty for links) and the unique key includes it; the table is rebuilt on upgrade and pending suggestions are kept (migration test). For a tag, `noteA` is the note to tag and `noteB` the closest note that has it; it never gets a "Suggested link" chip or a Home dot, and the Graph's dashed lines stay links only.
  - Home's "N new connections" card counts tag suggestions too, since they are reviewed in the same batches.
  - Tests: 4 rule/analysis/action, 2 widget, 1 migration.
- **Learning from accept rates** (product spec §7–8). Each suggestion kind keeps its last 20 accept / reject decisions ("Not sure" doesn't count; Undo takes a decision back). From 10 decisions on: if 70% or more were rejected, that kind's match bar rises 0.02 (at most +0.10 over the start); if 80% or more were accepted, it eases down 0.02 (at most 0.04 below the start, so suggestions stay strong). After a step the count starts over, so the bar moves slowly. Kept in this device's private settings; background analysis reads the link bar before each run. No model training. `SuggestionLearning` (rule), `KindLearning` (model). 6 tests.
- **"Similar in meaning" in Search** (UI spec §9). A moment after typing pauses (400 ms), the on-device model reads the search words and the notes whose passages are closest in meaning appear under Matches, up to 5, best first, each showing its closest passage. Keyword matches never wait and are never repeated there; the Folder / Tag / Date filters apply; archived and trashed notes are left out. Only while suggestions are on in Settings (it is AI). If the keywords find nothing but meaning does, the meaning results replace "No notes found".
  - `MeaningSearch` (core/ai/search) compares the query vector with the passage vectors analysis already stored; nothing new is stored. The model loads on the first search and stays loaded only while Search is open, then is released (a bounded exception to "load, run, release", so each keystroke doesn't pay the load).
  - Bar: cosine 0.40 (a short query scores lower against a passage than two passages do); to tune from use. Not yet checked on the phone with the real model (load time and the bar).
  - Tests: 3 unit, 2 widget. The test harness now always gives Search the fake model.
- **Archive** (UI spec §7 ⋮ menu, product spec §2 / §19). Decided 2026-10-08 (user): archiving **moves the note into `Notes/Archive/`**, keeping its folder inside (`Ideas/x.md` → `Archive/Ideas/x.md`), so other apps see a plain folder and Unarchive puts it back exactly where it was. The ⋮ menu shows Archive (or Unarchive on an archived note); archiving leaves the note with "Archived" and Undo. Archived notes leave Home's Recent and Tags views, the Graph, analysis and pending suggestions (which come back if unarchived); Search still finds them, and the Archive folder can be browsed under Folders. One folder rule in `ArchiveFolder`, one SQL/drift condition shared by the queries. 4 tests.
- **Graph folder colour** (UI spec §10, the last Graph item besides grouped bubbles): with a Folder filter on, the dots turn **amber**, the folder colour the user chose (2026-10-08); otherwise they stay ink. New token `AppPalette.folder` (`#B7791F` light, 3.3:1 against the stock, enough for a mark; `#F2B84B` dark, 10.4:1), the app's original ambers. Amber appears nowhere else. 1 widget test. DESIGN.md and `.impeccable/design.json` record it (Folder Rule).
- **DESIGN.md** written from the shipped colour world (finish review disposition "ship" after one fix round), with its sidecar `.impeccable/design.json`, and `PRODUCT.md` (product context, confirmed by the user).
- Spec text that still said "amber" for the pill, widget plus, link underline and set filter pills now says ink (UI spec §3, §5, §7, §9).
- **Trash screen** (UI spec §11), from Settings → DATA → Trash.
  - Deleted notes, most recently deleted first: when, title and the start of the text, with **Restore** and **Delete forever** buttons. A line on top says notes stay 30 days.
  - Restore puts the note back where it was, with Undo.
  - Decided 2026-10-08 (user): **Delete forever** is offered too. The note disappears at once, with Undo; the file is removed only when the Undo message goes away (timed out, swiped, or replaced), so nothing is lost by a slip. Tags, links and suggestions of that note go with it.
  - **30-day clean-up:** notes in the trash longer than 30 days are deleted for good after each start (after the folder check, never delaying the start). Before this, nothing removed them.
  - New `TrashRepository` (list, delete forever, purge). Empty state: "Nothing in the trash."
- **Export notes** (UI spec §11), Settings → DATA → Export notes (Android).
  - Decided 2026-10-08 (user): a .zip of every note as its Markdown file, **in its folders**, saved with **Android's own "save as" screen** (e.g. into Downloads). The trash and the app's own data (suggestions, rejections, analysis) are left out. Nothing leaves the phone unless the user moves the file.
  - The text comes from the database, which matches the files (unsaved typing is written first). Reading every file back through Android's folder access would be much slower.
  - The zip is made in a temporary file, handed to a new `ExportBridge.kt` (the app gets access to that one new file only), and always deleted after.
  - "Notes saved." when done; "Couldn't save the notes. Try again." on failure; nothing if the user backs out.
  - **New dependency: `archive` 4.3** (pure Dart zip writing; no native code, no network). It brings `posix` (desktop file modes only). Writing the zip format by hand was the alternative; not worth the risk.
- **Trash and Export checked on the phone** (test build, its own notes): Delete from Home → Trash lists it with "Deleted Today"; Restore brings it back and Undo returns it to the trash; Delete forever hides it at once, keeps the file during the 5 s Undo, then removes it from `.trash/`. Export opened Android's "save as" screen with "Vera N notes 2026-10-08.zip"; saved to Downloads, the zip held the remaining note's full Markdown file (header and text), and "Notes saved." showed above the nav bar. (Android's screen opens in the last folder used; the user picks where.)
- Tests: 6 storage tests (trash list, delete forever, never deleting an untrashed note, 30-day purge, export contents and name) and 3 Trash screen tests (empty, Restore, Delete forever with Undo). A widget-test note: a live database query read with `.first` inside the test's fake clock leaves drift's clean-up timer stuck and freezes the next step, so those reads use `runAsync`.
- **Capture outside the app** (UI spec §5): every entry point opens its screen directly, with no new package (plain Android code).
  - **App-icon shortcuts:** New note (first), Search, and Review connections only while suggestions are waiting. They are published at run time (`CaptureShortcuts.kt`) instead of from `res/xml/shortcuts.xml`, so they point at the installed build's own package (the test build's static shortcut pointed at the wrong one). Dart turns Review on and off as the waiting count changes.
  - **Quick Settings tile "New note"** (`NewNoteTileService`): closes the shade and opens a blank note; on a locked phone it asks to unlock first.
  - **Home-screen widgets:** Quick note bar (4x1, "Write a thought…" and an amber plus) and New note button (2x1). One tap opens a blank note; nothing to load or refresh. They follow the system theme through Android resources (`values` / `values-night`), which mirror `app_palette.dart` and `app_layout.dart` because native widgets can't read the Dart styles file.
  - **Settings → Quick capture** (APP section, Android only): Add quick note bar, Add New note button, Add Quick Settings tile, using Android's own add prompts. Where a prompt isn't available (older Android or launcher), a short line says how to add it by hand. Nothing is added automatically.
  - Entry points now share one route mapping (`CaptureIntents.kt`): new note, search, review. A running app switches tabs or opens the screen on top.
  - Floating messages on tab screens (Undo, notices) now share one margin token, `AppSpace.aboveNavBar`.
  - **Checked on the phone** (Android 15, test build):
    - New note and Search shortcuts are published (Review hidden with nothing waiting).
    - Settings → Quick capture shows Android's own prompts for the tile and both widgets, with correct previews.
    - The tile opens a blank note with the keyboard up: Android reports it drawn 1.16 s after the tap from a cold start.
    - The quick note bar opens a blank note with the keyboard up, **839 ms from tap to typing cursor** with the app not running (Android: drawn at 989 ms). Meets the ~1 s target.
  - **Fixed on the phone:** a widget added just before the app was force-stopped stayed a blank placeholder, because Android drops a stopped app's widget updates. The app now redraws its widgets every time it starts. (A force stop also cancels the app's tap actions until it runs again; that is Android behaviour for every app's widgets.)
  - **Measurement caveat:** the "ms to typing cursor" log counts from when the app's process started. Opening the Quick Settings panel starts the process early (to show the tile), so that log read 17 s for the tile; Android's own "Displayed" time (1.16 s) is the right number there. The same effect may explain the 15 s first launch in BACKLOG.
- **Onboarding** (UI spec §4): the full first-launch flow, on every platform (was: the folder question only, on Android).
  - All five screens are one swipeable set of pages with dots, in one route (`/welcome`); at the user's request the folder and name are pages of it, not separate screens.
  - Pages 1–3 ("Notes that stay yours.", "Just write.", "The thinking happens on your phone.") have Next; Skip at the top goes straight to the folder page. Moving between pages uses the standard motion, or jumps with reduce motion on.
  - The folder page (Android only) has Choose folder and Not now; both continue to the name page.
  - The name page ("What should we call you?") has Done, which keeps the name for the greeting, and Skip. Its keyboard opens only when the page is reached. Onboarding is marked done only here, so quitting halfway shows it again.
  - Decided 2026-10-08 (user): screen 3 keeps its laptop line although the laptop layer isn't built yet. It must exist before launch for the claim to be true (UI spec §4).
  - Checked on the phone (test app, fresh data): swipe and Next through screens 1–3, Not now, a name, then Home greeted by name. Fixed: the page dots sat at the left edge.
  - `ProgressDots` moved to `shared/widgets/` (Review and onboarding), with the screen-reader label passed in.
  - Tests: the old folder-screen tests are replaced by 6 covering the whole flow (pages and Next, Skip/Not now/Skip, folder and name, backing out of the picker, swiping through every page, desktop without the folder page).
- **Graph, second part** (UI spec §10).
  - **Focus:** the preview card's Focus shows only that note and its neighbours, 1 step away by default; "1 step / 2 steps / 3 steps" pills widen it, and "Show all" ends it. The bar reads "Focus: {title}".
  - **Search jump:** the search icon opens a sheet listing note titles as you type; picking one selects it and centres the graph on it, zoomed in enough to read titles. A note that was hidden (unlinked, or outside the focus) is made visible first.
  - **Folder and Tag filters**, as in Search (a folder includes its subfolders). Links count only between notes the filters keep.
  - **Show suggestions** (off by default; offered only while suggestions are on in Settings): waiting suggestions appear as dimmed dashed lines. Their notes show even if unlinked. Tapping a line (or its screen-reader item, "Suggested link: A and B") opens the same suggestion sheet as in a note, with accept / reject and Undo; closing it counts as not sure. The layout uses confirmed links only, so turning suggestions on never moves the dots.
  - The suggestion sheet and its accept / reject flow moved to `shared/widgets/` (`SuggestionSheet`, `SuggestionFlow`) so the note view and the Graph share one. Following the layer rule (shared widgets take data and callbacks), the flow gets the actions, the view loader and the date wording as callbacks.
  - **Layout timing** (laptop, Dart JIT, random graphs with 1.5 links per note): 60 notes 15 ms, 200 notes 81 ms, 500 notes 426 ms. Graphs of up to 30 notes are now laid out in place (a few ms), larger ones in a background isolate, so the screen never stalls. Not yet measured on the phone.
  - Not built: folder colours for dots when filtering by folder (the app has no folder colours yet), and grouped bubbles for very large libraries.
  - 2 widget tests (Focus and its steps; a dashed line opens the sheet).
  - **Checked on the phone** (test app with its own storage; 7 notes in two folders, two linked groups, one suggestion): dots and lines, selection and preview card, Focus, Show all, Show suggestions, accepting a dashed line (it turned solid, the dot grew), and the search jump to an unlinked note all worked. Fixed what the check found:
    - Separate groups were pushed far apart, squeezing each group into overlapping dots with invisible lines. The pull to the middle is stronger (1.0, was 0.05) and each note gets more room (110, was 90). A link is now about a third of the width in a two-group graph, was 0.09.
    - Showing suggestions moved the dots, because notes that only had a suggestion changed the layout. Those notes are now always placed and only drawn while suggestions are shown.
    - Focus left the preview card covering the focused notes; it now closes it.
    - The "Linked" / Undo message sat under the floating nav bar on Graph and Settings. `UndoSnackBar` (and `SuggestionFlow`) can now keep it above the bar.
- **Graph, first part** (UI spec §10): the Graph tab, between Search and Settings.
  - Each note is a dot and each confirmed link a solid line (written `[[links]]`, accepted suggestions included, either direction counted once). Dots grow with the number of links, up to a cap, in one color.
  - Notes with no links are hidden; the "Show unlinked notes" pill shows them as quieter dots.
  - Pan and pinch to zoom (0.3–4×). The graph starts centred, zoomed out only as far as needed to fit, so a few notes sit close together rather than at the screen's edges (seen on the phone with two notes). Titles appear from 1.4× zoom.
  - Tapping a dot highlights it and its links and shows a card with the title, the start of the note, and Open. Tapping elsewhere or ✕ closes it.
  - Screen readers get one item per dot ("Alpha, 2 links") that selects it, since a drawing can't be read.
  - **Layout:** a force layout (Fruchterman–Reingold, 300 steps), deterministic, so the same notes and links always give the same picture. Small graphs run in place; larger graphs run in a background isolate. Each result is cached for the session (last 4 kept), so the layout is only recomputed when notes or links change. Not yet measured on the phone for large libraries; the "grouped bubbles" view for very large libraries comes later.
  - New `GraphRepository` (one query for links, one for notes, updating when either changes).
  - Empty state: "Links between your notes will appear here."
  - Next part: Focus, the search jump, Folder and Tag filters, and "Show suggestions".
  - 4 tests (edges and trash, layout determinism, empty state, tap to preview and Open).
- **Settings screen** (UI spec §11), the fourth tab after Home and Search (Graph joins later).
  - **YOU:** Name, used in the Home greeting ("Good evening, Asha"); clearing it goes back to just "Good evening".
  - **APP:** Layout (Grid | List), Open app to (Home | New note), and Theme (System | Dark | Light), as pills. A change shows at once. Choices are kept on this device in the settings table and read once at start, so the first frame already has the right theme and layout. The list layout uses the same note card, full width (new token `AppSize.noteRowHeight`).
  - **SYNC:** Notes folder shows the folder's name, or "On this phone only" with the hint to choose one; tapping opens the folder picker and moves the notes there. Hidden on desktop.
  - **SMART SUGGESTIONS:** "Suggest connections" turns AI off completely: waiting analysis is cancelled, nothing new is scheduled, and no suggestion shows anywhere (Home card, card dots, note chips). Turning it back on shows any that were waiting. "Analyze only when charging" is on by default (as drawn in the spec): analysis is requested only with the charging constraint. Turning it off adds the idle-and-battery-not-low request as before.
  - **ADVANCED** (collapsed): "Rebuild suggestions" clears waiting suggestions and marks every note for matching again on the next run. Stored vectors are reused by chunk hash, so this costs little battery. "Reset rejected suggestions" forgets every rejection and empties this device's rejections file. Both offer Undo instead of a question.
  - **ABOUT:** the privacy line, the version (read from Android through the existing `vera_n/launch` channel, so no new package), and Licenses, which include the suggestion model's.
  - Not yet shown, because those features don't exist yet: Quick capture, sync Status, Laptop connection, Trash and Export. They join with their features.
  - Fixed on the phone: the APP choices were centered instead of left-aligned, and each choice was read out twice by screen readers.
  - New shared widgets `SettingRow` and `SettingChoice`; `TextEntrySheet` can start with text and allow an empty entry.
  - 4 tests (prefs saved and read back; Dark applies and is saved; suggestions off hides them on Home; reset with Undo).

- **Suggestions in the note view and on Home cards** (UI spec §5, §7–8).
  - **Note view:** a "Suggested links" section of dimmed chips (dashed outline), read out as "Suggested link: …". Tapping one opens the suggestion card in a bottom sheet with ✕ / ✓; closing the sheet counts as not sure and the chip stays. Accept and reject are the same actions as in Review, followed by "Linked" or "Not linked" with Undo.
  - **Accepting inside the open note:** if the link is written into this note, the editor first saves what was typed, then shows the new text, so the next autosave can't drop the link.
  - **Home cards:** a small dimmed dot (no number) on the card of every note with suggestions waiting, read out as "Has suggestions". The Home query gets this from one indexed `EXISTS` check (new index `suggestions_note_a`).
  - **Shared widget:** the ✕ / Not sure / ✓ row is now `shared/widgets/decision_buttons.dart`, used by Review and the sheet.
  - 4 widget tests.
- **Review screen and the Home "new connections" card** (UI spec §5–6, §8).
  - **Home card:** "N new connections" sits under the greeting. It counts at most one batch (5), so it never becomes a growing number, and it is hidden when nothing is waiting.
  - **Review:** one suggestion at a time, on the shared `SuggestionCard`: newer note first, the matched passage highlighted, the reason ("Looks related to your note on …"), and "Why?" to read the passages in full. Tapping a note opens it. Progress shows as dots, with the position read out to screen readers.
  - **Gestures:** swipe right to accept, left to reject, up for not sure, down to undo. The card tilts while dragged, shows a faint ✓ or ✕, and settles on a spring; with reduced motion it moves without animating. ✕ / Not sure / ✓ buttons (64-point targets) and Undo are always visible.
  - **Feedback:** accepting shows "Linked" with Undo. Haptics go through the new `core/feedback/haptics.dart`: light on accept, soft on not sure and undo, none on reject.
  - **One-time hint** showing the four gestures; whether it was seen is kept in settings.
  - **End of batch:** a quiet "All caught up."; "Review 5 more" appears only when suggestions this batch didn't show are waiting.
  - Nothing loads with a spinner: it is all on the device.
  - 7 widget tests.
- **Suggestion lifecycle** (product spec §7–8, UI spec §8): accept, reject, not sure, each with undo, and review batches of 5. The same `SuggestionActions` will serve the Review screen and the note's suggestion sheet (next changes).
  - **Accept:** the newer note of the pair gets a link to the older one in a "## Linked notes" footer at its end. The footer is only ever added to (`NoteFooter`). Undo removes it only if the note wasn't edited since, so it never takes the user's words.
  - **Reject:** stored in the database and appended to `MyNotes/.app/rejections-<deviceid>.jsonl`, which holds note ids and content hashes only, never note text (a test checks this). A headerless note gets its `id` header at that point, as for pin and tag.
  - **Not sure:** stays dimmed; comes back after fresh ones in later batches until it expires.
  - **Batches:** fresh suggestions first, then not-sure ones, oldest first; pairs with a note in the trash are hidden.
  - Decided 2026-10-04: **a rejected pair comes back only after a big change**, when about a third or more of a note's words differ, and only if it is still a strong match. The app measures this without keeping note text: a 128-byte word fingerprint (MinHash) of each note is saved with the rejection, in the private database only. Rejections arriving from other devices' files have no fingerprint, so those pairs stay rejected.
  - Notes can now read and write `.app/` files (`NoteFileStore.readAppFile` / `writeAppFile`). Reading other devices' rejection files comes with sync.
  - Schema 5 adds the `rejections` table, with migration.
  - 16 new tests.
- **On-device analysis: embeddings and link suggestions** (product spec §4, §7; build order step 5). Leaving the app requests analysis. It runs later, through Android's WorkManager, only while charging or idle. It embeds only notes whose text changed, and only their changed chunks; the model is loaded only when there is work, then released. Each changed note is matched against the others, and pairs at cosine ≥ 0.60 become suggestions that expire after 30 days. Nothing shows in the UI yet: the dimmed suggestions and the Review screen come next. Details: ARCHITECTURE.md §8 "On-device analysis". 23 new tests (chunking, including Hindi; int8 vectors; matching; the full run with a stand-in model: only changed chunks re-embedded, model not loaded when nothing changed, linked pairs skipped, expiry, model change, stopping).
- **Schema 4:** `note_analysis`, `chunks`, `suggestions` tables, with migration and a test from versions 1–3.
- **New dependencies:**
  - `flutter_onnxruntime` 1.8.5 (ONNX Runtime native libraries, about 15 MB per CPU type);
  - `dart_sentencepiece_tokenizer` 1.4.1 (pure Dart, small);
  - `workmanager` 0.10.10 (wraps AndroidX WorkManager, under 1 MB).
  
  Battery: no work while the phone is in use and on battery; no polling, wake locks or foreground service.
- **Model in the app:** the model is now listed in the `pubspec.yaml` assets, with its license shown on the app's licenses page. **Measured size (release, arm64 APK): 21.4 → 71.3 MB.** On the phone, the model is also copied out once (about 45 MB) for ONNX Runtime. That is within the user's 150 MB limit.
- Decided 2026-10-04: **accepted links are stored inline**, in one append-only "Linked notes" footer at the end of the note (product spec §5, §21; ARCHITECTURE.md §7). Built in the Review stage.
- **Typing performance tools** (`tool/perf/`). `typing_scenario.sh` types into the measurement build over adb (kinds plain, rich, long) and prints frame stats. `bin/timeline.dart` records the engine timeline over the VM service and summarises it per thread. New dev-only dependency in `tool/perf` only: `vm_service`. No change to the app's own dependencies.
- **Trimmed embedding model committed** at `assets/models/minilm-l12-en-hi/`, with Git LFS (`.gitattributes` tracks `assets/models/**`). Included: the Apache-2.0 license and a README with source, SHA-256 checksums and the notice of changes. Not yet listed in `pubspec.yaml` assets; it joins the app in the embeddings stage, so builds don't grow before the model is used.
- Decided 2026-10-04: **similarity threshold 0.60** for a "strong" match at launch (ARCHITECTURE.md §7, product spec §21).
- **Embedding model chosen and trimmed** (decided 2026-10-04). The model is paraphrase-multilingual-MiniLM-L12-v2 int8 (Apache-2.0), bundled in the app, with the user's limit of 150 MB app size.
  - The full model would mean ~120 MB download but ~255 MB on the phone, because it is unpacked from the APK. So `tool/model_trim/` trims it to English + Hindi: it keeps the word pieces the 300,000 most common English words use (wordfreq, which includes common romanized Hindi), all Devanagari, symbols and emoji. Kept rows keep their exact values.
  - Result: model 118 → 44.9 MB, tokenizer 17 → 2.4 MB.
  - Quality on the related-pair test is identical, on the computer and on the phone. Everyday notes average 0.998 similarity to the full model; English prose averages 0.994.
  - On the phone: load 1.6–2.1 s → 0.54–0.79 s; memory while loaded 421–477 → 299–314 MB; same speed.
  - Projected app: ~71 MB download, ~118 MB on the phone.
  - Trade-off: notes in other scripts get weak suggestions.
  - A frequency-only cut was tried first and rejected (details in `tool/model_trim/README.md`).
- **Embedding model benchmark tool** (`tool/embedding_bench/`, product spec §20 risk 1). A separate test app, so the Vera N app gets no new dependencies and real notes are never touched.
  - Measures load time, memory, and time per note at three lengths, plus an indicative quality check on a hand-written Hindi / English / Hinglish set of related pairs.
  - Candidates: multilingual-e5-small (MIT), paraphrase-multilingual-MiniLM-L12-v2 (Apache-2.0), both int8 ONNX; EmbeddingGemma-300M (LiteRT, Gemma terms, gated, downloaded by the user).
  - all-MiniLM-L6-v2 was dropped: English-only, and its tokenizer isn't supported by the Dart tokenizer used.
  - **Results (2026-10-04)**, full table in `tool/embedding_bench/README.md`. Phone charging at 39 °C; 3 fresh launches per model; EmbeddingGemma not run (user choice: open models only).
    - Speed: both embed a typical note in 15–30 ms (median). Long notes: e5-small 93–96 ms for 211 tokens; multilingual MiniLM 52–61 ms, but it reads only 128 tokens.
    - Load time: 1.5–2.4 s for each model.
    - Memory: both add about 250 MB while loaded (165 → ~420 MB), so load, run a batch, and release is required.
    - Quality, on 24 Hindi / English / Hinglish texts, so indicative only. Multilingual MiniLM found every text's partner (24/24), with related pairs averaging 0.71 and unrelated 0.09. e5-small found 22/24, with everything scoring 0.80–0.89 and related and unrelated overlapping.
    - Size: about 130 MB with either model.
  - Test phone: Snapdragon 778G (SM7325), 7.4 GB RAM, Android 15.
- **Numbered lists** (backlog #6 and #3). Typing `1. ` starts a list; Enter adds the next number and renumbers the items below; Enter on an empty item ends the list; backspace right after the number removes it. The List button keeps numbered points numbered, one per line, splitting points written inline ("1. milk 2. eggs") but only at numbers that count on. A numbered list pressed again loses its numbers. New: `MarkupKind.numbered` (visible, not hidden), `MarkupSpan.hasGlyph`, `MarkupEditing.renumberAfter`, `NumberedPoints`. 12 tests, including Hindi.
- **Delete and pin from Home** (backlog #7). Long-pressing a card opens a sheet with Pin / Unpin and Delete. Delete moves the note to the trash with an Undo popup, never a confirmation. Both actions are also inside the note, so the gesture has a visible button alternative (UI spec §2). Long-press rather than swipe: a swipe in a two-column grid is easy to trigger by accident while scrolling. New: `HomeNoteMenu`, and `CardCallbacks` (open and menu) replace Home's `onOpen` parameter. 3 tests.
- **Tab switch animation** (backlog #10). The amber pill slides to the chosen tab by transform only (`AnimatedSlide`), icon colours fade, and the page fades in; 200 ms ease-out from the motion tokens. With "reduce motion" on, all of it is instant (`Motion.of`, new in `core/feedback/motion.dart`). 2 tests measure the pill's position halfway through and with reduce motion.
- **Copy note** button next to pin (backlog #11). Copies the whole note as the user sees it (`NoteMarkup.display`: links as titles, ☐ / ☑, no Markdown), including text not yet saved, then shows a brief "Copied" (`NoticeSnackBar`, token `AppMotion.briefNotice`). Disabled while a new note is empty. 2 tests.
- **Home Recent | Folders | Tags switch** (UI spec §5; the open question in §14 is now decided).
  - Folders and Tags show a pill per folder or tag; tap one to see its notes (a folder includes its subfolders), tap again to clear.
  - The lists update live, and the view and the pick are kept while the app runs.
  - New: `RecentView` and `GroupView` (slivers), `PillTabs`, a `FilterPill` without the ▾, `homeViewProvider`.
  - `NotesRepository.watchNotes(filters:)` reuses Search's filter SQL, now `NoteFilterSql`. `SearchRepository.watchFolders()` and `watchTags()` are live versions of the picker lists.
- Tests: 5 new (default view, folder pick and clear with subfolders, tag pick, empty views, place kept after opening a note). 197 in total.
- **The editor shows formatting, not Markdown** (at the user's request). Bold is bold. Checklist lines show real checkboxes that tick with a tap (ticked items are struck through), and bullet lines show •.
  - The Markdown stays in the file for Obsidian. In the editor, the cursor skips the hidden symbols, and backspacing into them removes only the formatting.
  - Enter continues a checklist or bullet list; Enter on an empty item ends it.
  - Cards and search show ☐ / ☑ / • and plain words.
  - `NoteMarkup` (core: finds links, bold, checklist and bullet lines, and gives the reader's text) replaces `LinkMarkup` and `NoteLinks.displayText`. `MarkupEditing` holds the editing rules; `CheckboxGlyph` is drawn inline as a `WidgetSpan`.
  - Tokens: `AppTextStyles.strong`, `AppTextStyles.done`, `AppSize.glyphWidth`.
  - Accessibility trade-off: the checkbox target is 32 points wide by one line tall, below the 48 minimum, because a full-size target would spread every list line apart. Recorded in UI spec §7.
- **Tapping a link's title in the editor opens the linked note** (`LinksRepository.findNote`).
- **Typing performance work** (user report: typing felt jumpy when fast), measured on the phone (model A063, Android 15, charging, 37 °C). Profile builds, cold start into a new note, 12 bursts of `adb shell input text` with 0.35 s pauses, two rounds alternating before and after, 3 runs each:
  - Build p90: 3.1–4.0 ms before → 2.4–2.5 ms after (about a third less); the worst build frames mostly dropped too.
  - Frames over 8.3 ms (6 runs combined): 130 before, 121 after, which is within the noise.
  - Frames over 16.7 ms (6 runs combined): 15 before, 32 after, but 13 of those came from one run. Not an improvement.
  - Reading: the changes cut build-side work as intended, but the remaining slow frames are **raster-bound** (GPU drawing), which these changes don't touch. Next step is in `docs/BACKLOG.md`.
  - Limits: adb types much faster than a person, and the test text was plain, so the new formatting rendering wasn't exercised.

  Tooling:
  - `FrameStats` logs frame build and raster times in profile builds, summarized when the app goes to the background.
  - A measurement-only build switch (`--android-project-arg=vera.perf=true`) installs as a separate app with its own empty storage, so timing runs never touch real notes.
- `docs/BACKLOG.md`: the user's 11 pre-release items, with status and the two that conflict with the spec (premium shadows and colours versus product spec §22).
- `UndoSnackBar`: one shared way to offer Undo.
- Tests: 24 new (markup parsing and display, editing rules, checkbox tap, bold rendering, link tap, card symbols, Undo popup timing). 192 in total.
- **Formatting row** (UI spec §7): a slim row above the keyboard, shown only while text is selected.
  - Bold (`**…**`), List (`- `) and Checklist (`- [ ] `). All are toggles; a list line becomes a checklist line rather than getting both markers.
  - Link: turns the selected words into a link to a picked note, keeping your words as the link's title.
  - Plain Markdown, saved like typing. Attach comes with attachments.
  - New: `MarkdownFormat`, `FormatBar`, `NoteFormatActions`; `linkTextFor(label:)`.
- Tests: 13 new (formatting toggles including Hindi, the row's visibility, saving, link from selection). 176 in total.
- **Folder below the note's text**, like tags (at the user's request; UI spec §7). A note in a folder shows one chip; tap it to move. Otherwise an "Add to folder" button; with no folder and no tags, both add buttons share one row.
- **Links show only their title in the editor** ("Time Loop", underlined in amber; text stays the normal color). The note file still holds `[[name|Time Loop]]` for Obsidian.
  - `LinkMarkup` hides the markup: the cursor steps over it in the direction it's moving, and an edit that reaches into it removes the whole link.
  - Keyboard composing (Hindi input) is passed through untouched.
  - New tokens `AppTextStyles.hidden` and `AppTextStyles.link`.
- Tests: 11 new (hidden markup, cursor, removal, label cap, what the editor shows, folder row, no overflow). 161 in total.
- **Links you write** (UI spec §7):
  - Typing `[[` opens a note picker. Picking a note inserts `[[file-name|Title]]`, adding the folder path only when file names clash; backing out leaves `[[` as typed.
  - **Linked:** solid chips with each linked note's current title; tap to open.
  - **Mentioned in:** the notes that link here.
  - Links resolve by file name, like Obsidian: `[[name]]`, `[[name|text]]`, `[[folder/name]]`, `[[name#heading]]` and `![[embed]]` are understood. Links typed in other apps are indexed too.
- `links` table and `notes.name_key` (database schema version 3). The migration fills both from existing notes, so links written before the update show up at once. Links are refreshed on every save and every index. `LinksRepository` provides the Linked and Mentioned in queries (live), plus the link text for the picker.
- `NoteLinks` parsing and writing; `LinkTyping` (spot a freshly typed `[[`, which ignores keyboard composing, then insert the link); `NotePickerSheet`; `NoteRows.placedAt` sets every path column, including the new name key, in one place.
- Tests: 20 new (parsing, links storage and moves, upgrades from versions 1 and 2, `[[` detection, picker flow and backlinks). 150 in total.
- **Note view: tags** (UI spec §7, details written into the spec).
  - Solid tag chips below the text, plus an "Add tag" button.
  - The add sheet lists existing tags first, so they get reused.
  - Tapping a tag offers to remove it, with Undo.
  - The details area hides while typing (editor focused and keyboard up).
  - A tap below the text starts editing at the end.
- **Move to folder** from the ⋮ menu: no folder, an existing one, or a new one typed with `/` for subfolders. The file name never changes; a name clash gets a suffix; Undo is offered.
- `NotePlacement` (trash, restore, move to folder) split out of `NotesRepository`. After a move it records the file's new time and size, so the folder check doesn't re-read a file the app just moved.
- `Names` rules for typed tags and folders.
- Shared widgets `NoteChip` (solid, or dimmed with a dashed outline, ready for AI suggestions), `DashedPillBorder` and `TextEntrySheet`.
- Tests: 13 new (moving, name rules, the header fix, tag and folder flows with Undo). 133 in total.
- **Search filters: Folder, Tag, Date** (UI spec §9, behaviour decided 2026-10-03 and written into the spec).
  - Each pill holds one value from a bottom sheet; the first row clears it. A set pill is solid amber with its value.
  - Folder includes subfolders (letter case ignored). Tag is one confirmed tag. Date is Today, Last 7 days, Last 30 days or This year, by last-changed date.
  - With a filter set and nothing typed, matching notes are listed newest first.
  - Filtering runs in SQL alongside the keyword match.
- Shared widgets `FilterPill` (reusable for the Graph filters) and `OptionSheet`; model `SearchFilters` / `DateFilter`; `SearchRepository.folders()` (with parent folders) and `tags()` (trashed notes left out).
- Tests: 11 new (repository filters and lists, filter widget flows). 120 in total.
- **Search (keyword)**, UI spec §9.
  - The keyboard opens when the tab opens.
  - Matches appear as you type, with no debounce and no spinner; a result that arrives after a newer query is dropped.
  - Matched words get a soft amber fill behind normal-color text, in the title and in a short passage. Results are always one column.
  - "No notes found." when nothing matches.
  - Recent searches (up to 8, kept on this device) can be tapped or removed. A search is remembered when a result is opened or the keyboard's search key is pressed.
  - Not yet built: the Folder, Tag and Date filters (next change), and "Similar in meaning" (embeddings stage).
- **Floating pill navigation bar** (`PillNavBar`), UI spec §3: Home | Search for now. Graph and Settings join when those screens exist, so there are no dead tabs.
  - Icons only, each on the same fixed-size pill (`navItemWidth` 64 by 48); the current tab's pill is amber. Names are read by screen readers and shown on long press. (Changed after review on device: showing the selected tab's name made its pill a different shape from the others.)
  - The bar steps aside while the keyboard is open, and notes open above it, full screen.
  - Back from Search goes Home first.
  - "New note" floats just above the bar.
- `SearchRepository`, split out of `NotesRepository` (which was over 250 lines): FTS5 `highlight()` and `snippet()` with control-character marks, parsed into `MarkedText` ranges. The query builder quotes every word, so typed operators (`OR`, `NEAR`, `*`, quotes) are just text.
- Shared widgets `HighlightedText` and `PillNavBar`; tokens `navBarHeight`, `navBarClearance`, `fieldBorder`, `searchMatch` opacity.
- Test helper `AppHarness`, now used by every app-level widget test instead of copied setup.
- Tests: search repository (prefix, Hindi, highlights, odd input), recent searches, and Search screen widget tests (focus, matches, empty result, recent searches, back to Home). 109 tests in total.
- **Capture entry point.**
  - The `com.example.vera_n.NEW_NOTE` intent starts the app straight in a blank note with the cursor ready, skipping onboarding (UI spec §5). Used now by the app-icon shortcut "New note"; the widgets and the Quick Settings tile will reuse it.
  - If the app is already running, the intent opens a new note on top.
  - Back from a captured note goes Home; Android's own back gesture leaves the app (open, write, close).
- **Startup timing log** (`LaunchBridge.kt`, `LaunchChannel`): profile and debug builds log "VeraN startup: N ms to typing cursor" once per process, measured from process start to the first frame with the focused editor. It stays on the device (`adb logcat`); release builds log nothing.
- Widget tests: capture opens a focused blank note even on first launch; Back goes Home with the note saved. 99 tests in total.
- **Startup measured (baseline, before any startup changes):** profile build on the test phone (model A063, Android 15), cold start through the `NEW_NOTE` intent. Runs 2–8, first run discarded: 541, 489, 477, 477, 479, 479, 466 ms. **Median 479 ms** from process start to typing cursor. The target is about 1 s; this doesn't include the launcher's tap handling or the keyboard's slide-up animation.
  - Breakdown (temporary probe, not committed): about 390 ms passes before Dart's `main()` runs (Flutter engine start, not under our control), 40–50 ms in `main()` (storage, folder and onboarding checks), and 60–65 ms to the first frame with the cursor. Decision: **no startup rework.** Drawing before storage is ready would save at most about 45 ms and would make every file operation wait on startup.
  - Later samples (phone charging, 35 °C): median about 630 ms. An A/B round with and without the keyboard fix measured the same (about 630 vs 640 ms), so the fix costs nothing. The shift from 479 ms is in something both builds share, most likely the phone's state; the launch-colors change was in both builds and wasn't isolated. Still well under the target.

- **Notes folder you can see (Android).** A Kotlin bridge (`NotesFolderBridge.kt`, `SafDocuments.kt`) uses Android's own folder picker and keeps the permission across restarts. No storage permission is requested. File work runs on one background thread, and each folder is listed with one query.
- `SafNoteFileStore`, plus `SwitchingNoteFileStore` so the app can change folders while running. `FolderAccess` keeps this testable without Android.
- **Choosing a folder** moves notes from the in-app holding folder into `<picked>/Notes/`. Notes already there (a reinstall or a synced folder) are kept and indexed. A same-named file with different text is never overwritten.
- **Access removed:** on start, if access to the folder is gone, notes are rewritten into the holding folder from the database. Nothing is lost.
- **Onboarding screen "Choose where your notes live"** (UI spec §4), shown on first launch on Android. *Not now* goes to Home; backing out of the picker stays on the screen.
- Settings table (database schema version 2, with a migration), storing the notes folder, the onboarding flag, and a random 8-character device id for `.app/` files.
- 14 new tests, 97 in total: folder choose, reconnect, access lost, name clash, migration from version 1, the onboarding screen, the empty-folder guard, restore of a missing file, and colons in note names.

### Changed
- **New colour world: "plate section"** (backlog #2 and #4, product spec §22). Layout, buttons, shapes and fonts unchanged; only colours, surfaces and themes.
  - **How it was chosen:** product context written down first (`PRODUCT.md`, confirmed by the user). Then a decision page with a rolled direction (Garhwal night miniature), a pick (bahi-khata ledger) and catalogue challengers; the user chose the challenger "design annual's plate section". The user's guardrails: keep dimmed + dashed for suggestions; avoid gaudy gold, a generic dark app, and any slowdown while typing.
  - **Light:** near-white stock `#F5F4F6`, warmer plates `#FAF9F7`, ink `#16181A`, 1px hairlines `#C9C7C4`. **Dark:** the same section on black stock, `#121315` ground, warm plates `#1C1B19`, ivory ink `#ECEBE8`, hairlines `#393834`. No pure black or white anywhere.
  - **Roles:** the amber accent is replaced by the solid **ink plate** (ivory in dark) for the primary action, the chosen tab or filter, confirmed chips and the caret. A new **seal** colour (periwinkle) belongs only to the AI: dashed suggestion outlines, the "has suggestions" dot, the connections mark and the Graph's suggestion lines. Its soft form highlights selected and matched text. Accept is bottle green, reject vermilion.
  - **Contrast** measured for every pair: text at least 4.5:1, icons and marks at least 3:1, both themes.
  - **Backlog #2's "gold texture and shadows" not taken:** gold was ruled out by the user ("gaudy"), and the chosen world is flat; shadows were left out with it and are offered to the user separately.
  - **Finish review** (independent reviewer, verdict "fix"), all three material fixes applied: suggestion marks drawn at full seal strength (a 55%-faded seal measured 2.1:1 in light and read grey in dark); dark plates and hairlines warmed into the ivory family (they were cooler than the ground); in light, the veil behind sheets is ink at 32% instead of Material's grey, so the page stays pale.
  - **Checklist glyphs on screen:** card previews, search snippets and suggestion passages show □ / ✓ (glyphs Inter has) instead of ☐ / ☑. Inter has no ☐ / ☑, so Android fell back to its color emoji and drew a blue ☑️, the only saturated blue in the app (user's choice after the review, 2026-10-08). Copied text and the AI's chunks keep ☐ / ☑, so copies are unchanged and no note is re-analysed.
  - Decided 2026-10-08 (user): keep the world flat, no shadows on chips; the suggestion card's "NEW · date" / "OLDER · date" labels stay.
  - Native widgets, launch screen and shortcut icons follow the same colours. Unused tokens `AppOpacity.selection` and `searchMatch` removed; new `AppOpacity.scrim`.
- **Suggestions checked end to end on the phone** (2026-10-08, measurement build with its own fresh data, not the user's folder): 5 short notes (two about piano, two about pasta, one about a bike). One run while charging made exactly 2 suggestions, the piano pair and the pasta pair, with none for the bike note. Home showed "2 new connections" and the dots; Review showed both, and Accept linked the first.
- **Background analysis checked on the phone** (2026-10-08, measurement build): requested on leaving the app, started 60 s later while charging, finished successfully. See BACKLOG.
- **Background analysis now runs only while charging by default** (was: charging, or idle with battery not low). This follows the Settings default "Analyze only when charging: On"; the idle request is cancelled when the setting is on.
- **Linked and Mentioned in are text links**, no longer chips (backlog #1 and #9). The note's title in normal text with the amber link underline, as in the editor, tappable across 48 points (`TextLink`). Tags and folders stay chips, so what organises a note looks different from the notes it points to. UI spec §7 updated. 1 test.
- Typing performance: **Saving waits for a 1-second pause** in typing instead of 300 ms. Leaving the note or the app still saves at once.
- **A save is one database transaction** (row, revision and links together) instead of about five statements, so Home and the note view hear about it once.
- **The editor no longer rebuilds after saves.** Only the top bar and the details area listen to the note.
- **Home's list query reads a 280-character slice of each note,** not every note's full text.
- The Note screen was split (`NoteEditorView`, `FormatBar.whileSelecting`) to stay near the file-size target.
- The Android launch screen and the window behind the app use the app background (`#F7F6F3` light, `#0B0B0C` dark) instead of white or black, so there's no flash at start, especially in dark mode.
- UI spec §4: the folder screen now says "or make a new one such as "Vera N" in Documents", because Android's picker can't be pre-filled with a new folder name.
- The path check is shared by both file stores. Note names with `:` (for example `2:17 AM.md`) are allowed.

### Removed
- **Move to folder in the note's ⋮ menu** (backlog #5): it's reached through the Folder row below the text. The unused `AppCopy.moveToFolder` string is gone too.

### Fixed
- **Rejected suggestions now survive reinstalling** (product spec §3, §8). Every `rejections-*.jsonl` file in `.app/` is read into the database after each start (and after choosing a notes folder), so a reinstalled app does not suggest rejected pairs again, and other devices' files will count once sync exists. Pairs already known keep their row; damaged lines are skipped. Read-back pairs have no word fingerprints (those live only in the database), so they stay rejected even after a big change. New `NoteFileStore.listAppFiles` (device files, Android folder via a new `names` bridge call, and the test store).
- **Writing `.app/` files always failed** (found while fixing the above). The app-file name check refused every name: the backslash test had become `contains('')`, which is always true. So on the phone, rejecting a suggestion failed when its line was written. Fixed; the in-memory test store now runs the same check, and a test covers it.
- **A note changed both here and in another app no longer goes silent** (product spec §14). Such a note was marked "in conflict", the app stopped writing it, and nothing told the user, so later edits stayed only in the app. Now its Home card shows a small mark ("Changed in two places") and the note view shows "This note was also changed outside Vera N." with **Compare** (the other version in a sheet), **Keep this version** (written to the file; Undo saves the other version as a new note), **Keep the other version** (Undo puts this text back), and **Keep both** (the other version becomes a new note in the same folder). Nothing is overwritten without a choice. New `ConflictResolver`; `NoteIndexer.reload` / `fileBody`. Tests: 4 storage, 1 widget.
- Kotlin plugin builds failed on Windows (Kotlin's incremental caches can't span the C: pub cache and the D: project). `kotlin.incremental=false` in `android/gradle.properties`, as in the bench tool.
- **Typing in long notes: editor formatting work no longer grows with note length squared** (backlog: typing lag). Each keystroke rebuilt the formatted text by checking every Markdown piece against every text piece. It is now one pass that tracks only the pieces covering the current position. Desktop timing per keystroke: 200 lines 2.3 → 0.8 ms, 1000 lines 43 → 1.3 ms. On the phone at ~150 lines it changed little (UI frame median 23.5 → 23.0 ms, 3 runs each), because the main cost there is elsewhere (see BACKLOG.md).
- **Enter right next to a blank line could fail to continue a list.** The edit position came from comparing the old and new text, which is ambiguous between two line breaks. It now comes from the cursor, for checklists and bullets as well as numbers.
- Note cards in the grid always showed as unpinned. This was harmless while the grid held only unpinned notes, but folder and tag views include pinned ones; `NotesGrid` now uses each note's own pinned flag.
- **The Undo popup never went away on its own** (backlog #8). Flutter keeps a snackbar that has an action until it is dismissed (`persist` defaults to true when there's an action). Every Undo now goes through `UndoSnackBar`, which sets `persist: false`. Covered by a test that was checked to fail without the fix.
- **Home cards showed raw link text** (`[[20261003-153228-a7f3|Time Loop]]`). Everything outside the editor now shows links as readers see them: card titles and previews, search passages, and Linked / Mentioned in titles (`NoteLinks.displayText`). Titles stored before this fix are converted when read, so no migration is needed.
- **Long link labels and chips overflowed.** A note's title is its whole first line, so linking to a one-line note put the entire text into the link and its chip. New links cap the title at 40 characters with "…" (`NoteLinks.labelMaxLength`), and chips stop at `chipMaxWidth` (240) with "…". The "Mentioned in" rows are cut to one line.
- The note picker read the notes list through a live database stream just to take its first value, and that never finished under test. It now uses a one-off query (`NotesRepository.allNotes`), the right tool for a single read.
- **Crash on move or delete in the chosen notes folder (Android).** The Kotlin bridge replied to calls with no result (`move`, `delete`) with Kotlin's `Unit`, which Flutter's channel can't encode, so the app crashed on the main thread right after the file work finished. This hit Move to folder, Delete and Undo. It now replies `null`. Found on the phone from `adb logcat -b crash`. Tests missed it because they use an in-memory folder in place of the bridge. The completed moves were re-matched on restart, so no notes were lost.
- A note starting with a `---` block that isn't a valid header (for example a horizontal rule) was indexed as if the block were a header: its lines were hidden from the text and the title came from the wrong line. Indexing and header writing now share one rule, `NoteHeaderCodec.normalize`: such a block is note text.
- After a header change (pin, tags), the title and content hash are now recomputed when the text changed.
- Bottom sheets opened from a tab screen slid under the floating nav bar, which covered and swallowed taps on their last rows. Sheets now open above the bar. Caught by a widget test before reaching the phone.
- A search result for a one-line note repeated the title as its passage; the repeat is now hidden.
- **Keyboard didn't open on a cold start into a new note.** The editor was focused, but Flutter asked for the keyboard before the app's window had input focus, and Android ignored the request. Now, the first time the window gains focus, the app asks again if a text field is focused. This happens once per launch, so a keyboard you dismissed doesn't pop back. Verified on the phone: 4 of 4 cold starts show the keyboard; Home without capture doesn't.
- Restoring a trashed note whose file is gone (for example left in another folder) now writes the file again from the database.
- The indexer no longer empties the index when the notes folder is unavailable. If the folder lists as empty while more than one note was indexed, nothing is removed.

## [0.1.0] - in progress

### Added
- `lib/core/styles/app_styles.dart`: the one styles file (CLAUDE.md §4). Covers the palette from spec §22 as a `ThemeExtension`, the solid and dimmed chip looks, text styles, spacing, radii, sizes, borders, opacities, motion tokens, and the light/dark theme builders. Token groups live in `part` files so each stays small; there is still one import point.
- `lib/core/copy/app_copy.dart`: every user-facing string from the UI spec in one place, so wording changes are one edit.
- Bundled fonts (OFL, licenses kept next to the files): Inter variable (856 KB), Noto Sans Devanagari variable (627 KB), Instrument Serif (68 KB). About 1.5 MB added to the app; no runtime or battery cost. They are bundled instead of using `google_fonts`, which fetches fonts over the network.
- `test/architecture_test.dart`: fails when an import breaks the layer rules in ARCHITECTURE.md §5.
- `test/style_literals_test.dart`: fails on raw colors, `Colors.*`, `TextStyle(`, numeric `EdgeInsets`/radii/font sizes, `Curves.*`, and (in UI code) `Duration` literals outside `core/styles/`. Both checks were verified by planting a violating file.
- `test/core/styles/contrast_test.dart`: checks that every text/background pair meets 4.5:1 in both themes.
- `lib/app/app.dart`: minimal root that applies the light/dark themes and follows the system. Shows a blank page until Home exists.
- `docs/ARCHITECTURE.md`: folder tree, layer dependency rules, Riverpod for state, Drift/SQLite (FTS5) for the index database. Approved 2026-10-03.
- Architecture decisions recorded: a minimal note header (`id`, `created`, `tags`, `pinned`; no modified date), real subfolders, a notes folder the user can see, file names from creation time that are never renamed, and Obsidian-compatible link format `[[id|Title]]` if links are stored inline.
- Embedding size estimate now counts chunks, not notes. An early matching benchmark is planned for the embeddings stage.
- Git repository initialized on `main`.
- Note file format (`core/storage/files/`), the first part of the storage stage:
  - `NoteId`: `20261003-153228-a7f3` ids and file names.
  - `NoteDocument`: splits a file into header and body. Parse then serialize returns the exact original text, including Windows line endings.
  - `NoteHeaderCodec`: reads and writes `id`, `created`, `tags`, `pinned` while keeping other header lines (for example Obsidian's `aliases`) untouched. Absent defaults aren't added, Hindi tags aren't quoted, and a leading `---` block that isn't valid YAML stays in the body.
  - `NoteText`: the title is the first line without heading marks. The content hash is SHA-256 over the body with line endings normalized, so pin or tag changes never trigger re-analysis.
- `NoteFileStore` interface and `IoNoteFileStore` (plain files for the holding folder, desktop and tests). Writes go to a temp file and are then renamed, so a crash never leaves a half-written note. Hidden folders such as `.obsidian` and `.trash` are skipped, and paths outside the notes folder are refused.
- 29 tests for the above.
- Index database (`core/storage/db/`), using Drift and SQLite in app-private storage:
  - A notes table with indexes for the queries the UI runs (recent, by id, by folder).
  - Confirmed tags.
  - An FTS5 keyword index kept in sync by triggers. Verified to prefix-match Hindi (`कहा` finds `कहानी`) and English.
- `NotesRepository`: create, edit, pin, tag, trash, restore and search.
  - Every change lands in the database at once; the file is written a moment later by `NoteWriter`.
  - A revision counter makes sure an edit made during a file write is never lost.
  - Headerless notes stay headerless until the first pin or tag.
- `NoteWriter`: never overwrites a file that changed elsewhere. It marks the note as in conflict and keeps both versions.
- `NoteIndexer`: reconciles the folder with the database on start and on resume.
  - Skips unchanged files without reading them (same time and size).
  - Detects outside moves by header id, then by content hash, and treats renames that only change letter case as the same note.
  - Removes deleted notes but keeps unsaved ones.
- First working app:
  - **Home:** wordmark and greeting, pinned row, two-column grid of note cards with fading previews, the empty state "Write your first thought.", a floating "New note" pill, and the bottom fade.
  - **Note screen:** one plain text field whose first line shows in the title style (the keyboard's composing underline is kept for Hindi input). Keyboard up for new notes, autosave a moment after typing stops (no save button), and a fading "saved" tick.
  - **Actions:** pin, and Delete in the ⋮ menu, which moves the note to `.trash/` with an Undo snackbar instead of a confirmation dialog.
  - **Lifecycle:** unsaved text is written to files when the app goes to the background; outside changes are picked up on resume.
  - **Storage location:** notes currently live in the app-private holding folder (the "Not now" path) until the folder picker is built.
- New shared widgets: `PillButton`, `NoteCard`, `FadingText`, `SectionLabel`, `EmptyState`. New tokens: card sizes, bottom fade, saved-tick hold, undo window, snackbar theme.
- Tests: 83 in total.
  - Repository, indexer and editor controller (on in-memory SQLite and fake files).
  - Dates and greeting.
  - Widget tests for the empty Home and for write → back → note on Home with mixed Hindi and English.
- Dependencies:
  - `drift` 2.35.1 and `drift_flutter` 0.3.1: the index database; runs on a background isolate.
  - `sqlite3` 3.5.2, pulled in indirectly: bundles SQLite, compiled for each platform. Adds native code to the APK; the size change will be measured with the first release build.
  - `path_provider` 2.1.6: the app-private folder.
  - `flutter_riverpod` 3.4.3: state.
  - `go_router` 18.0.2: routes and later deep links.
  - `characters` 1.4.1: safe preview cuts.
  - Dev only: `drift_dev` and `build_runner`.
  - None of these run work in the background on their own; there's no polling and no wake locks.
- Dependencies, all pure Dart from the Dart team: `yaml` 3.1.4 (reads headers written by other apps; parsed only when a file is indexed), `crypto` 3.0.7 (SHA-256, run once per save), `path` 1.9.1 (already present indirectly). Their effect on app size is expected to be small but hasn't been measured yet; it will be logged with the first release build. No native code, no background work, no battery impact.

### Changed
- Decided 2026-10-03: **Light-mode amber** is used only for fills, outlines and icons, where 3:1 is enough. Link labels use the normal text color, because `#B7791F` reaches only 3.4–3.6:1 as text. No second amber until a text use comes up. Added a 3:1 test for the accent. Product spec §22 updated.
- Decided 2026-10-03: **Dimmed chips:** the ~55% opacity applies to the dashed outline only, and the label stays full-strength secondary text so it passes 4.5:1. Product spec §22 and UI spec §7 updated.
- Decided 2026-10-03: **File names:** creation time plus a 4-character random suffix (`20261003-153228-a7f3.md`) instead of a `-2` rule, so two offline devices creating notes in the same second don't collide. Link format becomes `[[20261003-153228-a7f3|Time Loop]]`. ARCHITECTURE.md §8 and product spec §3 and §5 updated.
- Decided 2026-10-03: **Values chosen here, now approved:** border colors, wordmark 28, button label 15 medium, section label 12 semibold, swipe spring (mass 1, stiffness 400, damping 28) and tilt (0.14 rad). All live in `app_styles.dart`.
- Decided 2026-10-03: **Folder access on Android:** the system folder picker, not all-files access, because of Play Store restrictions and the minimum-permissions rule. The app uses its own small Kotlin bridge. Added onboarding screen 4 "Choose where your notes live" (UI spec §4) and the "On this phone only" state for Notes folder in Settings (UI spec §11). If permission is declined, notes stay in an app-private holding folder and writing is never blocked. ARCHITECTURE.md §8 and product spec §3 updated; copy added to `app_copy.dart`.
- Product spec §21: Markdown format and header fields are no longer open.
- Decided 2026-10-03: **Database in app-private storage**, because SQLite can't open files through the folder picker. It is an index rebuilt from the notes. `MyNotes/.app/` keeps only what must survive uninstall and sync:
  - Rejections: one append-only `rejections-<deviceid>.jsonl` per device, read by all devices, holding note ids and content hashes only.
  - Suggestions: not saved as files (rebuildable, 30-day expiry). Laptop suggestions arrive as files and are imported.
  - Settings: private.

  Product spec §3, §8 and §16 and ARCHITECTURE.md §4 and §8 updated.
- Decided 2026-10-03: **Note identity** is the header `id`, otherwise the path inside `Notes/`. Paths are compared case-insensitively for Windows. Outside moves are detected by `id`, then by content hash. A headerless note gets an `id` header only on its first pin, tag or link. Links use the file name, adding the folder path only when ambiguous. Product spec §16 and ARCHITECTURE.md §8 updated.
- ARCHITECTURE.md §5 rule 4: `core/storage/storage_services.dart`, which wires storage together once at start, may also use the database. The import test was updated to match.
- ARCHITECTURE.md §7: two proposals are built and awaiting confirmation. Trash goes to `Notes/.trash/` (Obsidian's convention). An edit made while the file changed elsewhere is marked as a conflict and nothing is overwritten.
- `main.dart` no longer holds the Flutter counter template; it starts `App`. Removed the template's counter test.
- App display name set to "Vera N" (Android label, README). The Dart package name stays `vera_n` because package names can't contain spaces.
- Version set to `0.1.0+1` in `pubspec.yaml` to match this changelog.
- Spec files renamed to `Vera_N_Product_Spec_v3.md` and `Vera_N_UI_Spec.md` to match the names used in CLAUDE.md and inside the specs.
- Border colors (`#2A2A2E` dark, `#E4E2DD` light) were picked here because spec §22 asks for a "thin subtle border" without giving a value.
