# CLAUDE.md — Vera N

Instructions for building **Vera N**, a local-first, privacy-first notes app (Flutter, Android first). Read this file at the start of every session.

## 1. Source of truth

- `Vera_N_Product_Spec_v3.md`: behavior, AI pipeline, data, privacy.
- `Vera_N_UI_Spec.md`: every screen, gesture, copy line, and widget.
- If code and specs disagree, the specs win. If a spec is unclear or has an open decision that blocks you, **ask; don't guess**. Open decisions right now: where accepted links are stored (inline vs sidecar), which on-device embedding model, similarity thresholds.
- If you change behavior on purpose, update the spec in the same change and log it in the changelog.

## 2. Before writing any code

1. **Define the folder architecture first.** Write `docs/ARCHITECTURE.md` with the folder tree, what each folder owns, the state-management choice, the database choice, and the rules for how layers depend on each other. Get approval before building.
2. Create the **styles file** (section 4) before any screen.
3. Build in this order, phone capture first: architecture and styles → storage and notes CRUD → fast capture screen → Home, Note view, Search (keyword) → on-device embeddings and suggestions → Review screen and suggestion card → Graph, Settings, Onboarding → widgets, tile, shortcuts → laptop layer and sync.

### Proposed folder structure (confirm or revise in ARCHITECTURE.md)

```text
lib/
├── main.dart
├── app/                 app.dart, router.dart
├── core/
│   ├── styles/          app_styles.dart  (the one styles file)
│   ├── feedback/        haptics.dart
│   ├── storage/         file store, database, repositories
│   ├── ai/              embedder, matching, suggestion engine, scheduler
│   └── utils/
├── features/
│   ├── onboarding/
│   ├── home/
│   ├── note/
│   ├── review/
│   ├── search/
│   ├── graph/
│   └── settings/
└── shared/widgets/      reusable UI pieces
test/
docs/ARCHITECTURE.md
CHANGELOG.md
```

Each feature folder holds its own screen, widgets, and state. Features never import from each other; shared things go in `core/` or `shared/`.

## 3. File size and code structure

- **No giant files.** Aim for under 250 lines per file; 400 is the hard limit. Split before reaching it.
- One widget or class per file. Functions stay under about 40 lines.
- Screens only compose widgets. Business logic lives in state/repository classes, never inside widgets.
- Use `const` constructors wherever possible. Name files after the class they hold.

## 4. One styles file

`lib/core/styles/app_styles.dart` is the **only** place for styling values:

- **Colors** (dark and light, from the product spec section 22), including accept/reject and the solid vs dimmed chip look.
- **Typography** (Inter with Noto Sans Devanagari fallback; Instrument Serif for the wordmark only).
- **Spacing** (8-point grid), **radii** (cards 24, pills fully rounded), **tap-target minimum** (48), borders, opacities (dimmed about 55%).
- **Motion tokens**: durations and curves (200 ms ease-out default, spring for card swipe).
- Theme builders (`lightTheme`, `darkTheme`) that follow the system theme.

Rules:
- No hardcoded colors, font sizes, paddings, radii, durations, or curves anywhere else. No `Color(0x…)`, `TextStyle(` with literals, `EdgeInsets.all(12)`, or `Duration(milliseconds: …)` outside this file.
- Other files call the helpers and tokens from this file.
- If this file passes about 400 lines, split it into `part` files but keep **one import point** (`app_styles.dart`).
- Before finishing a task, search the codebase for stray literals and fix them.

## 5. Easy to change UI

- Every repeated UI element is a **shared widget** in `shared/widgets/` (for example `PillButton`, `NoteCard`, `SuggestionChip`, `SuggestionCard`, `SectionLabel`, `EmptyState`).
- Changing one widget or one token must update the whole app. If you copy-paste UI, extract it instead.
- Widgets take data and callbacks, not repository objects. Copy strings (microcopy) live in one place, so wording changes are one edit.
- Layout options (grid or list) are driven by a setting, not duplicated screens.

## 6. UI/UX rules (apply as you build, not afterward)

