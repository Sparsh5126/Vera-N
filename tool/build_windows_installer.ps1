# Builds the Windows setup .exe for a GitHub release (docs/LAPTOP_PLAN.md, L5):
# a release build, then Inno Setup packs it into build\installer.
# Needs Inno Setup 6 (winget install JRSoftware.InnoSetup).
# Run from the repository root: .\tool\build_windows_installer.ps1

# Failures are caught from exit codes below. (Not $ErrorActionPreference =
# 'Stop': in Windows PowerShell 5.1 it treats flutter's stderr notices as
# fatal.)
$root = Split-Path $PSScriptRoot -Parent

$iscc = @(
    "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
    "$env:ProgramFiles\Inno Setup 6\ISCC.exe",
    "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $iscc) {
    throw 'Inno Setup 6 not found. Install it with: winget install JRSoftware.InnoSetup'
}

# The version without the build number: "1.0.0+2" -> "1.0.0".
$line = Select-String -Path "$root\pubspec.yaml" -Pattern '^version:\s*(\S+)'
$version = $line.Matches[0].Groups[1].Value.Split('+')[0]

Push-Location $root
try {
    flutter build windows --release
    if ($LASTEXITCODE -ne 0) { throw 'flutter build windows failed' }
    & $iscc "/DAppVersion=$version" "windows\installer\vera_n.iss"
    if ($LASTEXITCODE -ne 0) { throw 'Inno Setup failed' }
} finally {
    Pop-Location
}

$setup = Get-Item "$root\build\installer\VeraN-Setup-$version.exe"
'{0} ({1:N1} MB)' -f $setup.FullName, ($setup.Length / 1MB)
