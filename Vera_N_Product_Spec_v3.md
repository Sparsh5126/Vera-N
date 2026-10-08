# Vera N — Product Spec v3

> **The app should remember the connections you forgot.**

Write naturally on your phone. The phone builds a basic semantic memory offline. The laptop deepens the understanding when available. AI discovers the organization. The user approves it.

This is a living document. Everything agreed so far is in here, including features that will not make the first build.

**Product name: Vera N.** *Vera* = truth or faith, *N* = Notes, and said together it sounds like *veeran*, "isolated" in Hindi: private, sealed, offline. Screen-by-screen UI, onboarding copy, and capture widgets are in **Vera_N_UI_Spec.md**; colors and typography are in section 22 of this file.

---

## 1. Core Philosophy

- **Capture with zero friction.** Open → write → close, on phone or laptop.
- **Write first, organize later.** No deciding folders, tags, or links at capture time.
- **Invisible AI.** No chatbox, no AI controls in everyday use. The AI works in the background; the user only reviews and confirms suggestions.
- **Everything local.** No cloud AI, no cloud storage, no account. Anything that leaves the device must be opt-in and clearly shown.
- **Never destroy the user's words.** The user's notes are the source of truth. AI output is separate, rebuildable metadata.
- **Phone is the product.** Obsidian already covers the desktop experience. The differentiator is instant phone capture plus quiet automatic linking.
- **Graph is secondary.** The main experience is writing and reading; the graph is an exploration tool.

---

## 2. Roles of the Devices

### Phone (primary)
- Instant-capture notes app (target: about one second from launch to typing).
- Full notes features: create, edit, read, delete/archive, search, pin/favorite, folders, tags, backlinks, attachments, formatting, offline use.
- Runs **embeddings on-device** (small model, e.g. MiniLM-class or EmbeddingGemma) so linking works offline with no laptop.
- No LLM on the phone. No chatbox anywhere.
- Runs analysis quietly while charging or idle.

### Laptop (booster, optional)
- Full notes app (Flutter desktop).
- Background process that watches the notes folder.
- Runs heavier LLM jobs through LM Studio when available: summaries, topic naming, clustering, deeper relationship analysis.
- Results sync back to the phone as separate metadata files.
- If the laptop is off for days, nothing breaks; the phone keeps working alone.

### Optional always-on AI box
- An old PC, mini PC, or Raspberry Pi can act as the AI machine instead of the daily laptop. Still fully local.

---

## 3. Storage Layout

```text
MyNotes/                              (user-visible folder, synced)
├── Notes/                            Markdown, source of truth; subfolders are folders
├── Attachments/
└── .app/                             only what must survive uninstall and sync
    ├── rejections-<deviceid>.jsonl   one append-only file per device
    └── (laptop output)               suggestions and metadata from the laptop, imported on arrival

App-private storage (per device, not synced, lost on uninstall)
├── database                          index, keyword search, embeddings, suggestions
└── settings
```

- On Android, `MyNotes/` is a user-visible folder the user picks with the system folder picker (for example `Documents/Vera N`), so notes survive uninstall and work with Syncthing and Obsidian. Until a folder is picked, notes are kept inside the app. Details in docs/ARCHITECTURE.md §8.
- Markdown files are canonical and portable (Obsidian-compatible). File names are stable and never renamed: creation time plus a 4-character random suffix, for example `20261003-153228-a7f3.md`.
- **The database lives in app-private storage**, because SQLite can't open a file inside a folder chosen through the system picker. It is an index: everything in it rebuilds from `Notes/` and `.app/`.
- **`MyNotes/.app/` holds only what must survive uninstall and sync:**
  - **Rejections:** each device appends only to its own `rejections-<deviceid>.jsonl`; every device reads all of them. Lines hold note ids and content hashes only, never note text. One file per device means sync never creates conflicts.
  - **Suggestions are not saved as files.** They are rebuildable and expire after 30 days. Suggestions made by the laptop arrive as files and are imported into the database.
