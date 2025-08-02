#define MyAppName "TravelManager"
#define MyAppExeName "TravelManager.exe"
#define MyAppVersion "0.1"

[Setup]
AppName            = {#MyAppName}
AppVersion         = {#MyAppVersion}
DefaultDirName     = {code:GetInstallDir}
DefaultGroupName   = {#MyAppName}
OutputBaseFilename = TravelManagerSetup
SetupIconFile      = ..\\resources\\Travel.ico
Compression        = lzma
SolidCompression   = yes
PrivilegesRequired = lowest
PrivilegesRequiredOverridesAllowed = dialog

[Files]
Source: "..\install\*"; DestDir: "{app}"; Flags: recursesubdirs

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#MyAppName}}"; Flags: nowait postinstall skipifsilent

[Registry]
// System-wide entries (if installed with admin rights)
Root: HKLM; Subkey: "Software\TravelManager"; ValueType: string; ValueName: "InstallPath"; ValueData: "{app}"; Flags: uninsdeletevalue; Check: IsAdminInstallMode
Root: HKLM; Subkey: "Software\TravelManager"; ValueType: string; ValueName: "RootTravelsPath"; ValueData: "{code:GetTravelsRoot}"; Flags: uninsdeletevalue; Check: IsAdminInstallMode

// Per-user entries (default)
Root: HKCU; Subkey: "Software\TravelManager"; ValueType: string; ValueName: "InstallPath"; ValueData: "{app}"; Flags: uninsdeletevalue; Check: not IsAdminInstallMode
Root: HKCU; Subkey: "Software\TravelManager"; ValueType: string; ValueName: "RootTravelsPath"; ValueData: "{code:GetTravelsRoot}"; Flags: uninsdeletevalue; Check: not IsAdminInstallMode

[Code]
var
  TravelsRoot: string;
  ResultCode: Integer;
  PageTravelsRoot: TInputDirWizardPage;

function GetDefaultTravelsRoot(): string;
begin
  Result := ExpandConstant('{userdocs}\Travels');
end;

function GetTravelsRoot(Param: string): string;
begin
  Result := TravelsRoot;
end;

function GetInstallDir(Param: string): string;
begin
  if IsAdminInstallMode then
    Result := ExpandConstant('{pf}\TravelManager')
  else
    Result := ExpandConstant('{localappdata}\TravelManager');
end;

procedure InitializeWizard;
begin
  // Allow user to select the Travels root folder
  PageTravelsRoot := CreateInputDirPage(
    wpSelectDir,
    'Select Travels Folder',
    'Where should your travel data be stored?',
    'Choose the folder for TravelManager to store travel definitions.',
    False, ''
  );
  PageTravelsRoot.Add('');
  PageTravelsRoot.Values[0] := GetDefaultTravelsRoot();
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID = PageTravelsRoot.ID then
  begin
    // Validate folder selection
    if DirExists(PageTravelsRoot.Values[0]) then
      TravelsRoot := PageTravelsRoot.Values[0]
    else
    begin
      MsgBox('The selected folder does not exist. Please choose a valid directory.', mbError, MB_OK);
      PageTravelsRoot.Values[0] := GetDefaultTravelsRoot();
    end;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  iniFile: string;
begin
  if CurStep = ssPostInstall then
  begin
    iniFile := TravelsRoot + '\Desktop.ini';
    SaveStringToFile(
      iniFile,
      '[.ShellClassInfo]' + #13#10 +
      'IconResource=' + ExpandConstant('{app}\{#MyAppExeName},0') + #13#10 +
      'IconFile='     + ExpandConstant('{app}\{#MyAppExeName}') + #13#10 +
      'IconIndex=0' + #13#10 +
      'InfoTip=Folder containing all Travel definitions.',
      False
    );
    Exec('cmd.exe', '/C attrib +S +H "' + iniFile + '"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
    Exec('cmd.exe', '/C attrib +S "' + TravelsRoot + '"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  end;
end;

procedure InitializeUninstallProgressForm;
begin
  if RegQueryStringValue(HKLM, 'Software\TravelManager', 'RootTravelsPath', TravelsRoot) then
    exit;
  RegQueryStringValue(HKCU, 'Software\TravelManager', 'RootTravelsPath', TravelsRoot);
end;
