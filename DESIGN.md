---
name: Vera N
description: A private, offline notes app on ink and stock, where the seal the AI signs its suggestions with is the one colour in everyday use.
colors:
  stock: "#F5F4F6"
  plate: "#FAF9F7"
  ink: "#16181A"
  ink-secondary: "#5C5E66"
  hairline: "#C9C7C4"
  seal: "#6266B0"
  seal-soft: "#DCDDF3"
  bottle-green: "#2D6A4F"
  vermilion: "#B4382D"
  stock-dark: "#121315"
  plate-dark: "#1C1B19"
  ivory-ink: "#ECEBE8"
  ink-secondary-dark: "#A2A2AA"
  hairline-dark: "#393834"
  seal-dark: "#A7AAE8"
  seal-soft-dark: "#34365A"
  bottle-green-dark: "#6CBF96"
  vermilion-dark: "#E8806F"
  folder-amber: "#B7791F"
  folder-amber-dark: "#F2B84B"
typography:
  wordmark:
    fontFamily: "Instrument Serif"
    fontSize: "28px"
    fontWeight: 400
    lineHeight: 1.214
  headline:
    fontFamily: "Inter, Noto Sans Devanagari"
    fontSize: "22px"
    fontWeight: 600
    lineHeight: 1.273
  body:
    fontFamily: "Inter, Noto Sans Devanagari"
    fontSize: "16px"
    fontWeight: 400
    lineHeight: 1.5
  title:
    fontFamily: "Inter, Noto Sans Devanagari"
    fontSize: "15px"
    fontWeight: 600
    lineHeight: 1.467
  body-card:
    fontFamily: "Inter, Noto Sans Devanagari"
    fontSize: "15px"
    fontWeight: 400
    lineHeight: 1.467
  label:
    fontFamily: "Inter, Noto Sans Devanagari"
    fontSize: "15px"
    fontWeight: 500
    lineHeight: 1.333
  small:
    fontFamily: "Inter, Noto Sans Devanagari"
    fontSize: "12px"
    fontWeight: 400
    lineHeight: 1.333
  section-label:
    fontFamily: "Inter, Noto Sans Devanagari"
    fontSize: "12px"
    fontWeight: 600
    lineHeight: 1.333
rounded:
  card: "24px"
  field: "24px"
  pill: "9999px"
spacing:
  xs: "4px"
  s: "8px"
  m: "16px"
  l: "24px"
  xl: "32px"
  xxl: "48px"
components:
  button-primary:
    backgroundColor: "{colors.ink}"
    textColor: "{colors.stock}"
    typography: "{typography.label}"
    rounded: "{rounded.pill}"
    padding: "0 24px"
    height: "48px"
  button-primary-dark:
    backgroundColor: "{colors.ivory-ink}"
    textColor: "{colors.stock-dark}"
    typography: "{typography.label}"
    rounded: "{rounded.pill}"
    padding: "0 24px"
    height: "48px"
  button-text:
    textColor: "{colors.ink}"
    typography: "{typography.label}"
    rounded: "{rounded.pill}"
    height: "48px"
  filter-pill:
    backgroundColor: "{colors.plate}"
    textColor: "{colors.ink}"
    typography: "{typography.label}"
    rounded: "{rounded.pill}"
    padding: "0 16px"
    height: "48px"
  filter-pill-active:
    backgroundColor: "{colors.ink}"
    textColor: "{colors.stock}"
    typography: "{typography.label}"
    rounded: "{rounded.pill}"
    padding: "0 16px"
    height: "48px"
  chip-confirmed:
    backgroundColor: "{colors.ink}"
    textColor: "{colors.stock}"
    typography: "{typography.label}"
    rounded: "{rounded.pill}"
    height: "48px"
  chip-suggested:
    textColor: "{colors.ink-secondary}"
    typography: "{typography.label}"
    rounded: "{rounded.pill}"
    height: "48px"
  note-card:
    backgroundColor: "{colors.plate}"
    textColor: "{colors.ink}"
    typography: "{typography.body-card}"
    rounded: "{rounded.card}"
    padding: "16px"
    height: "168px"
  nav-bar:
    backgroundColor: "{colors.plate}"
    rounded: "{rounded.pill}"
    padding: "8px"
    height: "64px"
  nav-item-selected:
    backgroundColor: "{colors.ink}"
    textColor: "{colors.stock}"
    rounded: "{rounded.pill}"
    width: "64px"
  sheet:
    backgroundColor: "{colors.plate}"
    textColor: "{colors.ink}"
    rounded: "{rounded.card}"
  snackbar:
    backgroundColor: "{colors.ink}"
    textColor: "{colors.stock}"
    typography: "{typography.label}"
    rounded: "{rounded.pill}"
