// Styles for docs/brand/preview.html, in the DESIGN.md colours. The
// wallpapers are fixed, not themed: an icon has to hold on any of them.
const brandPreviewStyle = '''
@font-face { font-family: "Instrument Serif"; src: url("../../assets/fonts/InstrumentSerif-Regular.ttf"); }
@font-face { font-family: "Inter"; src: url("../../assets/fonts/Inter-Variable.ttf"); font-weight: 100 900; }
:root {
  --stock: #F5F4F6; --plate: #FAF9F7; --ink: #16181A; --ink2: #5C5E66; --hair: #C9C7C4;
  color-scheme: light dark;
}
@media (prefers-color-scheme: dark) {
  :root { --stock: #121315; --plate: #1C1B19; --ink: #ECEBE8; --ink2: #A2A2AA; --hair: #393834; }
}
* { box-sizing: border-box; }
body { margin: 0; background: var(--stock); color: var(--ink); font: 15px/1.5 Inter, system-ui, sans-serif; }
main { max-width: 1080px; margin: 0 auto; padding: 48px 16px 96px; }
h1 { font: 400 48px/1.1 "Instrument Serif", serif; margin: 0 0 8px; }
h2 { font-size: 12px; font-weight: 600; letter-spacing: .08em; text-transform: uppercase; color: var(--ink2); margin: 48px 0 16px; }
p, li { max-width: 62ch; }
.lede, .cap { color: var(--ink2); }
.cap { font-size: 12px; margin: 12px 0 0; }
code { font-size: 13px; }
.row { display: flex; flex-wrap: wrap; gap: 16px; }
.row > * { flex: 1 1 320px; min-width: 0; }
.plate { background: var(--plate); border: 1px solid var(--hair); border-radius: 24px; padding: 24px; }
.plate > svg { display: block; width: 100%; height: auto; }
.mark { color: var(--ink); }
.lockup .mark { color: inherit; }
.big { display: flex; justify-content: center; padding: 24px 0; }
.big svg { height: 200px; width: auto; }
.ladder { display: flex; flex-wrap: wrap; align-items: flex-end; gap: 24px; }
.ladder + .ladder { margin-top: 24px; }
.ladder figure { margin: 0; display: flex; flex-direction: column; align-items: center; gap: 8px; }
.ladder figcaption { font-size: 11px; color: var(--ink2); }
.lockup { display: flex; flex-direction: column; align-items: center; gap: 12px; padding: 32px 0; border-radius: 16px; }
.lockup svg { height: 72px; width: auto; }
.lockup span { font: 400 44px/1 "Instrument Serif", serif; }
.lockup.light { background: #FAF9F7; color: #16181A; }
.lockup.dark { background: #1C1B19; color: #ECEBE8; }
.canvas { display: flex; justify-content: center; }
.canvas svg { width: 324px; max-width: 100%; height: auto; }
.wall { border-radius: 24px; padding: 24px; display: flex; flex-wrap: wrap; gap: 20px 24px; align-items: flex-end; }
.wall + .wall { margin-top: 16px; }
.wall figure { margin: 0; width: 72px; display: flex; flex-direction: column; align-items: center; gap: 6px; }
.wall figcaption { font-size: 11px; line-height: 1.3; text-align: center; }
.wall .gap { flex-basis: 100%; height: 0; }
.wall-light { background: #E4E1DC; color: #16181A; }
.wall-dark { background: #0E0F11; color: #ECEBE8; }
.wall-busy {
  color: #FFFFFF; text-shadow: 0 1px 2px rgba(0, 0, 0, .7);
  background: radial-gradient(circle at 18% 30%, #D98E4A, transparent 45%),
    radial-gradient(circle at 82% 22%, #3F6FA8, transparent 50%),
    radial-gradient(circle at 55% 95%, #2F6B4F, transparent 55%), #6B5A7A;
}
.wall-themed-light { background: #EEF1F6; color: #1A1C1E; }
.wall-themed-dark { background: #111418; color: #E2E2E6; }
''';
