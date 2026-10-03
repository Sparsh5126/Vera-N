# Vera N — Architecture

Status: **approved 2026-10-03** (architecture, Riverpod, Drift with FTS5, int8 embeddings, bundled fonts, import/style checks).

Sources of truth: `Vera_N_Product_Spec_v3.md` (behavior, data, privacy) and `Vera_N_UI_Spec.md` (screens, copy). This file only decides *how the code is organized*.

---

## 1. Guiding constraints (from the specs)

- Markdown files in `MyNotes/Notes/` are canonical. The database is an **index**, rebuildable from the files plus `.app/`.
- Everything AI-produced is separate metadata. Notes are only ever appended to, after user approval.
- Local actions are instant (no spinners); heavy work (embeddings) runs off the UI isolate, incrementally, and only when allowed.
- Phone first (Android). Desktop/laptop layer comes last and must reuse the same `core/`.

---

## 2. Folder tree

```text
lib/
├── main.dart                      bootstraps services, runs App
├── app/
│   ├── app.dart                   MaterialApp.router, themes, providers scope
│   ├── app_shell.dart             tab screens + floating pill nav bar
│   └── router.dart                route table (go_router)
├── core/
│   ├── styles/
│   │   └── app_styles.dart        THE styles file (colors, type, spacing, radii, motion, themes)
│   ├── copy/
│   │   └── app_copy.dart          all user-facing strings (microcopy)
│   ├── feedback/
│   │   ├── haptics.dart           named haptic events, respects system settings
│   │   └── motion.dart            reduce-motion aware helpers (durations come from app_styles)
│   ├── platform/
│   │   └── launch_channel.dart    capture entry points and startup timing (Android bridge)
│   ├── navigation/
│   │   └── routes.dart            route names/paths (features navigate by name, never import each other)
│   ├── models/                    plain immutable data: Note, Chunk, Suggestion, Rejection, Relationship, Topic
│   ├── storage/
│   │   ├── files/                 NoteFileStore: read/write Markdown, frontmatter parse, append-only footer
│   │   ├── db/                    Drift database, tables, DAOs, migrations
│   │   ├── repositories/          NotesRepository, SuggestionsRepository, SettingsRepository, ...
│   │   └── indexer/               keeps DB in sync with files (hash compare, rebuild)
│   ├── ai/
│   │   ├── embedder/              Embedder interface + on-device implementation (load, batch, release)
│   │   ├── chunking/              split notes into chunks, hash chunks
│   │   ├── matching/              vector math (int8/float16 cosine), thresholds, strong-match filter
│   │   ├── suggestions/           suggestion lifecycle: create, batch of 5, accept/reject/not sure, expiry
│   │   └── scheduler/             background work (charging/idle constraints), debounce after typing
│   └── utils/                     hashing, dates, debouncer, result types
├── features/
│   ├── onboarding/
│   ├── home/
│   ├── note/                      editor + note view + suggestion sheet container
│   ├── review/                    swipe stack container
│   ├── search/
│   ├── graph/
│   ├── settings/
│   └── capture/                   minimal fast-capture entry (widget/tile/shortcut target), if needed
└── shared/
    └── widgets/                   PillButton, NoteCard, SuggestionChip, SuggestionCard, SectionLabel,
                                   EmptyState, PillNavBar, ... (data + callbacks only)

test/
├── core/                          storage, matching, suggestion lifecycle (pure Dart, fast)
├── features/                      widget tests per screen
├── shared/                        widget tests for shared components
└── architecture_test.dart         enforces the import rules in section 5
docs/ARCHITECTURE.md
CHANGELOG.md
```

**Inside each feature folder:**

```text
features/home/
├── home_screen.dart               composes widgets only
├── state/
│   └── home_controller.dart       Riverpod notifier: reads repositories, exposes UI state
└── widgets/                       widgets used only by this feature
```

A widget moves to `shared/widgets/` the moment a second feature needs it.

---

