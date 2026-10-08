# Laptop version: plan

Drafted 2026-10-08. Nothing here is built yet. Product spec §2 ("Laptop (booster, optional)"), §5 ("Laptop (deeper layer)") and §14 (Sync) are the source; this plan turns them into phases.

## Decisions so far (user, 2026-10-08)

| Question | Decision |
|---|---|
| How notes travel | **Syncthing first.** The user installs it on both devices; it syncs `MyNotes/` (Tailscale when away from home). Vera N writes no network code. Laptop results travel as files in `.app/`. Built-in QR pairing comes later. |
| First scope | **Full notes app plus the AI booster**: the same app on the laptop with a desktop layout, and deeper analysis that runs while it is open. |
| First AI jobs | **All four**: new tag names, topics, a written "Why?", duplicates. |
| Platforms | **Windows first.** macOS and Linux later; most plugins already support them, but only Windows can be tested here. |
| AI server | LM Studio by default (product spec §5). Any OpenAI-compatible server on the same machine (Ollama, llama.cpp) also works. Never a cloud service. |

## What carries over as is

Checked 2026-10-08, from each package's platform list:

| Piece | Windows | Note |
|---|---|---|
| Database (Drift / SQLite) | yes | same schema, its own copy per device |
| On-device model (ONNX MiniLM) | yes | same model, so laptop and phone vectors match |
| Files (`IoNoteFileStore`) | yes | the picked folder is a plain path on the laptop |
| Notifications | yes | see the reminders question below |
| Locked folder (`local_auth`) | yes | Windows Hello |
| Voice (`record`, `audioplayers`) | yes | |
| Photos (`image_picker`) | gallery only | a file picker; no camera |
| Background work (`workmanager`) | **no** | replaced: analysis runs inside the app while it is open (phase L0) |

`core/` stays shared; the laptop adds a small `core/booster/` and a desktop layout. ARCHITECTURE.md rule 5 already keeps `core/ai` pure Dart for this.

## Phases

Each phase is one change: tests, phone check where it touches the phone, changelog, commit.

### L0. The app runs on Windows (foundation)
- **Notes folder:** onboarding and Settings pick the Syncthing-shared `MyNotes/` folder with the system folder dialog (`file_selector`). Notes live in `Notes/`, attachments in `Attachments/`, as on the phone.
- **Outside changes:** the app watches the folder while open (`Directory.watch`, debounced). Syncthing's edits reach the index within a second or two, with no polling.
- **Syncthing conflict files:** `x.sync-conflict-<date>-<device>.md` must **not** become new notes. Each one is read as the other version of `x.md` and shown with the existing Compare / Keep this / Keep the other / Keep both, then removed once settled. Syncthing's own `.stfolder` and `.stversions` are ignored, as dot folders already are.
- **Analysis on the laptop:** the same incremental analysis as the phone, run in-app when the computer is idle (no typing for a few minutes) and on mains power (battery state from `battery_plus`). It stops when either ends; no service runs when the app is closed.
- **Device id and rejections:** the laptop gets its own `rejections-<deviceid>.jsonl`, and every device already reads all of them, so a pair rejected on one device never returns on the other.
- **Window:** a sensible minimum size; the window size and position are remembered.
- **Tests:** a conflict file becomes a conflict, not a note; the watcher re-indexes; analysis waits for idle.

### L1. Desktop layout
- The same screens, laid out for a wide window when wider than a breakpoint. One adaptive shell, not duplicate screens (CLAUDE.md §5):
  - a sidebar with Home, Search, Graph, Review, Folders, Tags and Settings;
  - a note list and the open note side by side;
  - a wider Graph.
- **Keyboard:**
  - Ctrl+N new note, Ctrl+F search, Ctrl+K link to a note, Ctrl+B bold;
  - Ctrl+Enter accepts in Review and Delete rejects, beside the same buttons;
  - Esc closes sheets.
- **Mouse:** hover states; right-click on a card gives the same actions as long-press on the phone.
- The same styles file and shared widgets. Only layout tokens (sidebar width, two-pane breakpoint) are added.

### L2. The booster engine (`core/booster/`)
- **AI server client:**
  - Speaks the OpenAI-compatible chat API at `http://localhost:1234/v1` (LM Studio) by default.
  - **Only addresses on this computer are accepted** unless the user deliberately allows another of their own machines (the "always-on AI box", spec §2). A cloud URL is refused.
  - A connection test and model choice in Settings.
- **Job queue:**
  - Keyed by note content hashes, so a job reruns only when its notes changed (CLAUDE.md §8).
  - Runs while plugged in and idle; never while the user types; stops when the server goes away and resumes later.
  - The phone never waits on the laptop.