- Follow the UI spec exactly: screens, gestures, copy, empty states.
- **Dimmed means AI suggestion, solid means confirmed.** Dimmed items also use a dashed outline so meaning never relies on color alone.
- Every screen has designed empty, loading, and error states. Local actions are instant: no spinners for things that run on the device.
- Prefer undo over confirmation dialogs. Gestures always have visible button alternatives.
- While typing, only the user's words are on screen. Suggestions never interrupt writing.
- No notification-style badges, counts that nag, streaks, or percentages. No technical words in the UI. The app never speaks as "Vera".
- Accessibility: tap targets at least 48, text contrast at least 4.5:1, support system text scaling, semantic labels on icons, test with large text and small screens.
- Design for one-handed use; primary actions sit in thumb reach.
- Test Hindi and English text in the same note (Devanagari must render cleanly).

## 7. Haptics and animations

- All haptics go through one wrapper (`core/feedback/haptics.dart`) with named events, never raw calls in widgets. Mapping: accept = light tap, reject = none, not sure = soft, undo = soft. Add events only when the UI spec calls for them.
- Respect the system: no haptics if the user disabled them; honor "reduce motion" (use instant or simple fades).
- Animations are short and purposeful: 200 ms ease-out by default, a springy card swipe in Review with a tilt and a faint ✓ or ✕ while dragging. No decorative or looping animation.
- Animate only transform and opacity where possible, not layout. Dispose every controller. Keep scrolling and swiping at a steady 60 fps.

## 8. Battery and storage

- **Incremental work only.** Re-embed a note only when its content hash changes, and only after the user stops typing. Never re-embed the whole library for one edit.
- **Background analysis runs only when charging or idle** (use OS-scheduled work with constraints). No polling, no wake locks, no foreground service unless truly needed. Batch work and stop when conditions end.
- Load the embedding model, run a batch, release it. Don't keep it in memory. Use a small quantized model.
- Store embeddings as compact binary (float16 or int8), not JSON or text. Index the database for the queries the UI actually runs.
- Lists use lazy builders. Avoid unnecessary rebuilds. Cache the graph layout and recompute only when links change.
- Compress attachments. Cap caches. A periodic cleanup job removes expired suggestions (30 days) and trash (30 days).
- Add no dependency without a reason. Prefer Flutter built-ins; for each new package, note its size and battery impact in the changelog.
- Measure before and after for anything performance-related and record the result in the changelog.
- Target: tap on a widget, tile, or shortcut to a typing cursor in about one second.

## 9. Product rules that must never break

- **Local-first and private:** no cloud, no accounts, no analytics or crash-reporting SDKs, no sending note content anywhere. Request the minimum permissions.
- **Notes are the user's words.** AI never changes a note without permission, and only by adding, never removing or rewriting. AI never moves notes between folders. Folders are user-made; tags need approval.
- AI output is metadata and suggestions, kept separate and rebuildable. Approved links are user decisions (see the open link-storage decision).
- No chat or AI controls in everyday use. Smart Suggestions in Settings is the only AI surface.
- Suggestions: strong matches only, batches of 5, rejections remembered (with content hashes), unreviewed suggestions expire after 30 days.

## 10. Changelog

- Maintain `CHANGELOG.md` in Keep a Changelog style, with versions starting at 0.1.0 and newest on top.
- **Update it in every change before you finish**, under Added, Changed, Fixed, or Removed, with a short line on why.
- Log new dependencies, architecture decisions, spec changes, and performance measurements.

## 11. Working style

- At the start of a task, state your plan in a few lines. Keep changes small and focused; one concern per change.
- Run `flutter analyze`, format the code, and run tests before saying a task is done. Add tests for storage, matching logic, and suggestion lifecycle.
- Don't leave dead code, commented-out blocks, or TODOs without a changelog or issue note.
- Don't silently decide open questions or change the specs. Ask, then record the decision.

## 12. Definition of done

- [ ] Matches the UI spec (layout, gestures, copy, empty states)
- [ ] No hardcoded styling values; uses `app_styles.dart`
- [ ] Reusable pieces extracted into `shared/widgets/`
- [ ] No file over 400 lines
- [ ] Haptics and animations follow section 7; reduce motion respected
- [ ] No battery or storage regressions; measurements logged where relevant
- [ ] Analyze and tests pass
- [ ] `CHANGELOG.md` updated; specs updated if behavior changed
