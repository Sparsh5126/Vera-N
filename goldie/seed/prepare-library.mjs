// Gives a store flow the same starting point every time: the test app's
// data cleared, then the demo notes (goldie/seed/notes, all made up) put in
// its private notes folder, with last-changed dates spread over the past
// weeks. The app's next launch shows onboarding and indexes the notes, as
// it would notes copied in by another app.
import { readdirSync, readFileSync, statSync } from "node:fs";
import { join, relative } from "node:path";
import { adb, appId, asApp, repoRoot } from "./adb.mjs";

const notesDir = join(repoRoot, "goldie", "seed", "notes");
const target = "files/MyNotes/Notes";

/// Days since each note last changed, so Home reads like real use.
const daysAgo = {
  "20261016-184522-0d91": 0,
  "20261014-230812-e41f": 1,
  "20261015-200930-f3a6": 2,
  "20261012-221004-9b7e": 4,
  "20261010-210145-b6c3": 5,
  "20261008-063015-c7e2": 7,
  "20261001-193300-2fa8": 9,
  "20260925-070230-a9d5": 15,
  "20260918-120455-71b0": 18,
  "20260921-081530-3c1a": 21,
  "20260912-190040-4b18": 25,
  "20260905-174210-5d22": 33,
  "20260830-131210-8e4c": 40,
};

function walk(dir) {
  return readdirSync(dir).flatMap((name) => {
    const path = join(dir, name);
    return statSync(path).isDirectory() ? walk(path) : name.endsWith(".md") ? [path] : [];
  });
}

/// A local time `days` ago, in the form Android's touch keeps the time in.
function stamp(days) {
  const t = new Date(Date.now() - days * 86400000 - 3600000);
  const two = (n) => String(n).padStart(2, "0");
  return `${t.getFullYear()}-${two(t.getMonth() + 1)}-${two(t.getDate())}T${two(t.getHours())}:${two(t.getMinutes())}:00`;
}

adb(["shell", "pm", "clear", appId]);
const files = walk(notesDir);
for (const file of files) {
  const path = relative(notesDir, file).replace(/\\/g, "/");
  const id = path.split("/").pop().replace(/\.md$/, "");
  const dest = `${target}/${path}`;
  const folder = dest.slice(0, dest.lastIndexOf("/"));
  // Files are LF and UTF-8, as the app writes them.
  const text = readFileSync(file, "utf8").replace(/\r\n/g, "\n");
  asApp(`mkdir -p ${folder} && cat > ${dest} && touch -d ${stamp(daysAgo[id] ?? 3)} ${dest}`, text);
}
console.log(`cleared the app and seeded ${files.length} notes`);
