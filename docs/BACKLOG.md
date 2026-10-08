# Backlog: before release

From the user's note `20261004-145445-ae09` (2026-10-04): "all these aren't urgent but it has to be done before the release." Items keep the user's numbers. Each one is done in its own change, with the specs updated.

| # | Item | Status | Notes |
|---|---|---|---|
| 1 | Linked notes and backlinks below the text should work like hyperlinks | **Done** (2026-10-04) | Same as #9: Linked and Mentioned in become text links rather than chips. **Changes UI spec §7** ("Linked: solid chips"). |
| 2 | Premium feel: chips "with maybe gold texture and shadows", shown after the keyboard closes, without slowing the app | Open: **needs a decision** | **Conflicts with product spec §22**: "Flat surfaces with a thin subtle border, no shadows" and a "calm, quiet" mood. Decide the direction before building, then update §22. Do it together with #4 as one design pass. |
| 3 | Selecting numbered points and choosing List should keep them as a numbered list | **Done** (2026-10-04) | Needs numbered lists (`1. `) as list markup, together with #6. |
| 4 | Enhance the overall UI and colours | Open: **needs a decision** | One design pass with #2. The colours are fixed in product spec §22 today, so changing them updates the spec. |
| 5 | Move to folder is below the text now, so remove it from the ⋮ menu | **Done** (2026-10-04) | The earlier concern didn't hold: a new note can't be moved before it has text either way, and while typing the keyboard can be closed to reach the Folder row. |
| 6 | Typing like the Claude app: typing `1. ` starts a numbered list and Enter numbers the next item | **Done** (2026-10-04) | Extend `MarkupEditing` with a numbered kind (the bullet and checklist continuation already works the same way). |
| 7 | Delete a note from Home (long-press or swipe) | **Done** (2026-10-04): long-press | Keep a visible button alternative (UI spec §2.6), and offer Undo, not a confirmation. |
| 8 | The Undo popup doesn't go away on its own | **Done** (2026-10-04) | Flutter keeps a snackbar with an action until dismissed; `UndoSnackBar` now sets `persist: false`. A test guards it. |
| 9 | Tags and folders as chips; linked and backlinked notes as hyperlinks | **Done** (2026-10-04) | See #1. |
| 10 | Animate switching tabs on the nav pill | **Done** (2026-10-04) | 200 ms ease-out from the motion tokens; instant when "reduce motion" is on. |
| 11 | A button to copy the whole note, next to the pin button | **Done** (2026-10-04) | Copy the text as the reader sees it (links as titles, ☐/☑, no Markdown), in line with "for them it's just notes". |

## Also open (found during work)

- **Typing lag in long notes (paused 2026-10-04 at the user's request; resume later).** Measured on the phone with `tool/perf/typing_scenario.sh long` (~150 lines: checklists, bullets, bold):
  - Short notes are fine (UI frame median ~3.5 ms).
  - Long notes: UI frame median 23 ms, about 70% of frames over 16 ms. The timeline shows ~18 ms of each frame in LAYOUT of the text field.
  - The same note as plain unformatted text: median 7.6 ms. So ~15 ms per frame comes from formatting, not the text length alone.
  - Without the checkbox/bullet glyph widgets: 22 ms, so glyphs are not the cause.
  - Not yet measured: without the hidden-symbol style (0.01 font size runs) and without bold font variations. These are the next two suspects (many tiny style runs break up text shaping).
  - Already fixed: the quadratic span build (CHANGELOG).
- ~~**Release build size.**~~ Measured 2026-10-04 (CHANGELOG): the release arm64 APK is 71.3 MB with the model, 21.4 MB without. Per-device APKs or an app bundle are needed: a single all-CPU APK is about 160 MB.
- **Application id** is still `com.example.vera_n`; it needs the user's own id before any store release.
- ~~**Device check of background analysis.**~~ Passed 2026-10-08 on the measurement build: after leaving the app while charging, the log shows `VeraN analysis: requested`, and the run started 60 s later and finished (`run finished, all done: true`). Work queued by the earlier build also ran at the next launch. Why the 2026-10-04 check saw no job is unknown (it has not come back since the logging was added). Not yet checked: that a library with matching notes produces suggestions on the phone.
- **Slow first launch seen once (2026-10-04):** "15415 ms to typing cursor" on the first launch after installing the new build (schema 4 migration plus the new plugins). Check whether it repeats on a second launch; the target is about 1 s.
