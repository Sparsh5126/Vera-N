// adb for the goldie seed scripts: the SDK from android/local.properties,
// and the device from ANDROID_SERIAL or the one emulator that is running.
import { execFileSync, spawnSync } from "node:child_process";
import { existsSync, readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

export const repoRoot = join(dirname(fileURLToPath(import.meta.url)), "..", "..");

/// The test app goldie captures: the profile build's own id, so real notes
/// are never involved (android/app/build.gradle.kts, `vera.perf`).
export const appId = "com.example.vera_n.perf";

function sdkDir() {
  const props = join(repoRoot, "android", "local.properties");
  const line = readFileSync(props, "utf8").split(/\r?\n/).find((l) => l.startsWith("sdk.dir="));
  if (!line) throw new Error("sdk.dir is missing from android/local.properties");
  return line.slice("sdk.dir=".length).replace(/\\\\/g, "\\").replace(/\\:/g, ":");
}

const adbPath = (() => {
  const exe = process.platform === "win32" ? "adb.exe" : "adb";
  const path = join(sdkDir(), "platform-tools", exe);
  return existsSync(path) ? path : exe;
})();

const serial = (() => {
  if (process.env.ANDROID_SERIAL) return process.env.ANDROID_SERIAL;
  const lines = execFileSync(adbPath, ["devices"], { encoding: "utf8" }).split(/\r?\n/);
  const devices = lines.slice(1).filter((l) => l.endsWith("\tdevice")).map((l) => l.split("\t")[0]);
  if (devices.length !== 1) {
    throw new Error(`expected one device, found ${devices.length}; set ANDROID_SERIAL`);
  }
  return devices[0];
})();

/// Runs adb on the device and returns its output; throws on failure.
export function adb(args, input) {
  const result = spawnSync(adbPath, ["-s", serial, ...args], {
    input,
    encoding: "utf8",
    maxBuffer: 64 * 1024 * 1024,
  });
  if (result.status !== 0) {
    throw new Error(`adb ${args.join(" ")} failed: ${result.stderr || result.stdout}`);
  }
  return result.stdout;
}

/// A shell command run as the app, inside its private data directory.
/// The device's shell parses the line, so the command goes to `sh -c` as
/// one double-quoted string; `input` arrives on its stdin.
export function asApp(command, input) {
  const quoted = command.replace(/(["\\$`])/g, "\\$1");
  return adb(["shell", `run-as ${appId} sh -c "${quoted}"`], input);
}

export const sleep = (ms) => new Promise((done) => setTimeout(done, ms));