---

# Design System: Vera N

## Overview

**Creative North Star: "The Plate Section"**

Vera N is a design annual's plate section. Every note is a plate on uncoated stock, ruled by a single hairline; the user's words are printed in ink that is never pure black or pure white; and the one hue in everyday use is a quiet periwinkle seal that the on-device AI uses to sign what it proposes (amber appears only to mark a folder in the Graph). What the user confirmed is solid ink. What the AI suggests is open, dashed and sealed, so its voice is always recognisable and never loud.

Light is near-white stock with plates a shade warmer. Dark is the same section printed on black stock, composed rather than inverted: the ground stays cool, the plates sit in the ivory family, and the ink is ivory. Both themes follow the system setting. The world is colour-and-role only: layout, type, radii and spacing predate it and were deliberately left as they were.

The world is flat by the user's explicit choice. It refuses the near-black-plus-one-bright-accent dark app and the cream-and-serif notebook.

**Key Characteristics:**
- Two inks and a seal: ink for the user, secondary ink for metadata, periwinkle only for the AI.
- Solid ink plate means chosen or confirmed: primary action, active tab or filter, confirmed chip, caret.
- Plates ruled by 1px hairlines; no shadows, gradients, glow or texture.
- Generous, fully rounded pills and 24px card corners, unchanged from the incumbent app.
- Dark is composed, not inverted: cool ground, warm ivory plates.

## Colors

A near-neutral paper-and-ink palette with one restrained periwinkle reserved for the AI, plus green and vermilion for decisions.

### Primary
- **Ink Plate** (ink in light, ivory ink in dark): the solid fill for the one primary action per screen (New note), the selected nav tab, the active Recent/Folders/Tags filter, confirmed tag/folder/link chips, the text caret and selection handles, the underline of confirmed links in the editor, and the snackbar body. Text on it is the stock colour of the same theme.

### Secondary
- **Periwinkle Seal** (seal / seal-dark): the AI's mark and nothing else. Dashed outlines of suggested chips, the waiting-suggestion dot on note cards, the connections-card icon on Home, and dashed suggestion lines in the Graph. Drawn at full strength; it is never faded.
- **Pressed Seal** (seal-soft / seal-soft-dark): the seal pressed lightly into the stock. Text selection and search-match highlights only.

### Tertiary
- **Bottle Green** (bottle-green / bottle-green-dark): confirms. The ✓ decision button and the Review card's drag-right mark.
- **Vermilion** (vermilion / vermilion-dark): strikes. The ✕ decision button, the drag-left mark, "Delete forever" in Trash, and the Material error role.
- **Folder Amber** (folder-amber / folder-amber-dark): the folder colour, chosen by the user (2026-10-08). Only the Graph's dots while a Folder filter is on, and the outline and light wash (16%) of its folder bubbles in very large libraries (UI spec §10); the bubble's name stays ink. Fills and marks only, never text (light amber is 3.3:1 against the stock, enough for a dot, not for type).