## 3. State management: Riverpod (`flutter_riverpod`, no code generation)

**Why**
- Dependency injection and state in one tool: repositories, the database, and the embedder are providers, so tests swap them for fakes with `overrides` and no service locator.
- `AsyncValue` gives every screen designed loading / error / data states almost for free (UI rule: every screen has all three).
- Fine-grained `select` rebuilds help keep lists and the editor from rebuilding unnecessarily.
- No codegen keeps the build simple and the dependency list short.

**Alternatives considered**
- *Built-in `ChangeNotifier` + `InheritedWidget`*: zero dependencies, but we would hand-roll DI, disposal, and async states. More code, more bugs.
- *Bloc*: solid, but more boilerplate per feature; events add ceremony we don't need.
- *Provider*: predecessor of Riverpod, context-bound, weaker for testing and for non-widget code (background work).

**Rules**
- Controllers (`Notifier` / `AsyncNotifier`) live in `features/*/state/`. They call repositories; they never touch Drift or files directly.
- Widgets read controllers; they never call repositories.

---

## 4. Database: SQLite via Drift

**Why**
- **FTS5** full-text search built into SQLite: keyword search on the Search tab is instant and indexed.
- Typed queries, compile-time checked, with real migrations (the schema will grow: suggestions, rejections, topics).
- Embeddings stored as compact `BLOB`s (int8 or float16, per CLAUDE.md §8), with model name and version per row.
- Runs on a background isolate (`NativeDatabase.createInBackground`), so the UI thread never waits.
- In-memory database for fast unit tests.
- Same code on Android and desktop (laptop layer later).

**Alternatives considered**
- *sqflite (raw SQL)*: smaller API, but stringly-typed queries and hand-written migrations; Android/iOS only, which hurts the desktop layer.
- *Isar*: fast, but original maintenance stalled (community fork); no FTS5-quality text search.
- *ObjectBox*: has built-in vector search (HNSW), but adds a large native library and its own data model; vector search is unnecessary at personal-library scale (see below).
- *Hive*: key-value only; no queries or full-text search.

**Vector search**: brute-force cosine over int8 vectors in a background isolate. No vector-database dependency until measurements show we need one.

Size is counted **per chunk, not per note**: `notes × avg chunks per note × dims × bytes per value`.

| Library | Avg chunks/note | Dims | int8 | float16 |
|---|---|---|---|---|
| 5,000 notes | 3 | 384 | 5.8 MB | 11.5 MB |
| 5,000 notes | 10 (long notes) | 384 | 19.2 MB | 38.4 MB |
| 5,000 notes | 3 | 768 | 11.5 MB | 23.0 MB |

Plus a few bytes per chunk for the scale factor and ids. Scan time is an estimate until measured: **matching is benchmarked early** (synthetic int8 vectors at the sizes above, on a mid-range Android phone) as part of the embeddings stage, before suggestion logic is built on top. Results go in the changelog.

**What lives where**

| Data | Location | Rebuildable? |
|---|---|---|
| Note text, title (first line), folder (subfolder), header fields, accepted links* | `MyNotes/Notes/*.md` | — (source of truth) |
| Rejections | `MyNotes/.app/rejections-<deviceid>.jsonl`, one append-only file per device, ids and hashes only; also loaded into the database | — (user decisions) |
| Laptop suggestions and metadata | Arrive as files in `MyNotes/.app/`, imported into the database | Yes, by the laptop |
| Note index, FTS, content hashes, file times | Database in app-private storage | Yes, from files |
| Chunk embeddings | Database (BLOB) | Yes, by re-embedding |
| Phone suggestions | Database only (expire after 30 days) | Yes |
| Settings (theme, layout, name), device id | App-private storage | No — small, per device |

The database can't live in `MyNotes/.app/`: SQLite can't open a file through the folder picker's content URIs.

\* Pending the open link-storage decision.

---

## 5. Dependency rules