- Settings stay in app-private storage.
- Changing or removing AI models never harms notes.
- **Attachments (built 2026-10-08):** photos, drawings and voice notes live in `MyNotes/Attachments/` as `<id>.<ext>` (the note id scheme). A note embeds one as a standard Markdown line, `![](Attachments/<name>)`, the path from `MyNotes/`, so Obsidian and other apps show it too.
  - Photos are shrunk to 2048 px and saved as JPEG at quality 80.
  - Voice notes are AAC in `.m4a`.
  - A drawing is one vector file, `<id>.drawing.svg` (changed 2026-10-08, user: "vector, so it never blurs"). Each line is a path, so it is sharp at any size and opens in any app; the app reads its own SVGs back to keep drawing.
  - Attachment files are the user's. Removing one from a note leaves its file. They are deleted only by the user's choice in Settings: "Remove unused attachments" (with Undo), or the optional automatic clean-up (off by default) of files in no note for 30 days.
  - The AI never reads attachments; their lines are left out of the text it analyzes.

---

## 4. AI Pipeline

### Phone (incremental embeddings)
1. Note saved or edited.
2. Content hash compared with stored hash. Unchanged → skip.
3. Wait until the user stops typing before processing.
4. Split long notes into chunks; embed only new or changed chunks.
5. Store the **embedding model name and version** with every embedding.
6. When the model changes, rebuild embeddings in the background.
7. Compare against existing notes; keep only **strong** matches.
8. Create dimmed suggestions with the reason attached.

Never re-embed the whole library for one change.

### Laptop (deeper layer, when available)
- Summaries, topic discovery, clustering, duplicate/overlap detection, knowledge-health data.
- Backend-agnostic: LM Studio by default; architecture allows Ollama, llama.cpp, or any OpenAI-compatible local server.
- Authenticated local endpoint; remembers trusted devices; handles the laptop disappearing gracefully.

### Design rule
Sync and AI are independent systems. Notes and sync work even if no AI is available.

---

## 5. Note Modification Rules

- AI **produces metadata, suggestions, summaries, tags**. It does not touch note content on its own.
- Any change to a note (for example inserting a `[[link]]`) happens **only after the user gives permission**.
- Changes are **additive only**. The AI never removes or rewrites anything the user wrote.
- AI never deletes notes, never merges notes without approval, never hides notes it considers irrelevant.
- Generated metadata is always visibly distinguishable from user-written content.

**Open decision: where accepted links are stored.**

- **Inline:** accepting a link writes it into the note's own Markdown file, for example `[[20261003-153228-a7f3|Time Loop]]` (file name plus display title, so it works in Obsidian). Pros: the link travels with the note, works in Obsidian, and survives even if app data is lost. Cons: it edits the user's file, and two devices editing the same note can create sync conflicts.
- **Sidecar:** the link is stored in the app's own metadata (a separate hidden file or database) and the note text is never touched. Pros: no edits to notes, no sync conflicts, easy undo. Cons: other apps cannot see the links, and they are lost if that metadata is deleted.

Key point: an approved link is a decision the user made, not something the AI can rebuild. The `.app/` folder is meant to be disposable, so approved links should not live only there.

**Decided 2026-10-04:** inline, in one dedicated footer block at the end of the note (for example a "Linked notes" list), written only after the user accepts and only ever appended to. A single append-only block keeps sync merges simple and respects the additive-only rule. Suggestions and rejections stay in `.app/`.

---

## 6. Relationships: Related vs Linked

| Term | Meaning |
|---|---|
| **Related** | The AI thinks two notes are connected. Suggestion only. |
| **Linked** | The user created the connection or approved the AI's suggestion. |

Relationship types:
- **Explicit:** user-made `[[links]]`.
- **Semantic:** related meaning even with different words.
- **Topic:** several notes around an emerging subject.
- **Temporal:** how an idea developed over time.