### Neutral
- **Stock** (stock / stock-dark): the screen ground, scaffold and canvas; also the native launch background.
- **Warm Plate** (plate / plate-dark): cards, sheets, the nav bar, inactive filter pills, home-screen widgets. A shade warmer than the stock in both themes; in dark it sits in the ivory family, never cool graphite.
- **Ink** (ink / ivory-ink): the user's words, titles and every label.
- **Secondary Ink** (ink-secondary / ink-secondary-dark): dates, section labels, hints, inactive nav icons, ticked checklist items, chevrons, and the label of suggested chips.
- **Hairline** (hairline / hairline-dark): the 1px rule around plates and outlined controls, dividers, the sheet drag handle.

### Named Rules
**The Seal Rule.** Periwinkle belongs to the AI. It appears only on suggestions (dashed outlines, the waiting dot, the connections mark, graph suggestion lines) and never on anything the user confirmed, never as a button, link or brand colour.

**The Open Plate Rule.** "Dimmed" means an empty fill, a secondary-ink label and a dashed seal outline at full strength. Do not fade the dashes: a faded seal measured 2.1:1 in light and read grey in dark. Meaning never relies on colour alone.

**The Ink Plate Rule.** A solid ink plate means chosen: the primary action, the selected tab or filter, a confirmed chip. Never use it decoratively.

**The Folder Rule.** Amber marks a folder in the Graph and nothing else: never a button, link, text, or a second accent. Everywhere else a folder is an ink chip like any confirmed item.

**The Mirror Rule.** Android resources drawn outside Flutter (`values/colors.xml`, `values-night/colors.xml`: launch background, widget card, border, text, secondary text, accent) carry the exact palette values. Change both together.

## Typography

**Display Font:** Instrument Serif (wordmark only)
**Body Font:** Inter (variable, weight axis set explicitly), with Noto Sans Devanagari fallback
**Label Font:** Inter

**Character:** A single humanist-neutral sans carries everything, so Hindi and English sit in one line without a seam; the serif appears once, as the "Vera N" wordmark. Sizes scale with the system text size. Unchanged by the plate-section pass.

### Hierarchy
- **Wordmark** (Instrument Serif 400, 28/34): "Vera N" on Home and onboarding only.
- **Headline** (600, 22/28): the note title in the note view.
- **Body** (400, 16/24): note text and the editor; hints use secondary ink.
- **Title** (600, 15/22): card titles, the connections card line, suggestion card titles.
- **Body Card** (400, 15/22): card previews, fading out from 60% of the card height.
- **Label** (500, 15/20): buttons, pills, tabs, chips, snackbar text.
- **Small** (400, 12/16, secondary ink): dates and metadata.
- **Section Label** (600, 12/16, secondary ink, sentence case): headings such as "Pinned", "Tags", "Linked", "Suggested links".

### Named Rules
**The One Serif Rule.** Instrument Serif is the wordmark and nothing else.

**The Inline Mark Rule.** In the editor, confirmed links are body text with a 2px ink underline; bold is Inter 700; a ticked checklist item is secondary ink, struck through. Read-only text on screen draws checklists as □ / ✓ (Inter has no ☐ / ☑ and Android would fall back to colour emoji); text that leaves the screen keeps ☐ / ☑.

## Layout

An 8-point grid with one half-step (4px) for tight icon gaps. Every screen has a 16px side margin; cards pad 16px inside; pills and buttons pad 24px horizontally. Home is a two-column grid (or a list, by setting) of 168px cards, with a pinned row of 168px-wide cards above it. A floating pill nav bar (64px tall, 64px items) and a floating New note button sit in thumb reach at the bottom; scrolling content keeps 168px of clearance under it (96px on tab screens without the floating button). Text columns cap at 680px on large screens. Every interactive element is at least 48px; Review's main choices are 64px.

## Elevation & Depth

Flat. There are no shadows, glows, gradients or textures anywhere; Material elevation and surface tint are zeroed on cards, sheets and snackbars. Depth is carried by tone and line alone: warm plates on cooler stock, each ruled by a 1px hairline. Behind sheets, light mode lays an ink veil at 32% so the near-white page stays pale; dark mode uses the platform default scrim.

