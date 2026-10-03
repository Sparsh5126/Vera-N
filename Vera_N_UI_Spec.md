# Vera N — UI Spec v1

Companion to **Vera_N_Product_Spec_v3.md**. That file covers architecture and AI behavior; this one covers the name, onboarding, every screen, and interaction rules.

---

## 1. Name

**Vera N**

- **Vera:** truth or faith (Latin *verus*; Russian/Slavic *vera*). Notes that are honestly yours.
- **N:** Notes.
- **Said together, "veeran":** isolated in Hindi. Sealed off, private, offline.
- Also echoes *veer* ("brave") in Sanskrit-rooted languages.

Caution: in everyday Hindi, *veeran* often means deserted or desolate. Onboarding steers toward the "isolated by design" reading.

Tagline options: "Truth, kept close." / "Isolated by design." / "Your thoughts. Nowhere else."

Voice rule: the app never speaks as "Vera". The AI is invisible, so wording stays neutral ("Looks related to your note on Time Loop").

To check before launch: Play Store, domain, and trademark for both "Vera N" and "Veeran".

---

## 2. Design Principles

1. **Zero friction capture.** Writing is always one tap away.
2. **Invisible AI.** No chat, no AI controls in daily use. The AI works quietly and the user only confirms.
3. **Dimmed = AI suggestion, solid = confirmed.** Used everywhere, consistently.
4. **No pressure.** No notification-style badges, streaks, counts that nag, or maintenance prompts.
5. **While typing, only the user's words are on screen.**
6. **Gestures always have a visible button alternative**, with no setting to toggle them.
7. **Soft, rounded, card-based look.** Pill-shaped buttons and navigation.
8. **Plain language.** No technical words ("embedding", "similarity score", percentages).

---

## 3. Navigation

Floating pill bottom bar: **Home | Search | Graph | Settings**

- A pill-shaped **New note** button floats just above the bar, bottom right.
- A soft fade at the bottom of scrolling content keeps cards from clashing with the floating controls; scroll areas get bottom padding so the last card is never hidden.
- The bar hides while writing a note.
- Theme: **follows system by default**; options for Dark and Light. Accent color is amber; colors, typography, shape, and motion are defined in section 22 of Vera_N_Product_Spec_v3.md.

---

## 4. Onboarding

Shown once, on first launch. Plain language, no jargon. Draft copy below (all claims must be true at launch).

**Screen 1: Private by design**
> **Vera N**
> Notes that stay yours.
> Built for privacy. Your notes live on your phone. No account, no cloud, no one else reading them.

**Screen 2: What it does**
> Just write.
> Vera N quietly notices when your notes connect and suggests links and tags. Nothing changes unless you say yes.

**Screen 3: How it works**
> The thinking happens on your phone.
> If you have a laptop, it can help with deeper analysis over your own devices. We have no servers that see your notes.

**Screen 4: Notes folder**
> Choose where your notes live.
> Pick a folder on your phone, or make a new one such as "Vera N" in Documents. Your notes are saved there as plain files you can open in other apps, and they stay even if you remove Vera N.
> ( Choose folder )  (Not now)

- "Choose folder" opens Android's own folder picker at Documents. The picker can't be pre-filled with a new folder name, so the text above suggests making one; the picker has its own "new folder" option. The storage root and Download root can't be picked on Android 11+, so a subfolder is always used.
- Backing out of the picker returns to this screen, where both choices stay available.
- Until screens 1–3 and 5 are built, this is the only onboarding screen shown on first launch (Android only).
- "Not now", or backing out of the picker, never blocks writing: notes are kept inside the app until a folder is chosen. Settings shows this under Notes folder (see section 11).

**Screen 5: Name prompt**
> What should we call you?
> [ name field ]  (Skip)

- Name is optional. If skipped, the greeting is just "Good evening".
- Short, skippable, no tutorials beyond this.
- A one-time gesture hint appears the first time the Review screen opens (see section 6).

---

## 5. Home

