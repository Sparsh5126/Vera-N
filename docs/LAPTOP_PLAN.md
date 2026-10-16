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

### L0. The app runs on Windows (foundation): done 2026-10-09, run on Windows the same day (folder dialog, watcher, onboarding; conflicts and idle analysis covered by tests, real Syncthing not yet)
- **Notes folder:** onboarding and Settings pick the Syncthing-shared `MyNotes/` folder with the system folder dialog (`file_selector`). Notes live in `Notes/`, attachments in `Attachments/`, as on the phone.
- **Outside changes:** the app watches the folder while open (`Directory.watch`, debounced). Syncthing's edits reach the index within a second or two, with no polling.
- **Syncthing conflict files:** `x.sync-conflict-<date>-<device>.md` must **not** become new notes. Each one is read as the other version of `x.md` and shown with the existing Compare / Keep this / Keep the other / Keep both, then removed once settled. Syncthing's own `.stfolder` and `.stversions` are ignored, as dot folders already are.
- **Analysis on the laptop:** the same incremental analysis as the phone, run in-app when the computer is idle (no typing for a few minutes) and on mains power (battery state from `battery_plus`). It stops when either ends; no service runs when the app is closed.
- **Device id and rejections:** the laptop gets its own `rejections-<deviceid>.jsonl`, and every device already reads all of them, so a pair rejected on one device never returns on the other.
- **Window:** a sensible minimum size (done: 400×600); the window size and position are remembered (moved to L5; done 2026-10-11 in the runner, see L5).
- **Tests:** a conflict file becomes a conflict, not a note; the watcher re-indexes; analysis waits for idle.

### L1. Desktop layout: done 2026-10-09 and checked on Windows (sidebar, two panes, Ctrl+N / Ctrl+F, Settings in a readable column)
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

### L2. The booster engine (`core/booster/`): code done 2026-10-09 and tested with a fake server; not yet tried with a real model (connection test and model choice in Settings move to L4)
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

### L3. The phone shows laptop results: built 2026-10-09 (tested; not yet seen with real laptop results)
- It imports `laptop-*.jsonl` on start, on resume, when the folder changes, and on the laptop after each booster run (`LaptopResultsImport`).
- **As built:**
  - A "Why?" sentence is set on the waiting link between the same two notes (`suggestions.detail`). Laptop and phone suggestions for a pair are one row, so they merge by themselves.
  - New tag names and topics are ordinary tag suggestions (decided 2026-10-09). A new name has no reason note (`noteB = noteA`); the card shows one note.
  - Copies are a new kind, `duplicate`, with Merge / Remove one / Not copies (decided 2026-10-09).
  - Each result is offered once (`imported_results`, schema 7): an expired or rejected one never returns. "Not copies" is the pair (id, `=other id`) in the rejections file.
  - Laptop suggestions don't move this device's learned match bars (`fromLaptop`): they never passed them. **This differs from the line above ("learned from per kind").**
  - The sentence uses the secondary text colour rather than a 55% fade, which could drop below 4.5:1 contrast.
- **Merge keeps the note with more text** (the older one if equal), and the card says which; "Remove one" lets the user pick either note. Confirmed by the user 2026-10-15 ("keep the larger note").
- Analysis on the phone needs no change.

### L4. Settings on both devices: built 2026-10-09 (tested; not yet tried with a real AI app)
- **Phone, "Laptop" row:** built here; removed 2026-10-16 (user) once built-in sync existed. "Your laptop last helped: Today" now shows in the "Sync with your laptop" row while paired (UI spec §11).
- **Laptop:** an "AI on this computer" group with the server address (local), a connection test, the model, and the four jobs, each with its own switch.
- **Onboarding page 3** says "If you have a laptop, it can help with deeper analysis…". This phase makes that true.

