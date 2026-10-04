# Changelog

All notable changes to Vera N are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
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