```text
app  ──►  features  ──►  shared/widgets  ──►  core/{styles, copy, feedback}
  │           │
  │           └──────►  core/{models, storage/repositories, ai/suggestions, navigation}
  └──────────────────►  core/*
```

1. **features never import other features.** Navigation goes through route names in `core/navigation/routes.dart`.
2. **shared/widgets** import only `core/styles`, `core/copy`, `core/feedback`, `core/models`. They take data and callbacks, never repositories or providers.
3. **core never imports features, shared, or app.**
4. **core/storage/db** (Drift) is imported only by `core/storage/repositories`, `core/storage/indexer`, and `core/storage/storage_services.dart` (which wires storage together once at start). Everything else sees repositories and `core/models`.
5. **core/ai** depends on repositories and models, never on Flutter widgets. Pure Dart where possible, so it can run in isolates and on the laptop.
6. **Styling values only from `app_styles.dart`; strings only from `app_copy.dart`.**
7. **Haptics only through `core/feedback/haptics.dart`.**

Rules 1–4 are enforced by `test/architecture_test.dart`, which scans `import` lines and fails on a violation. Rule 6 is backed by a literal check (`Color(0x`, `EdgeInsets.all(<number>`, `Duration(milliseconds:`, `TextStyle(` with literals) outside `core/styles/`, run as part of the tests.

---

## 6. Other key choices

| Concern | Choice | Reason |
|---|---|---|
| Routing | `go_router` (Flutter team package) | Deep links for widgets, tile, and app-icon shortcuts ("open new note") need URL-style routes. |
| Isolates | Drift background isolate; embedding and matching in a separate short-lived isolate | Keeps typing and scrolling at 60 fps. |
| Background work | OS-scheduled work with charging/idle constraints (e.g. `workmanager`), added at the embeddings stage | CLAUDE.md §8: no polling, no wake locks. |
| Fonts | Bundled font assets (Inter, Noto Sans Devanagari, Instrument Serif), not `google_fonts` | `google_fonts` fetches over the network by default; the app must never go online. |
| Models | Hand-written immutable classes with `copyWith` | Avoids `freezed` codegen until the model count justifies it. |

Each package is logged in `CHANGELOG.md` with size and battery impact when it is actually added, not before.

---

## 7. Open decisions (not decided here)

From the specs — **blocking the stages noted, not the architecture**:

1. **Accepted-link storage**: inline footer block vs sidecar. Blocks: Review/accept logic.
2. **On-device embedding model** (MiniLM-class vs EmbeddingGemma, and runtime: TFLite vs ONNX Runtime). Blocks: embeddings stage. Needs a week-one benchmark on a mid-range Android phone.
3. **Similarity thresholds** for "strong". Blocks: suggestions stage.

Raised by the storage stage — **built as proposed, easy to change; please confirm**:

4. **Trash location.** Deleting moves the file to `Notes/.trash/` (the folder Obsidian also uses), so a deleted note survives uninstall and syncs as deleted. The database keeps it as trashed; it is purged after 30 days.
5. **Edit while the file changed elsewhere.** If a note has an unsaved edit and its file changed on disk (for example via Syncthing), the app never overwrites the file. It marks the note as in conflict and keeps both versions until the conflict screen from product spec §14 exists.

---

## 8. Decided

**Note file format** (decided 2026-10-03)
- Header (YAML frontmatter) is minimal: `id` (stable), `created`, `tags`, `pinned`. No modified date: modified time comes from the file time and the database, so edits never rewrite the header.
- Folders are real subfolders inside `Notes/`.
- The title is the first line of the note.
- Notes **without a header** (for example imported ones) are fully supported. They are tracked in the database. The `id` header is added only the first time the user does something that must persist (pin, tag, link), never before. Editing the text of a headerless note writes the text and still adds no header.

