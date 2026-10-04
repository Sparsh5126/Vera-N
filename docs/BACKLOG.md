# Backlog: before release

From the user's note `20261004-145445-ae09` (2026-10-04): "all these aren't urgent but it has to be done before the release." Items keep the user's numbers. Each one is done in its own change, with the specs updated.

| # | Item | Status | Notes |
|---|---|---|---|
| 1 | Linked notes and backlinks below the text should work like hyperlinks | Open | Same as #9: Linked and Mentioned in become text links rather than chips. **Changes UI spec §7** ("Linked: solid chips"). |
| 2 | Premium feel: chips "with maybe gold texture and shadows", shown after the keyboard closes, without slowing the app | Open: **needs a decision** | **Conflicts with product spec §22**: "Flat surfaces with a thin subtle border, no shadows" and a "calm, quiet" mood. Decide the direction before building, then update §22. Do it together with #4 as one design pass. |
| 3 | Selecting numbered points and choosing List should keep them as a numbered list | Open | Needs numbered lists (`1. `) as list markup, together with #6. |
| 4 | Enhance the overall UI and colours | Open: **needs a decision** | One design pass with #2. The colours are fixed in product spec §22 today, so changing them updates the spec. |
| 5 | Move to folder is below the text now, so remove it from the ⋮ menu | **Done** (2026-10-04) | The earlier concern didn't hold: a new note can't be moved before it has text either way, and while typing the keyboard can be closed to reach the Folder row. |
| 6 | Typing like the Claude app: typing `1. ` starts a numbered list and Enter numbers the next item | Open | Extend `MarkupEditing` with a numbered kind (the bullet and checklist continuation already works the same way). |
| 7 | Delete a note from Home (long-press or swipe) | Open | Keep a visible button alternative (UI spec §2.6), and offer Undo, not a confirmation. |
| 8 | The Undo popup doesn't go away on its own | **Done** (2026-10-04) | Flutter keeps a snackbar with an action until dismissed; `UndoSnackBar` now sets `persist: false`. A test guards it. |
| 9 | Tags and folders as chips; linked and backlinked notes as hyperlinks | Open | See #1. |
| 10 | Animate switching tabs on the nav pill | Open | 200 ms ease-out from the motion tokens; instant when "reduce motion" is on. |
| 11 | A button to copy the whole note, next to the pin button | **Done** (2026-10-04) | Copy the text as the reader sees it (links as titles, ☐/☑, no Markdown), in line with "for them it's just notes". |

## Also open (found during work)

- **Typing smoothness.** The 2026-10-04 measurement (CHANGELOG) shows the remaining slow frames are raster-bound (GPU drawing), not build-bound. Next step: a DevTools timeline of fast typing on the phone, to see what is being redrawn.
- **Release build size.** Profile APKs varied between 75 and 98 MB between builds; measure a release build and log it.
- **Application id** is still `com.example.vera_n`; it needs the user's own id before any store release.