- **Results go to files:** `MyNotes/.app/laptop-<deviceid>.jsonl`, append-only, one line per result. Each line holds note ids plus the content hashes it was made from. The phone and laptop import them; a result whose note has since changed is dropped as stale.
- **The four jobs:**
  1. **Written "Why?"** For each waiting link suggestion: one plain sentence from the two matched passages ("Both notes plan a spring trek to Triund."). Stored per pair and hashes, and shown on the suggestion card. It follows the voice rules: plain words, never "Vera" speaking.
  2. **New tag names.** For a note, up to two short tag names that don't exist yet, in lower-case kebab form. A name too close to an existing tag is folded into that tag. Offered like today's tag suggestions, marked as new; approval required.
  3. **Topics.** Group notes whose vectors cluster tightly, then have the model name each group in two or three words. Offered as a topic card in Review ("These 6 notes are about *trek planning*"); see open question 1.
  4. **Duplicates.** Pairs above a very high similarity, which the model confirms say the same thing. Offered for review and never merged on their own; see open question 2.
- **Prompts:** short, one job each, with the note text sent only to the local server. Hindi and English allowed, and results keep the note's language.
- **Tests:** a fake server; stale results dropped; nothing is called when no server is running; non-local addresses are refused.

### L3. The phone shows laptop results
- It imports `laptop-*.jsonl` on start and when the folder changes (the same path as rejections).
- **New suggestion kinds:** `topic` and `duplicate`. Tags gain an `isNew` flag.
- **Display:** the written "Why?" shows under the matched passages, in the same dimmed / seal style (it is AI output).
- **Review:** topic and duplicate cards use the existing swipe card. Accept, reject and "not sure" are remembered and learned from per kind, as today.
- Laptop and phone suggestions for the same pair merge into one, keeping the laptop's sentence.
- Analysis on the phone needs no change.

### L4. Settings on both devices
- **Phone, "Laptop" row** (UI spec §11 said "pair, test, forget", which belongs to built-in pairing later). With Syncthing it reads "Last helped 2 h ago", or "Not connected", which is a normal state. Tapping it explains Syncthing in two lines.
- **Laptop:** an "AI on this computer" group with the server address (local), a connection test, the model, and the four jobs, each with its own switch.
- **Onboarding page 3** says "If you have a laptop, it can help with deeper analysis…". This phase makes that true.

### L5. Packaging for Windows
- An installer (MSIX or a signed zip), with the user's own application id (backlog).
- The model ships inside, as on the phone. Release size is measured and logged.
- No auto-update service: updates come from GitHub releases.

### Later
- Built-in pairing (QR code, local network) as an alternative to Syncthing.
- macOS and Linux builds.
- Summaries and knowledge-health data (spec §5).

## Open questions (to decide before the phase that needs them)

1. **What accepting a topic does** (L3). AI never moves notes between folders (CLAUDE.md §9). The options:
   - (a) add the topic as a **tag** on its notes (my suggestion: reversible, and visible in Obsidian);
   - (b) a separate "topics" view;
   - (c) both.
2. **What accepting a duplicate does** (L3). The options:
   - (a) **link** the two notes and mark them "same idea";
   - (b) also offer to move one to the trash, with Undo.
   Never merge their text.
3. **Reminders on the laptop** (L0). If both devices schedule a note's reminder, it rings twice. The options:
   - (a) the phone only (my suggestion);
   - (b) the laptop only while the phone is away;
   - (c) both.
4. **Laptop results sent to the phone** contain short AI-written text (topic names, "Why?" sentences) inside the user's own synced folder. That stays within "nothing leaves your devices", and the onboarding wording still holds. Confirm it fits.
5. **Which local model** to recommend in LM Studio for Hindi plus English on a typical laptop (picked by testing in L2; at least two candidates compared on the user's own kind of notes).

## Risks

- **Syncthing conflicts:** two devices editing one note produce conflict files; L0 must handle them before any real use.
- **Double work:** both devices analyse. Each device's suggestions stay in its own database; only rejections and laptop results travel, and suggestions for the same pair merge.
- **Quality:** local models vary. Every AI result stays a dimmed suggestion that needs approval, and the "Why?" sentence never replaces the matched passages.
- **Laptop disappears:** if the laptop is off for days, results stop arriving and the phone works alone (spec §2). Old laptop suggestions expire after 30 days like the rest.

## Order and size

L0 → L1 → L2 → L3 → L4 → L5. L0 and L2 are the largest. L3 is the only phase that changes the phone.
