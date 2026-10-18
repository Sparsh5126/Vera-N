// Runs the app's background analysis now instead of waiting for the
// charger: forces the WorkManager jobs Vera N queued when it was left, and
// waits for "VeraN analysis: run finished, all done: true" in the log.
// Run by the store flows after they leave the app.
import { adb, appId, sleep } from "./adb.mjs";

const timeoutMs = 240000;

/// The app's queued jobs as [namespace, id]. Android 14 and later list
/// WorkManager's as `JOB androidx.work.systemjobscheduler:u0a227/0: …`;
/// earlier versions as `JOB #u0a227/0: …`, with no namespace.
function queuedJobs() {
  const dump = adb(["shell", "dumpsys", "jobscheduler", appId]);
  const jobs = new Map();
  const line = /JOB (?:([\w.]+):)?#?u\d+a\d+\/(\d+):[^\n]*io\.github\.sparsh5126\.veran\.perf\//g;
  for (const [, namespace, id] of dump.matchAll(line)) jobs.set(`${namespace}/${id}`, [namespace, id]);
  return [...jobs.values()];
}

function force([namespace, id]) {
  const ns = namespace ? ["-n", namespace] : [];
  adb(["shell", "cmd", "jobscheduler", "run", "-f", ...ns, appId, id]);
}

adb(["logcat", "-c"]);
const started = Date.now();
let runs = 0;
let lastForced = 0;
let finished = false;
// argent runs this as a flow step, so it must end by returning, never
// process.exit().
while (!finished) {
  if (Date.now() - started > timeoutMs) {
    throw new Error(`analysis did not finish within ${timeoutMs / 1000} s`);
  }
  // Force again only if a run hasn't finished well after the last one, so
  // a run in progress is never interrupted.
  if (Date.now() - lastForced > 30000) {
    const jobs = queuedJobs();
    jobs.forEach(force);
    if (jobs.length > 0) {
      runs++;
      lastForced = Date.now();
    }
  }
  await sleep(3000);
  const log = adb(["logcat", "-d", "-s", "flutter:I"]);
  if (log.includes("VeraN analysis: run finished, all done: true")) {
    console.log(`analysis finished after ${Math.round((Date.now() - started) / 1000)} s (${runs} forced runs)`);
    finished = true;
  }
  const failed = log.match(/VeraN analysis: run failed: .*/);
  if (failed) throw new Error(failed[0]);
}
