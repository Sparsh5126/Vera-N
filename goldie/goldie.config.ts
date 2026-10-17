// Google Play store assets for Vera N, made by goldie (https://www.npmjs.com/package/goldie).
//
// Every flow starts with .argent/flows/store-setup.yaml: it clears the test
// app (com.example.vera_n.perf), seeds the made-up notes in goldie/seed/notes
// and runs the on-device analysis, so the suggestions on screen are real
// ones. Real notes are never involved.
//
// Build the APK first (x86_64, for the emulator):
//   flutter build apk --profile --target-platform android-x64 --android-project-arg=vera.perf=true
// Then: GOLDIE_CONFIG=goldie/goldie.config.ts npx -y goldie@0 capture   (frame, manifest, studio)
//
// The type lives in the goldie package (dist/config.d.ts); it isn't imported
// here so the file doesn't depend on where goldie is installed.

import { fileURLToPath } from "node:url";

const config = {
  // The repository root, worked out from this file so any working directory does.
  appRoot: fileURLToPath(new URL("..", import.meta.url)),
  devices: ["pixel-10-pro"],
  android: {
    appPath: "../build/app/outputs/flutter-apk/app-profile.apk",
    applicationId: "com.example.vera_n.perf",
  },
  locales: ["en-US"],
  appearance: "light",
  // goldie requires this; it is iPhone art, so Play tiles keep the bundled Pixel 10 Pro bezel.
  frame: { variant: "17-pro-silver" },

  // The app's own colours (DESIGN.md): ink on stock, and its own typeface.
  theme: {
    background: "linear-gradient(180deg, #F5F4F6 0%, #ECEBEE 100%)",
    headlineColor: "#16181A",
    subheadColor: "#5C5E66",
    fontFiles: [
      {
        family: "Inter",
        files: { 400: "../assets/fonts/Inter-Variable.ttf", 600: "../assets/fonts/Inter-Variable.ttf" },
      },
    ],
    fontFamily: "Inter",
    // The classic layout sizes the copy and device from these; without them
    // it draws no device at all.
    copyHeightRatio: 0.24,
    deviceWidthRatio: 0.84,
    template: "uniform",
    layout: "classic",
  },

  store: {
    name: "Vera N",
    subtitle: { "en-US": "Private notes that remember what you forgot" },
    developer: "Sparsh Saxena",
    category: "Productivity",
    // Not released yet, so no ratings to show.
    rating: 0,
    ratingCount: "No ratings yet",
    ageRating: "Everyone",
    price: "Free",
    description: {
      "en-US":
        "Vera N is a private notes app for writing quickly on your phone, in English, Hindi, or both in one note.\n\n" +
        "While you write, nothing gets in your way. Later, while your phone charges, a small language model on the phone itself suggests connections between notes you may have forgotten. Every suggestion waits for your yes; nothing changes without it.\n\n" +
        "No account. No cloud. Your notes are plain Markdown files in a folder you choose, and the code is open source.",
    },
  },

  scenes: [
    {
      kind: "screenshot",
      id: "home",
      flow: "store-01-home",
      headline: { "en-US": "Notes that stay yours" },
      subhead: { "en-US": "No account, no cloud. Connections are found on your phone." },
    },
    {
      kind: "screenshot",
      id: "review",
      flow: "store-02-review",
      headline: { "en-US": "Remembers what you forgot" },
      subhead: { "en-US": "Link two related notes with one tap, or let it go." },
    },
    {
      kind: "screenshot",
      id: "search",
      flow: "store-03-search",
      headline: { "en-US": "Search by meaning" },
      subhead: { "en-US": "Ask in Hindi, find the note you wrote in English." },
    },
    {
      kind: "screenshot",
      id: "note",
      flow: "store-04-note",
      headline: { "en-US": "Hindi and English, one note" },
      subhead: { "en-US": "Checklists, links and tags, in the words you think in." },
    },
    {
      kind: "screenshot",
      id: "write",
      flow: "store-05-write",
      headline: { "en-US": "Just write" },
      subhead: { "en-US": "From a tap to a typing cursor in about a second." },
    },
    {
      kind: "preview",
      id: "preview",
      // Two segments, not four: each clip starts with a few seconds of still
      // screen while recording spins up, so fewer clips means less dead time.
      segments: [
        { id: "connect", flow: "store-preview-01-connect" },
        { id: "search", flow: "store-preview-02-search", holdSeconds: 1 },
      ],
    },
  ],
};

export default config;