Every relationship records who created it (user or AI) and a confidence value.

---

## 7. Suggestion Lifecycle and Review UX

1. **Detected:** only strong matches pass the threshold; weak ones are dropped and never shown.
2. **Dimmed:** the match appears as a faded "suggested" tag or link on the note.
3. **Reviewed:** the home screen shows a **"New connections"** card (no number, so it never feels urgent). Open it to go through a batch of 5. Each card has three outcomes: **accept** (swipe right or ✓ button), **reject** (swipe left or ✕ button), **not sure** (swipe up or a "Not sure" button). Swipe down or an Undo button reverses the last choice.
4. **Resolved:** accepted → solid, confirmed link. Rejected → stored (see section 8). Not sure → stays dimmed and comes back in a later batch until it expires.
5. **Expired:** unreviewed suggestions disappear after **30 days**.

Rules:
- Never interrupt writing; suggestions are batched.
- High threshold at the start; loosen later based on accept rates.
- Plain human wording ("Looks related to your note on Time Loop"). No percentages, no technical terms.
- Suggestions are visible on notes only as dimmed items, never silently converted to real links.

---

## 8. Rejections and Learning

- Every rejected pair is stored so it does not reappear.
- Store a **content hash of both notes** with the rejection.
- Rejections are kept in `MyNotes/.app/rejections-<deviceid>.jsonl` (see section 3), so they survive uninstall and reach every device. Each device appends only to its own file and reads all of them.
- Rejections are not necessarily permanent: if either note changes substantially (about a third or more of its words, decided 2026-10-04), the pair may be reconsidered, but only if the new match is strong.
- Learning is simple: track the accept rate per suggestion type (link, tag, topic). If a type is rejected often, raise its threshold. No model training at first.
  - Built 2026-10-08: last 20 decisions per type; from 10 on, 70%+ rejected raises the bar 0.02 (cap +0.10), 80%+ accepted lowers it 0.02 (floor −0.04, so only strong matches still pass); the count restarts after each step. Device-local.

---

## 9. "Why Are These Related?"

- Default: a short line, e.g. "Looks related to your note on Time Loop."
- Tap to expand: the reasoning, with the matching ideas or passages highlighted in both notes.
- Requires chunk-level embeddings.

---

## 10. Resurfacing / Forgotten-Thought Suggestions

- The app can bring back old notes that have become relevant again ("You might want to revisit this").
- Appears as a **separate button on the homepage**. The user chooses whether to open it.
- No push notifications, no interruptions. (The only notifications the app ever sends are reminders a note asks for, §10a.)
- Possibly one of the most valuable features of the app.
- Built 2026-10-08 (decided by the user: old notes related to recent ones). During background analysis, a note changed in the last 7 days is compared with notes untouched for 30 days or more; its best strong match (the learned link bar) that is not already linked or offered becomes a `resurface` suggestion (old note, recent note). These never enter the Review batches, Home's dot, suggested-link chips or the Graph. Opening one removes it; "Not now" snoozes it for 30 days; it stays known meanwhile, so it is not offered again, and after that it can come back if the notes still match. Unopened offers expire after 30 days like other suggestions.

---

## 10a. Reminders a note asks for (built 2026-10-08, decided by the user)

- **Only when asked:** a line in a note containing "remind me" plus a date and a time still in the future sets a reminder. The app never sends a notification for anything else.
- **Understood on the phone with plain rules, in English:**
  - a time: "at 9 am", "9:30 pm", "17:00", "noon", "tonight";
  - a date: "today", "tomorrow", "day after tomorrow", a weekday ("Friday", "next Monday"), "12 Oct", "Oct 12", "12/10" (day first);
  - or a span: "in 10 minutes", "in 2 hours", "in 3 days".
  - Relative words count from when the note last changed, so reading the note later never moves the reminder.
  - A date with no time sets nothing, and the note says "Add a time, like 'at 9 am'". A past time sets nothing either.