**Note identity** (decided 2026-10-03)
- Identity is the header `id` when present, otherwise the path inside `Notes/`.
- Paths are compared case-insensitively (the laptop may be Windows): the database keeps a lower-cased path key with a unique index.
- Moves and renames done outside the app: when the indexer sees a path disappear and a new one appear, it matches them by header `id`, then by content hash, and keeps the same note (its suggestions and rejections follow it).
- Links use the file name, adding the folder path only when the name is ambiguous.
- When a headerless note is adopted, it gets a newly generated id in the usual form (`20261003-153228-a7f3`). Its file is never renamed, so for these notes the id and the file name differ. `created` is taken from the file's modified time, the best date available.

**Database location and `.app/`** (decided 2026-10-03)
- The database lives in app-private storage; it is an index and rebuilds from `Notes/` and `.app/`.
- `MyNotes/.app/` keeps only what must survive uninstall and sync. Rejections: one append-only `rejections-<deviceid>.jsonl` per device, read by all devices, holding note ids and content hashes only, never note text. Suggestions are not saved as files; laptop suggestions arrive as files and are imported. Settings stay private.

**Notes location** (decided 2026-10-03)
- A user-visible folder, not app-private, so notes survive uninstall and work with Syncthing and Obsidian.
- The UI never scans the folder. The database is the index; reconciling with the folder happens in the indexer, off the UI.

**Folder access on Android: system folder picker** (Storage Access Framework, decided 2026-10-03)
- One folder, picked by the user, permission kept across restarts. No all-files access (Play Store restrictions, privacy).
- A small Kotlin bridge in the app (no third-party plugin) does the few calls needed: pick folder, list a folder in one query (name, modified time, size), read, write, create, delete. Dart's `File` API can't use these folders.
- Writes: the editor saves to the database instantly; the file is written in the background shortly after. A pending-writes list finishes any unwritten file on the next start.
- Outside changes (Syncthing, Obsidian): no change notifications on these folders, so the indexer compares one folder listing against the database on app resume, off the UI.
- First launch: onboarding screen "Choose where your notes live" (UI spec §4). Declined, cancelled, or later revoked: notes are kept in an app-private holding folder, writing is never blocked, and Settings → Notes folder offers to choose a folder and move the notes.
- `NoteFileStore` is an interface with two implementations: folder picker (Android) and plain files (holding folder, desktop, tests). `SwitchingNoteFileStore` forwards to whichever is current, so nothing else changes when the user picks a folder.
- **Built (2026-10-03):** `NotesFolderBridge.kt` and `SafDocuments.kt` on channel `vera_n/notes_folder`, with all file work on one background thread. Each folder is listed with one query (name, type, time, size). Files are written in place with truncate mode (`wt`); unlike the plain-file store, this is not atomic, because the system picker has no rename-over. Moves are done as copy then delete, which every provider supports.
- **Choosing a folder** flushes pending writes, then moves every note from the current folder into the picked folder's `Notes/` subfolder and points the database rows at the new files. Notes already in the picked folder are kept and indexed. A same-named file with different text is never overwritten: the moved note gets a 4-character suffix.
- **Access removed** (detected on start): the app switches back to the holding folder and rewrites every note there from the database, so nothing is lost.
- **Folder unavailable:** if the folder lists as empty while more than one note was indexed, the indexer removes nothing.
- The chosen folder, the onboarding flag, and the device id live in a `settings` table (schema version 2) in the private database.

**Note colors** (decided 2026-10-03)
- Light-mode amber is used only for fills, outlines, and icons; text uses the text colors. Dimmed chips: dashed outline at about 55%, label at full-strength secondary text.

**File names** (decided 2026-10-03)
- Stable: local creation time plus a 4-character random suffix, `20261003-153228-a7f3.md`. Never renamed.
- The suffix (4 lowercase hex characters from a secure random source, 65,536 values) avoids collisions when two devices create notes in the same second while offline. If a name still exists on the device, a new suffix is drawn.
- For notes created in the app, the header `id` equals the file name without `.md` (adopted imported notes differ; see Note identity).
- If inline links are chosen later, they are written as `[[20261003-153228-a7f3|Time Loop]]` so they keep working in Obsidian.
