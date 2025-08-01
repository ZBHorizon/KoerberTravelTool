; ============================================================
;  TravelManager – single-EXE installer
;  ------------------------------------------------------------
;   Per-user install by default (checkbox lets user elevate)
;   User can pick / create a “Travels” folder
;   Adds mandatory Explorer context-menu items   (New / Edit)
;   Creates Desktop.ini with custom icon + tooltip
;   Uninstaller removes registry keys & Desktop.ini
; ============================================================

#define MyAppName     "TravelManager"
#define MyAppExeName  "TravelManager.exe"
#define MyAppVersion  "0.1"

; ---------------------------------------------------------------------------
;  SETUP
; ---------------------------------------------------------------------------
[Setup]
AppName                      = {#MyAppName}
AppVersion                   = {#MyAppVersion}
DefaultDirName               = {code:GetInstallDir}
DefaultGroupName             = {#MyAppName}
OutputBaseFilename           = TravelManagerSetup
SetupIconFile                = ..\resources\Travel.ico
Compression                  = lzma
SolidCompression             = yes

; privilege handling per user unless user ticks the box
PrivilegesRequired           = lowest
PrivilegesRequiredOverridesAllowed = dialog

; ---------------------------------------------------------------------------
;  FILES & RUN
; ---------------------------------------------------------------------------
[Files]
Source: "..\install\*"; DestDir: "{app}"; Flags: recursesubdirs

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Launch TravelManager"; Flags: nowait postinstall skipifsilent

; ---------------------------------------------------------------------------
;  REGISTRY  (one physical line per entry!)
; ---------------------------------------------------------------------------
[Registry]

; -- Per-user settings -------------------------------------------------------
Root: HKCU; Subkey: "Software\TravelManager"; ValueType: string; ValueName: "InstallPath";      ValueData: "{app}";               Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\TravelManager"; ValueType: string; ValueName: "RootTravelsPath";  ValueData: "{code:GetTravelsRoot}"; Flags: uninsdeletevalue

;   Context-menu items HKCU\Software\Classes  (user area of HKCR)
Root: HKCU; Subkey: "Software\Classes\Directory\shell\TravelManager.New"; ValueType: string; ValueData: "Create new travel";               Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\Directory\shell\TravelManager.New\command"; ValueType: string; ValueData: """{app}\{#MyAppExeName}"" --new"; Flags: uninsdeletekey

Root: HKCU; Subkey: "Software\Classes\Directory\shell\TravelManager.Edit"; ValueType: string; ValueData: "Edit travel";                      Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\Directory\shell\TravelManager.Edit\command"; ValueType: string; ValueData: """{app}\{#MyAppExeName}"" --edit ""%1"""; Flags: uninsdeletekey

Root: HKCU; Subkey: "Software\Classes\lnkfile\shell\TravelManager.Edit"; ValueType: string; ValueData: "Edit travel";                      Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\lnkfile\shell\TravelManager.Edit\command"; ValueType: string; ValueData: """{app}\{#MyAppExeName}"" --edit ""%1"""; Flags: uninsdeletekey

; -- The *same* keys when Setup is elevated (HKLM) ---------------------------
Root: HKLM; Subkey: "Software\TravelManager"; ValueType: string; ValueName: "InstallPath";     ValueData: "{app}";                Flags: uninsdeletevalue; Check: IsAdminInstallMode
Root: HKLM; Subkey: "Software\TravelManager"; ValueType: string; ValueName: "RootTravelsPath"; ValueData: "{code:GetTravelsRoot}"; Flags: uninsdeletevalue; Check: IsAdminInstallMode

Root: HKLM; Subkey: "Software\Classes\Directory\shell\TravelManager.New"; ValueType: string; ValueData: "Create new travel";               Flags: uninsdeletekey; Check: IsAdminInstallMode
Root: HKLM; Subkey: "Software\Classes\Directory\shell\TravelManager.New\command"; ValueType: string; ValueData: """{app}\{#MyAppExeName}"" --new"; Flags: uninsdeletekey; Check: IsAdminInstallMode

Root: HKLM; Subkey: "Software\Classes\Directory\shell\TravelManager.Edit"; ValueType: string; ValueData: "Edit travel";                      Flags: uninsdeletekey; Check: IsAdminInstallMode
Root: HKLM; Subkey: "Software\Classes\Directory\shell\TravelManager.Edit\command"; ValueType: string; ValueData: """{app}\{#MyAppExeName}"" --edit ""%1"""; Flags: uninsdeletekey; Check: IsAdminInstallMode

Root: HKLM; Subkey: "Software\Classes\lnkfile\shell\TravelManager.Edit"; ValueType: string; ValueData: "Edit travel";                      Flags: uninsdeletekey; Check: IsAdminInstallMode
Root: HKLM; Subkey: "Software\Classes\lnkfile\shell\TravelManager.Edit\command"; ValueType: string; ValueData: """{app}\{#MyAppExeName}"" --edit ""%1"""; Flags: uninsdeletekey; Check: IsAdminInstallMode

; ---------------------------------------------------------------------------
;  SHORTCUTS (Start-menu group)
; ---------------------------------------------------------------------------
[Icons]
Name: "{group}\{#MyAppName}";           Filename: "{app}\{#MyAppExeName}"
Name: "{group}\Uninstall {#MyAppName}"; Filename: "{uninstallexe}"

; ---------------------------------------------------------------------------
;  CODE  (Pascal Script)
; ---------------------------------------------------------------------------
[Code]

{ ===================================================================
  GLOBALS
  =================================================================== }
var
  TravelsRoot : string;               // Folder chosen by the user
  PageTravels : TInputDirWizardPage;  // Folder picker wizard page
  PageInfo    : TOutputMsgWizardPage; // Info page
  ResultCode  : Integer;              // For Exec() return codes

{ -------------------------------------------------------------------
  Helper callbacks referenced in the .iss sections
------------------------------------------------------------------- }
function GetTravelsRoot(_: string): string;
begin
  Result := TravelsRoot;
end;

function GetInstallDir(_: string): string;
begin
  if IsAdminInstallMode then
    Result := ExpandConstant('{pf}\TravelManager')
  else
    Result := ExpandConstant('{localappdata}\TravelManager');
end;

{ -------------------------------------------------------------------
  WIZARD INITIALISATION create pages & defaults
------------------------------------------------------------------- }
procedure InitializeWizard;
var
  profile, defPath, infoMsg: string;
begin
  { choose sensible default path }
  profile := GetEnv('USERPROFILE');
  if (profile <> '') and DirExists(profile + '\OneDrive') then
    defPath := profile + '\OneDrive\Travels'
  else
    defPath := ExpandConstant('{userdocs}\Travels');
  TravelsRoot := defPath;

  { Page 1 folder picker }
  PageTravels := CreateInputDirPage(
                   wpSelectDir,
                   'Select Travels Folder',
                   'Where should your travel data be stored?',
                   'Choose or create the folder where TravelManager keeps all travel definitions.',
                   True, { allow New Folder } ''
                 );
  PageTravels.Add('');
  PageTravels.Values[0] := defPath;

  { Page 2  static info page }
  infoMsg :=
      'TravelManager adds the following context-menu shortcuts:' + #13#10#13#10 +
      '• Create new travel' + #13#10 +
      '• Edit travel'       + #13#10#13#10 +
      'These items appear on folders and shortcuts, allowing quick creation ' +
      'or editing of a travel definition.';

  PageInfo := CreateOutputMsgPage(
                PageTravels.ID,          // insert right after folder page
                'Explorer Integration',  // caption
                '',                      // description (optional)
                infoMsg                  // main message
              );
end;

{ -------------------------------------------------------------------
  Validate folder page before leaving
------------------------------------------------------------------- }
function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;                       // allow Next by default
  if CurPageID = PageTravels.ID then
  begin
    if DirExists(PageTravels.Values[0]) then
      TravelsRoot := PageTravels.Values[0]
    else
    begin
      MsgBox('The selected folder does not exist. Please choose a valid directory.',
             mbError, MB_OK);
      Result := False;                  // stay on the page
    end;
  end;
end;

{ -------------------------------------------------------------------
  POST-INSTALL create Desktop.ini & set attributes
------------------------------------------------------------------- }
procedure CurStepChanged(CurStep: TSetupStep);
var
  iniFile: string;
begin
  if CurStep = ssPostInstall then
  begin
    iniFile := TravelsRoot + '\Desktop.ini';
    SaveStringToFile(
      iniFile,
      '[.ShellClassInfo]'#13#10 +
      'IconResource=' + ExpandConstant('{app}\{#MyAppExeName}') + ',0'#13#10 +
      'IconFile='     + ExpandConstant('{app}\{#MyAppExeName}')       + #13#10 +
      'IconIndex=0'#13#10 +
      'InfoTip=Folder containing all Travel definitions.',
      False);  // do not overwrite user's own desktop.ini

    Exec('cmd.exe', '/C attrib +h +s "' + iniFile   + '"', '', SW_HIDE,
         ewWaitUntilTerminated, ResultCode);
    Exec('cmd.exe', '/C attrib +s "'  + TravelsRoot + '"', '', SW_HIDE,
         ewWaitUntilTerminated, ResultCode);
  end;
end;

{ -------------------------------------------------------------------
  UNINSTALLER remove Desktop.ini and folder (if empty)
------------------------------------------------------------------- }
procedure DeinitializeUninstall;
var
  rootPath, iniFile: string;
begin
  if RegQueryStringValue(HKCU, 'Software\TravelManager', 'RootTravelsPath', rootPath) or
     RegQueryStringValue(HKLM, 'Software\TravelManager', 'RootTravelsPath', rootPath) then
  begin
    iniFile := rootPath + '\Desktop.ini';
    if FileExists(iniFile) then DeleteFile(iniFile);
    RemoveDir(rootPath);          // silently fails if not empty
  end;
end;
