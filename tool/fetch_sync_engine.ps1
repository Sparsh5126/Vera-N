# Fetches the sync engine Vera N ships (docs/LAPTOP_PLAN.md, S1): Syncthing
# (MPL-2.0). Windows: the official release. Android: the Android build from
# Syncthing-Fork (libsyncthingnative.so), made for Android's rules.
# Each file is checked against a pinned SHA-256; the binaries are not in git.
#
# Usage: powershell -File tool/fetch_sync_engine.ps1
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$version = '2.1.6'
$forkVersion = '2.1.6.0'
$tmp = Join-Path ([IO.Path]::GetTempPath()) "vera-n-sync-engine"
New-Item -ItemType Directory -Force $tmp | Out-Null

# Pinned hashes of the files Vera N ships (checked 2026-10-16).
$pinned = @{
  'windows' = 'e33d934db704c9a3c7c46488d34ba655d676ac17234f01f3025740ffa4655dae'
  'arm64-v8a' = '7edcabbd3c02b6bb6829fb217b57cba52cb063021dd895221b42b4d3dd1d3864'
  'armeabi-v7a' = 'd9c252023056159ff1913c8c491d6dd79717b1242302a4c2ee5730038f4bde11'
  'x86_64' = '88bf4bfeefd6bdcd1ab6e4a51e61cd6e705bd0526700ebd7db41ae665190fa26'
}

function Check($file, $key) {
  $got = (Get-FileHash $file -Algorithm SHA256).Hash.ToLower()
  if ($got -ne $pinned[$key]) { throw "${key}: hash mismatch ($got)" }
  Write-Host "$key ok"
}

# Windows: the official zip.
$zip = Join-Path $tmp "syncthing-windows-amd64-v$version.zip"
Invoke-WebRequest "https://github.com/syncthing/syncthing/releases/download/v$version/syncthing-windows-amd64-v$version.zip" -OutFile $zip -UseBasicParsing
Expand-Archive $zip -DestinationPath (Join-Path $tmp 'win') -Force
$exe = Join-Path $tmp "win\syncthing-windows-amd64-v$version\syncthing.exe"
Check $exe 'windows'
$winDest = Join-Path $root 'windows\sync_engine'
New-Item -ItemType Directory -Force $winDest | Out-Null
Copy-Item $exe (Join-Path $winDest 'syncthing.exe') -Force

# Android: the native library out of each per-CPU Syncthing-Fork APK.
Add-Type -AssemblyName System.IO.Compression.FileSystem
foreach ($abi in 'arm64-v8a', 'armeabi-v7a', 'x86_64') {
  $apk = Join-Path $tmp "fork-$abi.apk"
  Invoke-WebRequest "https://github.com/researchxxl/syncthing-android/releases/download/v$forkVersion/com.github.catfriend1.syncthingfork_release_v${forkVersion}_$abi.apk" -OutFile $apk -UseBasicParsing
  $z = [IO.Compression.ZipFile]::OpenRead($apk)
  try {
    $entry = $z.GetEntry("lib/$abi/libsyncthingnative.so")
    $dest = Join-Path $root "android\app\src\main\jniLibs\$abi"
    New-Item -ItemType Directory -Force $dest | Out-Null
    $out = Join-Path $dest 'libsyncthingnative.so'
    [IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $out, $true)
  } finally { $z.Dispose() }
  Check $out $abi
}
Write-Host 'sync engine ready'
