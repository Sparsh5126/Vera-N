---
version: 1
slug: "lib-core-styles-app-styles-dart"
primary_target: "lib/core/styles/app_styles.dart"
related_targets: []
---

# App-wide colour and theme (Vera N, Android)

Scope: every screen's colours, surfaces and both themes. Visitor mode: Operate. Layout, positions, buttons, shapes, fonts and copy are fixed by the user (2026-10-08): no element is added or removed. Backlog #2 and #4.

Audience and task: one person writing private notes in passing, in English and Hindi, reading and reviewing later. Constraints: typing must not slow down (no animated or gradient layers behind the editor); contrast 4.5:1 for text, 3:1 for controls; dimmed + dashed = AI suggestion stays.

## Direction contract

THESIS: Vera N as a design annual's plate section: every note is a plate on uncoated stock, ruled by hairlines, and the only colour is a quiet periwinkle seal the AI uses to sign its suggestions. Refuses the near-black-plus-one-bright-accent dark app and the cream-and-serif notebook.

OWN-WORLD: Light: near-white stock #F5F4F6 with warmer plates #FAF9F7, ink #16181A (never pure black), hairlines #C9C7C4, secondary ink #5C5E66. Dark: the same section printed on black stock, composed not inverted: #121315 ground, #1C1B19 plates (warmer than the ground, in the ivory family), ivory ink #ECEBE8, hairlines #393834. Primary action and selection are a solid ink plate (ivory plate in dark). Seal #6266B0 / #A7AAE8 belongs only to AI marks: dashed suggestion outlines, the suggestion dot, the connections card mark, graph suggestion lines; its soft form #DCDDF3 / #34365A is the highlight (selection, search match). Bottle green confirms, vermilion strikes. Flat: no gradients, glows, shadows or texture.

STORY: The user sees their own words in ink on calm stock; what they confirmed is solid ink; what the AI proposes carries the periwinkle seal and dashes, so its voice is always recognisable and never loud.

FIRST VIEWPORT: Home unchanged in layout: wordmark and greeting in ink on #F5F4F6; Recent/Folders/Tags pills as hairline outlines with the active one a solid ink plate; note cards as warm plates with a 1px hairline; the new-connections card marked by the seal; New note a solid ink plate bottom right; nav pill bar with the selected tab an ink plate.

FORM: Challenger "design annual's plate section" (user's choice over the assigned direction, seed 584fb4b2), translated to colour roles only.

FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, DESIGN.md, and every shipping raster carrying its provenance
