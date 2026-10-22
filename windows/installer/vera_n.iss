; Vera N for Windows: the setup .exe for GitHub releases (docs/LAPTOP_PLAN.md,
; L5; Inno Setup chosen by the user, 2026-10-11).
; Build it with tool/build_windows_installer.ps1, which passes the version
; from pubspec.yaml. It packs the release build as it is.
;
; - Installs for the current user only (no admin prompt), in
;   %LOCALAPPDATA%\Programs\Vera N.
; - Uninstalling removes the app and its window placement, never the
;   user's notes (in the folder they picked) or the app's database.

#ifndef AppVersion
  #define AppVersion "1.0.1"
#endif
#define AppName "Vera N"
#define AppExe "vera_n.exe"
#define Root ".."

[Setup]
; Never change AppId: it is how an update recognises the installed app.
AppId={{421A2EF9-BF05-4C38-9FB6-D08527028A75}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
AppPublisher={#AppName}
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
OutputDir={#Root}\..\build\installer
OutputBaseFilename=VeraN-Setup-{#AppVersion}
SetupIconFile={#Root}\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\{#AppExe}
UninstallDisplayName={#AppName}
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
CloseApplications=yes

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#Root}\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#AppName}"; Filename: "{app}\{#AppExe}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExe}"; Tasks: desktopicon

[Registry]
; The window placement the runner saves (window_placement.cpp); removed on
; uninstall.
Root: HKCU; Subkey: "Software\Vera N"; Flags: uninsdeletekey

[Run]
Filename: "{app}\{#AppExe}"; Description: "{cm:LaunchProgram,{#AppName}}"; Flags: nowait postinstall skipifsilent