- **The notes are the source of truth:** editing the line moves the reminder, and removing it, trashing the note or the time passing cancels it. Reminders are scheduled with Android's alarms; they survive a restart, and the boot receiver sets them again.
- **Notifications:**
  - The title is "Reminder" and the text is the line as written. On a locked screen only "Reminder" shows.
  - A note in the Locked folder shows "A note in your Locked folder", never its words.
  - Tapping a reminder opens its note.
- **Permissions:** notifications are asked for the first time a note has a reminder, never at install, and only once. Exact timing needs the user's permission on Android 14 (Settings → On-time reminders); without it a reminder may come a few minutes late.
- **Settings:** "Reminders from notes" sits in Smart Suggestions with the other automatic features, on by default. Off cancels every reminder.
- Nothing leaves the phone.

## 11. Tags, Folders, Topics

- **Folders:** created and managed by the user only. The AI never moves notes between folders.
- **Tags:** the AI may suggest tags; a tag becomes official only after user approval. The AI should reuse existing tags before inventing new ones, to avoid near-duplicates. Tags are another way to browse and filter. In the note view, confirmed tags show as solid chips and AI-suggested tags show as dimmed chips in the same Tags row until approved.
- **Topics:** the AI can discover themes and emerging subjects, but never auto-creates folders or moves notes.

---

## 12. Graph

- Secondary exploration tool, not something the user has to maintain.
- Default view: **confirmed Linked** relationships only.
- Option to show AI suggestions (visually distinct).
- Can include topics, clusters, people, projects, and concepts.
- Must be useful even if the user never creates a manual link.

---

## 13. Knowledge Health (internal)

Tracked internally as a foundation for future features, not as a dashboard the user manages:
- Notes with no connections
- Highly connected notes
- Duplicate or overlapping notes
- Old notes worth resurfacing
- Unreviewed suggestions
- Growing topics

---

## 14. Sync