Two functional fades predate this world and stay: card previews fade out from 60% of their height, and a 96px fade of the stock colour sits above Home's floating controls so cards do not collide with them. They are legibility devices, not a gradient vocabulary.

### Named Rules
**The Flat Plate Rule.** A plate is separated from the stock by colour and a 1px hairline, never by a shadow. If something needs to read as raised, it is a sheet with a scrim, not a shadow.

## Shapes

Two shapes only. Plates (cards, the connections card, suggestion cards, sheet tops) have softly generous 24px corners. Everything you press or pick (buttons, filter pills, tabs, chips, the nav bar, the snackbar) is a fully rounded stadium; text fields are pills at half the 48px tap height. Every outline is 1px. Suggested chips are dashed (4px dash, 3px gap); graph suggestion lines use the same dashes doubled.

## Components

### Buttons
- **Shape:** fully rounded stadium (pill), 48px minimum height.
- **Primary:** solid ink plate with stock-coloured label, 24px horizontal padding. One per screen (New note on Home, bottom right).
- **Text / Icon:** ink label or icon, no fill, same pill shape and 48px target.
- **Decisions:** ✕ in vermilion and ✓ in bottle green, with "Not sure" between them when offered.

### Chips
- **Confirmed (tag, folder, link):** solid ink plate, stock-coloured label, no dash. Labels cut with "…" past 240px.
- **Suggested:** the same pill with no fill, a dashed seal outline at full strength and a secondary-ink label.

### Filter Pills
- **Inactive:** warm plate fill, 1px hairline, ink label.
- **Active:** solid ink plate with a stock-coloured label. An optional 20px chevron for the menu variant.

### Cards / Containers
- **Corner Style:** 24px.
- **Background:** warm plate, 1px hairline, flat.
- **Internal Padding:** 16px.
- **Note card:** small date line in secondary ink, a seal dot (8px) when a suggestion is waiting, a 600 title, then the preview fading at 60%.
- **Connections card (Home):** plate with the seal-coloured connections icon, a title line, and a secondary-ink chevron.

### Inputs / Fields
- **Style:** borderless; hint text in secondary ink at body size. While typing, only the user's words are on screen.
- **Selection:** pressed seal behind selected text; ink caret and handles.

### Navigation
- **Pill nav bar:** a floating plate stadium with a hairline, 8px inner padding. The selected tab is a 64px ink plate that slides under the icons (200ms ease-out); its icon flips to the stock colour, the others stay secondary ink.

### Sheets and Snackbars
- **Sheet:** plate with 24px top corners, a hairline-coloured drag handle, ink scrim at 32% in light.
- **Snackbar:** floating ink pill with stock-coloured text and action, flat. Undo snackbars stay 5s.

### Suggestion Card (Review)
Two plates, one per note, each with a small label, title and highlighted preview, plus a "why" line in secondary ink. It swipes on a spring with a tilt of up to 0.14 rad and shows a faint green ✓ or vermilion ✕ (at most 55% opacity) while dragging; reduce motion makes transitions instant.

## Do's and Don'ts

### Do:
- **Do** use the seal (#6266B0 / #A7AAE8) only for AI marks, at full strength.
- **Do** show a suggestion as an empty fill, secondary-ink label and dashed seal outline, so meaning never relies on colour.
- **Do** use a solid ink plate for the one primary action and for whatever is selected or confirmed.
- **Do** separate plates from the stock with tone and a 1px hairline.
- **Do** keep Android's native colour resources identical to the palette in both themes.
- **Do** keep text at 4.5:1 and controls, including dashed outlines, at 3:1 or better in both themes.

### Don't:
- **Don't** use periwinkle for buttons, links, brand moments or anything the user confirmed.
- **Don't** fade suggestion dashes to signal "dimmed".
- **Don't** add shadows, gradients, glows or texture; the two existing preview and bottom fades are the only fades.
- **Don't** use pure black or pure white for ink or ground.
- **Don't** invert light into dark; dark plates stay warm ivory-family, never cool graphite.
- **Don't** use Instrument Serif for anything but the wordmark.