### L5. Packaging for Windows
- **Window placement: done 2026-10-11.** The runner (`windows/runner/window_placement.cpp`, no package) saves the size, position and maximized state when the window closes, under `HKCU\Software\Vera N\Window`: per-computer window state, never in the synced folder. A spot no monitor shows any more (an unplugged screen) falls back to the default. Checked on Windows: moved and resized, maximized, and off-screen.
- **Release size, measured 2026-10-11:** 92.4 MB unpacked (30 files), 47.9 MB zipped. The model is 42.8 MB of it (`model_int8.onnx`), then `flutter_windows.dll` 20.3 MB, `onnxruntime.dll` 11.8 MB, app code 8.6 MB. The model already ships inside: it is a Flutter asset.
- **Installer: done 2026-10-11 (user chose a setup .exe made with Inno Setup over a zip or MSIX).** `windows/installer/vera_n.iss`, built by `tool/build_windows_installer.ps1` (a release build, then Inno Setup 6), gives `build/installer/VeraN-Setup-<version>.exe`, 42.6 MB.
  - It installs for the current user only, with no admin prompt, in `%LOCALAPPDATA%\Programs\Vera N`. It adds a Start menu entry, and a desktop icon only if ticked.
  - Uninstalling removes the app and its window placement. It never removes the notes folder or the app's database (`%APPDATA%\com.example\vera_n`).
  - Checked 2026-10-11: silent install, the app runs, silent uninstall.
  - Unsigned, so SmartScreen says "unknown publisher" on first run. Signing needs a code-signing certificate (later).
  - The application id stays `com.example.vera_n` for now (user, 2026-10-11), and the installer's `AppId` GUID must never change.
- The model ships inside, as on the phone. Release size is measured and logged.
- No auto-update service: updates come from GitHub releases.

### S. Built-in sync (decided 2026-10-16, user): built and checked on the phone and the laptop 2026-10-16 (paired by typed words; notes synced both ways; QR scanning not yet tried on the phone)