- Start with **Syncthing** between phone and laptop instead of building custom sync.
- Use **Tailscale** (or similar) for syncing away from home Wi-Fi, so there is still no cloud copy.
- Later option: built-in device pairing via QR code and local-network discovery.
- Sync never silently overwrites notes. On conflict, show both versions with Compare / Keep Phone / Keep Desktop / Merge.
  - Built on the phone 2026-10-08 for any outside change (another app or a synced copy): Compare, Keep this version, Keep the other version, and Keep both (the other version becomes its own note, the phone's merge). A true line-by-line merge is not built.
- Keep note version history so recovery is possible.
- Optional encrypted relay in the long term.

---

## 15. Privacy Model

Defaults: notes stored locally, AI processing local, no account, no cloud storage, no AI subscription, device-to-device sync, portable files.

Cloud sync or cloud AI, if ever added, must be opt-in and clearly show when data leaves the device.

**Locked folder (built 2026-10-08; decided by the user: an app lock, the phone's own lock, one folder).** Notes moved into `Notes/Locked/` (keeping their folder inside, like Archive) are private inside the app:
- **Never touched by the AI:** no analysis, suggestions, tag suggestions, Revisit or meaning search. Locking a note deletes its stored passages, vectors, analysis record and suggestions, and every analysis run first forgets any note found in `Locked/` (moved there by another app). Taking a note out lets the AI read it again.
- **Hidden** from Home, Search, the Graph, the folder and tag lists, the link picker and the Linked / Mentioned-in lists of open notes (a locked note may still list open ones). In the trash it shows as "Locked note", without its words.
- **Opening it** needs the phone's lock (fingerprint, face, PIN or pattern) through the system prompt. Once open, the folder stays open while the app is in use, and closes when the app has been away for more than 30 seconds, or with "Lock now". A phone without a screen lock can't lock notes, so a note can never get stuck.
- **Not encryption:** the files stay plain Markdown, so Obsidian and sync keep working, and anyone with a file manager could read them. This was the user's choice.

---

## 16. Data Model

**Note:** id, path, title, content, createdAt, modifiedAt, contentHash, folder, tags, pinned, attachments

- **Note identity:** the header `id` when present, otherwise the path inside `Notes/`. Paths are compared case-insensitively (the laptop may be Windows).
- A headerless note (for example an imported one) gets an `id` header only the first time the user does something that must persist (pin, tag, link). Never before.
- Moves and renames done outside the app are detected by matching the content hash when one path disappears and a new one appears.
- Links use the file name, adding the folder path only when the name is ambiguous.

**Chunk embedding:** noteId, chunkId, embedding, embeddingModel, modelVersion, contentHash

**Relationship:** id, sourceNoteId, targetNoteId, type, status (suggested / linked), confidence, createdBy (user / AI), createdAt

**Suggestion:** id, kind (link / tag / topic / resurface), reason, matchedPassages, status, createdAt, expiresAt (30 days)

**Rejection:** pairKey, noteA, hashA, noteB, hashB, rejectedAt, deviceId (stored as one JSON line per rejection; no note text)

**Topic:** id, name, description, noteIds, createdAt, updatedAt

**AI metadata:** noteId, summary, topics, entities, lastAnalyzedAt, modelVersion

---

## 17. Phone Home Screen

Summary (full layout in Vera_N_UI_Spec.md): app name and greeting, then two cards side by side ("new connections" and "Revisit", shown only when active), a Recent | Folders | Tags switch, pinned notes, then note cards in a grid (default) or list. A pill-shaped New note button floats above a pill bottom bar (Home | Search | Graph | Settings). The app opens on Home by default; a setting can open it straight to a new note.

---

## 18. Example

Phone note: "Maybe the protagonist receives a message every night at 2:17 AM."

Days later: "Maybe the messages aren't predicting the future. They're causing it."

The phone detects a strong match and shows a dimmed suggestion. In the review batch the user sees both notes, the highlighted matching ideas, and swipes to accept. The link becomes confirmed.

---

## 19. Full Feature List (nothing dropped)

**Phone and desktop:** create, edit, read, delete/archive, search, recent, pin/favorite, folders, tags, backlinks, attachments, formatting, manual linking, offline use, basic graph.

**AI (invisible):** on-device incremental embeddings, semantic search, related-note detection, link suggestions with "why", suggested tags (approval required), topic discovery, duplicate/overlap detection, summaries (laptop), clustering (laptop), resurfacing, rejection learning, suggestion expiry, internal knowledge-health data.

**Later:** voice-to-note, image understanding, PDF ingestion, lecture/meeting notes, timeline view, idea-evolution tracking, daily/weekly review, project workspaces, custom local models, encrypted remote sync, import from Obsidian / Apple Notes / Keep / Notion.

---

## 20. Risks to Test Early

1. **Phone embeddings on mid-range Android:** speed, battery, memory. Everything depends on this; test in week one.
2. **Suggestion quality:** if the first week of suggestions feels random, users stop reviewing. Start strict.
3. **Sync conflicts** with Markdown files edited on two devices.
4. **Chunking and highlighting** for "why" explanations on long notes.
5. **Link storage decision** (inline `[[link]]` vs sidecar).

---

## 21. Open Decisions

- Logo and app icon final artwork (direction: dark rounded square, serif V, one amber dot).
- ~~Where accepted links are stored.~~ Decided 2026-10-04: inline, in one append-only "Linked notes" footer block at the end of the note (section 5).
- ~~Which on-device embedding model to start with.~~ Decided 2026-10-04: paraphrase-multilingual-MiniLM-L12-v2 (int8), trimmed to English + Hindi and bundled; benchmarked on a mid-range phone (Snapdragon 778G). Details in docs/ARCHITECTURE.md §8.
- ~~Similarity thresholds for "strong" at launch.~~ Decided 2026-10-04: cosine ≥ 0.60, tuned later from accept rates (section 8).
- ~~How "substantial change" is measured when reconsidering rejected pairs.~~ Decided 2026-10-04: about a third or more of either note's words changed since the rejection (estimated from a word fingerprint kept in the private database, no note text), and the match is still strong.
- Capture-screen details (launch-to-typing target). Markdown format and header fields are decided in docs/ARCHITECTURE.md §8: `id`, `created`, `tags`, `pinned`.

---

## 22. Brand and Visual Design

**Mood:** calm, quiet, private. The interface stays out of the way of the user's words.

**Visual world (decided 2026-10-08, backlog #2 and #4):** a design annual's plate section. Notes are plates on uncoated stock ruled by hairlines; the user's words and everything they confirmed are ink; the only hue is a quiet periwinkle **seal** the AI uses to sign its suggestions. Flat: no gradients, glows, shadows or texture (also keeps typing fast). Dark is the same section printed on black stock, composed rather than inverted. Layout, shapes and fonts were unchanged by this decision. Chosen by the user over the alternatives on 2026-10-08; it replaces the earlier amber palette.

**Colors**

| Role | Dark | Light |
|---|---|---|
| Background (stock) | `#121315` | `#F5F4F6` |
| Card (plate), warmer than the stock | `#1C1B19` | `#FAF9F7` |
| Text (ink, never pure black or white) | `#ECEBE8` | `#16181A` |
| Secondary text | `#A2A2AA` | `#5C5E66` |
| Primary plate (primary action, chosen tab or filter, confirmed chips, caret) | `#ECEBE8` | `#16181A` |
| On the primary plate | `#121315` | `#F5F4F6` |
| Seal (AI marks only) | `#A7AAE8` | `#6266B0` |
| Soft seal (selected and matched text) | `#34365A` | `#DCDDF3` |
| Accept (bottle green) | `#6CBF96` | `#2D6A4F` |
| Reject (vermilion) | `#E8806F` | `#B4382D` |
| Hairline | `#393834` | `#C9C7C4` |
| Folder (Graph dots while a Folder filter is on; never text) | `#F2B84B` | `#B7791F` |

- Theme follows the system by default, with Dark and Light options.
- **Confirmed vs suggested:** confirmed links and tags are solid chips in the primary plate. AI suggestions use the same chip shape with no fill, a dashed seal outline, and a secondary-text label; the dashes keep at least 3:1 so the meaning never relies on color alone, and the seal never appears on anything the user confirmed.
- All text pairs meet 4.5:1 and all icons, seal marks and accept/reject at least 3:1 in both themes (measured 2026-10-08).
- Android widgets, the launch screen and shortcut icons mirror these values in `res/values*/colors.xml`.

**Typography**
- UI and notes: **Inter**, with **Noto Sans Devanagari** as fallback so Hindi text renders cleanly.
- Sizes: note title 22 semibold, body 16 (line height 24), card text 15, small text 12.
- Wordmark only: "Vera N" in a serif such as **Instrument Serif**, used on the Home header and onboarding.
- One font family for the app, no font setting.

**Shape and spacing**
- Cards radius 24; buttons, tabs, and the nav bar fully rounded (pill).
- Flat surfaces ruled by a 1px hairline, no shadows.
- 8-point spacing grid; tap targets at least 48.
- Line icons with rounded strokes, one consistent style.

**Motion**
- 200 ms ease-out transitions; springy card swipe in Review; no decorative animation.
- Respects the system "reduce motion" setting.

**App icon direction:** dark rounded square with a serif **V** and one small amber dot (the lone node, the "isolated" meaning).

**Accessibility:** text contrast at least 4.5:1, support for system text size, dimmed items always marked by more than color.

---

## 23. Quick Capture (outside the app)

Android home-screen widgets, a Quick Settings tile, and app-icon shortcuts all open a blank note with the keyboard up. They never show AI suggestions or counts. Full details are in Vera_N_UI_Spec.md.
