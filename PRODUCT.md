# Product

<!-- impeccable:product-schema 1 -->

## Platform

android

## Users

One person writing for themselves: quick private notes on their phone, in English and Hindi (often mixed in one note), captured in passing and read back later. Confirmed 2026-10-08 with the user (the developer, who is also the first user).

## Product Purpose

Vera N is a private, offline-first notes app for writing quickly on the phone, where on-device AI quietly suggests links between notes that the user approves. Success: a thought goes from the home screen to a typing cursor in about one second, and connections the user forgot resurface without the user organizing anything.

## Positioning

"The app should remember the connections you forgot." The phone builds a semantic memory of the notes fully offline; the AI only suggests, the user decides. No account, no cloud, no chatbox.

## Operating Context

- Capture happens in passing, one-handed, from a widget, the Quick Settings tile, an app shortcut, or the app; reading and reviewing happen later.
- Notes are plain Markdown files in a folder the user picks (Obsidian-compatible); the app keeps an index and AI metadata privately.
- Suggestions are reviewed in batches of five (swipe or buttons) or from a note; analysis runs only while charging (or idle, if allowed).
- An optional laptop layer for deeper analysis is planned, not built.

## Capabilities and Constraints

- Built: capture, Home (Recent / Folders / Tags), note view and editor with Markdown formatting, keyword search, on-device embeddings and link suggestions, Review, Graph, Settings, onboarding, widgets, tile and shortcuts, Trash, Markdown .zip export.
- Flutter, Android first. One styles file (`lib/core/styles/app_styles.dart`) is the only place for colors, type, spacing and motion; native widget resources mirror it.
- Performance is a product requirement: typing must stay smooth (long notes are already near the frame budget), and capture-to-cursor is about one second.
- Specs of record: `Vera_N_Product_Spec_v3.md` (behavior, data, privacy; §22 visual design) and `Vera_N_UI_Spec.md` (screens, gestures, copy).

## Brand Commitments

- Name "Vera N" (Vera = truth; N = Notes; said together, "veeran", isolated in Hindi: private, sealed, offline).
- AI suggestions always look different from confirmed items: dimmed with a dashed outline, never by color alone (confirmed binding 2026-10-08).
- The app never speaks as "Vera"; plain language, no technical words, no nagging counts, badges or streaks.

## Evidence on Hand

No testimonials, users, or metrics beyond the developer's own use. Do not invent any.

## Product Principles

1. The user's words come first: while typing, only their words are on screen.
2. Everything stays on the device unless the user moves it.
3. AI suggests, the user decides; nothing changes without a yes, and every decision can be undone.
4. Instant capture beats features.

## Accessibility & Inclusion

Text contrast at least 4.5:1, 48 dp tap targets, system text scaling, reduce motion respected, Devanagari renders cleanly next to Latin text.