```text
┌─────────────────────────┐
│ Vera N                  │
│ Good evening, Sparsh    │
│                         │
│ ┌─────────┐ ┌─────────┐ │
│ │ 5 new   │ │ Revisit │ │
│ │ connect.│ │         │ │
│ └─────────┘ └─────────┘ │
│                         │
│ (Recent)(Folders)(Tags) │
│                         │
│ Pinned                  │
│ ┌──────┐ ┌──────┐ ┌─    │
│ │ 📌   │ │ 📌   │ │     │
│ └──────┘ └──────┘ └─    │
│                         │
│ ┌─────────────────────┐ │
│ │ Title          Today│ │
│ │ Preview text...     │ │
│ └─────────────────────┘ │
│        ( + New note )   │
│  (Home Search Graph ⚙)  │
└─────────────────────────┘
```

**Header**
- App name and greeting on a compact area. The header collapses as you scroll down.
- No search bar on Home (the Search tab covers it).

**Suggestion cards (top row)**
- Two rounded rectangular cards side by side: **connections** ("5 new connections") and **Revisit**.
- If only one is active it takes the full width. If neither is, the row is hidden.
- Revisit is silent: no notification, the user opens it by choice.

**View switch:** thin rounded pills **Recent | Folders | Tags**. Recent is the default. Folders and Tags swap the notes area to folder or tag pills and their notes.

**Notes area**
- Pinned notes first, as cards with a small pin icon (horizontal row).
- Remaining notes as scrollable cards.
- **Layout setting:** two-column grid (default) or single-column list.
- Cards: text top-aligned, optional title first, long text fades out. A small dimmed dot on a card means that note has pending suggestions (no numbers).

**Empty state (first launch):** a blank page with "Write your first thought" and the New note button.

**Capture shortcuts (Android, outside the app)**

Purpose: the fastest possible route to a blank note. All entry points open a new note with the keyboard up, regardless of the "Open app to" setting. None of them ever show AI suggestions, counts, or badges.

*1. Home-screen widgets* (native Android app widgets; a Flutter helper such as `home_widget` can connect them to the app)
- **Quick note bar (4x1):** a pill reading "Write a thought…" with a small amber plus. Tapping anywhere opens a blank note. The main widget.
- **New note button (2x1 or 2x2):** one large amber plus and the label "New note". For people who prefer a compact tap target.
- **Recent notes (4x2), later version:** the last three note titles (titles only, no previews) plus a new-note button. Titles only, because a home screen can be seen by others. Tapping a title opens that note.
- Style: follows the system theme, same card color and radius as the app, wordmark not shown.
- Works fully offline, with no loading state.

*2. Quick Settings tile*
- Label "New note" with the app's plus icon. Tapping closes the shade and opens a blank note.
- On a locked phone, the user must unlock first. Capture never bypasses the lock screen, since notes are private.

*3. App-icon long-press shortcuts*
- **New note** (always first), **Search**, and **Review connections** (shown only when suggestions are waiting).

*Adding them:* the app does not nag. Settings has a **Quick capture** row that opens a short page with "Add widget" and "Add Quick Settings tile" buttons, using Android's own add prompts. Nothing is added automatically.

*Speed target:* from tapping a widget, tile, or shortcut to a typing cursor in about one second. If a cold Flutter start is too slow, add a minimal capture entry point that loads only the editor. Notes created this way are saved immediately and analyzed later, as usual.

**Settings option:** "Open app to" → Home (default) or New note.

---

## 6. Review Screen

Full-screen page (not a bottom sheet), opened from the "new connections" card.

```text
┌─────────────────────────┐
│ ✕          ● ○ ○ ○ ○    │
│                         │
│ NEW · Today             │
│ Future Self             │
│ "...the messages aren't │
│ [predicting the future] │
│ They're causing it."    │
│                         │
│   ↕ Both are about      │
│   messages that shape   │
│   events.   Why? ▾      │
│                         │
│ OLDER · Sep 21          │
│ 2:17 AM                 │
│ "...the protagonist     │
│ [receives a message]    │
│ every night."           │
│                         │
│  ✕    Not sure    ✓     │
│         ↶ Undo          │
└─────────────────────────┘
```