"for him it should be just the vera n app settings not another app". Decisions: **A, Syncthing runs inside Vera N** (not Vera N's own sync protocol); pairing by **QR code and a word code**; on the phone a **mirror copy** (no "All files access").

What the user does: laptop Settings → "Sync with your phone" shows a QR code and six words; phone Settings → "Sync with your laptop" → scan or type them. After that nothing: notes, rejections and laptop results travel when both are on the same Wi-Fi and Vera N is open. Settings shows "Last synced" and Unpair.

- **S1. The engine** (`core/sync/`):
  - Ships Syncthing (MPL-2.0) inside the app: on Windows the official `syncthing.exe`; on Android the Android build from Syncthing-Fork (`libsyncthingnative.so`, made for Android's network and file rules), packed as a native library so it can run.
  - Vera N starts it only while open (and stops it a minute after leaving), with its own private home folder, a random API key, and the web page bound to 127.0.0.1 only.
  - Switched off: internet relays, global (internet) discovery, NAT port opening, usage reports, crash reports, automatic upgrades. Only local discovery on the user's own network stays on, so nothing goes through anyone else's server.
  - Vera N talks to it through its local API only; the user never sees it.
- **S2. Pairing:**
  - The laptop opens a pairing window of 5 minutes and shows a QR code (its device id, its local addresses and a one-time secret) and the same secret as six words (from a 2,048-word list: 66 bits).
  - With the words, the phone finds the laptop by a local broadcast that only someone knowing the secret can recognise.
  - The phone sends its device id to the laptop with a proof made from the secret (HMAC); the laptop answers with its own id and proof. Each adds the other and shares the notes folder. A wrong or expired code adds nothing.
  - QR scanning needs the camera, asked only when the user taps "Scan"; the words need no extra permission.
- **S3. The folder:**
  - Laptop: Syncthing shares the picked notes folder directly (`Notes/`, `Attachments/`, `.app/`).
  - Phone (mirror copy): Syncthing shares a private copy inside Vera N; Vera N copies changes both ways between that copy and the user's chosen folder, remembering what each side last had. A file changed on both sides keeps the folder's version and saves the other as a conflict copy, which the existing Compare / Keep screen handles.
- **S4. Settings and words:** "Sync with your laptop / phone", status ("Last synced: today, 5:40 pm" / "Waiting for your laptop on this Wi-Fi"), Unpair. Onboarding and the helper's text stop mentioning Syncthing; the phone's Laptop row was later folded into the sync row.
- **Permissions:** the Android app gains the network permission (any sync needs it; the engine only talks within the user's own network) and the camera (asked only when scanning). No extra permission was needed to receive the pairing reply on Wi-Fi. Windows asks once to allow Vera N through the firewall.
- **Size (measured):** about +12 MB packed per CPU type to the phone APK (27.5 MB installed on arm64) and +27.4 MB to the Windows install.

### Later
- Syncing away from home without the cloud (for example over Tailscale, which works already if the user has it).
- macOS and Linux builds.
- Summaries and knowledge-health data (spec §5).

## Decided 2026-10-09 (user)

1. **Topics become tag suggestions.** A topic the laptop finds is offered as a suggested tag (dimmed, dashed outline) on each of its notes, accepted or rejected per note like links. No separate topics view.
2. **Duplicates:** the Review card offers **Merge** or **Remove one**.
   - **Merge** adds to the kept note only the lines it doesn't already have (lines in both appear once), then moves the other to the trash, all with Undo. Text is only added, never rewritten.
   - **Remove one** moves the chosen note to the trash, with Undo.
3. **Reminders are a phone-only feature.** The laptop never schedules them; its note view and Settings don't show them.
4. **AI-written text** (topic names, "Why?" sentences) travelling in the user's own synced folder is fine.
5. **Model:** the user has **Gemma 4** in LM Studio on an external SSD, to plug in when L2 starts testing.

## Running a local model (measured 2026-10-15)

- Qwen 3.5 9B in LM Studio does all four jobs well at about 1 s per answer, once reasoning is turned off per request (the app does this).
- Load the model with a **context length of 4,096**: LM Studio's default reserved 18.9 GB on a 16 GB laptop and starved every other program; 4,096 reserved 7.0 GB. The app's prompts need at most about 1,500 tokens.

## Every kind of user (user, 2026-10-09)

"we also have to account the app for users who will have no local llm model on their laptop or their laptop isnt capable to run a llm model locally. also for users who will only use laptop or only use mobile app."

| User | What they get |
|---|---|
| Phone only | Everything on the phone today. No laptop results arrive, and nothing waits for or mentions them beyond onboarding page 3's "If you have a laptop…". |
| Laptop only | The full notes app with a local folder (no Syncthing needed), and on-device links, tags and Revisit from the same small model (it runs on any laptop). No reminders (phone-only). |
| Laptop without a local AI server, or too weak to run one | The same as "laptop only". The booster finds no server, does nothing, and says nothing: one refused local connection per idle spell, no error, no nagging. |
| Phone and laptop with a local AI server | Everything, including the four booster jobs. |

Rules that follow:
- The booster is an extra, never a requirement. No screen, empty state or copy may assume a phone, a laptop or an AI server exists.
- Laptop onboarding speaks of "this computer"; a phone appears only as "if you also use Vera N on your phone".
- L4: "AI on this computer" reads "Not set up" as a normal state, with a switch to turn the booster off completely (then not even the local check runs), and a short line on what it needs (a local AI app such as LM Studio, and a computer that can run it).
- L3: the phone shows laptop results only when they exist; with none, nothing on the phone changes.

## Risks

- **Syncthing conflicts:** two devices editing one note produce conflict files; L0 must handle them before any real use.
- **Double work:** both devices analyse. Each device's suggestions stay in its own database; only rejections and laptop results travel, and suggestions for the same pair merge.
- **Quality:** local models vary. Every AI result stays a dimmed suggestion that needs approval, and the "Why?" sentence never replaces the matched passages.
- **Laptop disappears:** if the laptop is off for days, results stop arriving and the phone works alone (spec §2). Old laptop suggestions expire after 30 days like the rest.

## Order and size

L0 → L1 → L2 → L3 → L4 → L5. L0 and L2 are the largest. L3 is the only phase that changes the phone.
