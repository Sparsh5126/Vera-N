# Changelog

All notable changes to Vera N are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- **Notes folder you can see (Android).** A Kotlin bridge (`NotesFolderBridge.kt`, `SafDocuments.kt`) uses Android's own folder picker and keeps the permission across restarts. No storage permission is requested. File work runs on one background thread, and each folder is listed with one query.
- `SafNoteFileStore`, plus `SwitchingNoteFileStore` so the app can change folders while running. `FolderAccess` keeps this testable without Android.
- **Choosing a folder** moves notes from the in-app holding folder into `<picked>/Notes/`. Notes already there (a reinstall or a synced folder) are kept and indexed. A same-named file with different text is never overwritten.
- **Access removed:** on start, if access to the folder is gone, notes are rewritten into the holding folder from the database. Nothing is lost.
- **Onboarding screen "Choose where your notes live"** (UI spec §4), shown on first launch on Android. *Not now* goes to Home; backing out of the picker stays on the screen.
- Settings table (database schema version 2, with a migration), storing the notes folder, the onboarding flag, and a random 8-character device id for `.app/` files.
- 14 new tests, 97 in total: folder choose, reconnect, access lost, name clash, migration from version 1, the onboarding screen, the empty-folder guard, restore of a missing file, and colons in note names.

### Changed
- UI spec §4: the folder screen now says "or make a new one such as "Vera N" in Documents", because Android's picker can't be pre-filled with a new folder name.
- The path check is shared by both file stores. Note names with `:` (for example `2:17 AM.md`) are allowed.

### Fixed
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