**Layout:** one card at a time, two notes stacked with the matching passage highlighted, a one-line plain-language reason between them, and "Why?" to expand the full reasoning. Progress is five small dots, not a number.

**Gestures**
| Gesture | Action |
|---|---|
| Swipe right | Accept |
| Swipe left | Reject |
| Swipe up | Not sure (stays dimmed until it expires) |
| Swipe down | Undo last swipe |

**Buttons:** ✕ (reject), **Not sure**, and ✓ (accept) in one row, with a small Undo below. All are always visible; no setting to hide them. Each button does exactly what its swipe does.

**Feedback**
- Card tilts and shows a faint green ✓ or red ✕ while dragging.
- Haptics: light on accept, none on reject, soft on "not sure".
- Accepting shows a brief "Linked" confirmation with undo.
- Tapping either note opens the full note.

**Batches:** 5 cards per batch. "Not sure" cards return in the next batch and stop appearing after their 30 days.

**First-time hint:** a one-time overlay showing the four gestures, never shown again.

**Other card types** use the same swipe pattern: tag suggestion (note with proposed tag chip) and topic suggestion (the notes it would group).

**Finished:** a quiet "All caught up" screen. No streaks or rewards. A "Review 5 more" button appears only if more exist.

---

## 7. Note View

```text
┌─────────────────────────┐
│ ←              📌  ⋮    │
│                         │
│ Future Self             │
│                         │
│ Maybe the messages      │
│ aren't predicting the   │
│ future. They're         │
│ causing it.             │
│                         │
│ ───────────────────     │
│ Tags                    │
│ (#story) (·#idea·)      │
│                         │
│ Linked                  │
│ (2:17 AM) (Causality)   │
│                         │
│ Suggested links         │
│ (·Time Loop·)           │
│                         │
│ Mentioned in            │
│ Movie idea              │
└─────────────────────────┘
```

**Top bar:** back, pin toggle, ⋮ menu (move to folder, archive, delete, attachments). A tiny "saved" tick fades in and out; there is no save button (autosave).

**Writing**
- Title is optional; if empty, the first line becomes the title.
- New notes open with the keyboard up. Existing notes open showing the text; tap anywhere to edit. No separate edit mode.
- Formatting is hidden until text is selected. A slim row above the keyboard offers bold, list, checklist, attach, and a `[[ ]]` link button.
- Typing `[[` opens a note picker for manual links.

**Below the text** (visible only when not typing; empty sections hidden)
- **Tags:** one row. Solid chips are confirmed tags (user-made or approved). Dimmed chips (no fill, dashed outline at about 55% opacity, readable secondary-text label) are AI-suggested tags waiting for approval. Tapping a dimmed tag opens the suggestion sheet (accept, reject, or close for not sure). The user can also add a tag by hand.
- **Linked:** solid chips for links the user made or approved.
- **Suggested links:** dimmed chips for AI link suggestions. Tapping opens the suggestion sheet.
- **Mentioned in:** backlinks.

---

## 8. Suggestion Card (shared component)

One reusable card, two containers:

| Place | Container | Interaction |
|---|---|---|
| Review screen | Full-screen swipe stack | Swipes plus buttons |
| Note view | Bottom sheet | Buttons only |

- The card shows both notes with highlighted passages, the one-line reason, "Why?", and ✓ / ✕.
- Accept and reject call the same logic everywhere (update status, store rejection, write link only after approval).
- In the sheet, closing it works as "not sure": the chip stays dimmed.
- After a choice, the chip on the note updates immediately (dimmed becomes solid, or disappears).
- Graph dashed lines open this same sheet.

---

## 9. Search

```text
┌─────────────────────────┐
│ ┌─────────────────────┐ │
│ │ 🔍 Search notes...  │ │
│ └─────────────────────┘ │
│ (Folder)(Tag)(Date)     │
│                         │
│ Recent searches         │
│ commute            ✕    │
│                         │
│ Matches                 │
│ ┌─────────────────────┐ │
│ │ Future Self    Today│ │
│ │ ...the [messages]...│ │
│ └─────────────────────┘ │
│ Similar in meaning      │
│ ┌─────────────────────┐ │
│ │ Time Loop      Sep 2│ │
│ └─────────────────────┘ │
└─────────────────────────┘
```

- Keyboard opens as soon as the tab is tapped.
- Before typing: recent searches, each removable.
- **Matches:** keyword results, highlighted, instant.
- **Similar in meaning:** on-device meaning-based results, filled in a moment later so keyword results never wait.
- Filters: thin pills for Folder, Tag, Date.
- Results are always a single-column list, even if Home uses grid.
- Search shows only the user's notes, never AI suggestions.
- Empty result: a quiet "No notes found".
- Works offline.

---

## 10. Graph

- Each note is a dot; solid lines are confirmed links. Default view shows confirmed links only.
- Dot size grows with link count. One dot color (folder color only when filtering by folder).
- Notes with no links are hidden by default (toggle to show).
- **Show suggestions** toggle (off by default) adds dimmed dashed lines; tapping one opens the suggestion sheet.
- Pan and pinch to zoom; titles appear only when zoomed in.
- Tap a dot → preview card at the bottom (title, snippet, **Open**, **Focus**). Focus shows that note and neighbors 1 to 3 hops out.
- Search icon jumps to and centers a note.
- Filter pills: Folder and Tag, plus the two toggles.
- No stats, no "orphan note" nudges, nothing to maintain.
- Empty state: "Links between your notes will appear here."
- Layout calculated once and cached; very large libraries switch to grouped bubbles.

---

## 11. Settings

Single scrollable page.

```text
YOU
Name                    Sparsh

APP
Layout                  Grid | List
Open app to             Home | New note
Theme                   System | Dark | Light
Quick capture           Widget and tile ›

SYNC
Notes folder            /MyNotes
Status                  Synced · 2 min ago

SMART SUGGESTIONS
Suggest connections     On
Analyze only when       On
charging
Laptop connection       Connected ›

DATA
Trash                   Kept 30 days ›
Export notes            Markdown .zip ›

ADVANCED ▾
Rebuild suggestions
Reset rejected suggestions

ABOUT
Privacy                 Everything stays on
                        your devices.
Version
```

- Smart Suggestions is the only place AI appears: no model picker, no thresholds, no jargon. One switch turns it off completely.
- Notes folder shows the chosen folder's name; tapping it opens the folder picker to change it. If no folder is chosen (or access was removed), the row reads "On this phone only" with the line "Choose a folder so your notes stay if the app is removed." Choosing a folder moves the notes there.
- Laptop connection is one row: pair, test connection, forget device. "Not connected" is a normal state.
- Advanced is collapsed by default.
- Trash keeps deleted notes for 30 days.
- Export produces a Markdown zip.

---

## 12. Microcopy

- Suggestion reason: "Looks related to your note on {title}."
- Revisit: "You might want to revisit this."
- Review finished: "All caught up."
- Empty home: "Write your first thought."
- Empty graph: "Links between your notes will appear here."
- Empty search: "No notes found."
- No numbers, percentages, or technical terms anywhere in the UI.

---

## 13. Gesture Summary

| Where | Gesture | Result |
|---|---|---|
| Review | Swipe right / left | Accept / Reject |
| Review | Swipe up | Not sure |
| Review | Swipe down | Undo |
| Suggestion sheet | Swipe down | Close (counts as not sure) |
| Graph | Drag / pinch | Pan / zoom |
| Note | Tap text | Start editing |
| Note | Type `[[` | Open note picker |

---

## 14. Open Questions

- Logo and app icon final artwork, and the final look of the "N" in the logo (colors and typography are settled; see the main spec).
- Final onboarding copy (the privacy claims must be exactly true at launch, including how sync works).
- Exact behavior of the Folders and Tags switch on Home (swapping the notes area to folder or tag pills is the current plan).
- Where accepted links are stored (inline `[[link]]` vs sidecar file); see the main spec.
- Whether the later "Recent notes" widget is worth it, given privacy of titles on the home screen.
- Whether a cold Flutter start meets the one-second capture target, or a minimal capture entry point is needed.
