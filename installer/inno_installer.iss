#define MyAppName "TravelManager"
#define MyAppExeName "TravelManager.exe"
#define MyAppVersion "0.1"

[Setup]
AppName={#MyAppName}
AppVersion={#MyAppVersion}
DefaultDirName={code:GetInstallDir}
DefaultGroupName={#MyAppName}
OutputBaseFilename=TravelManagerSetup
SetupIconFile=..\\resources\\Travel.ico
PrivilegesRequired=admin
PrivilegesRequiredOverridesAllowed=dialog
Compression=lzma
SolidCompression=yes

[Files]
Source: "..\\install\\*"; DestDir: "{app}"; Flags: recursesubdirs

[Run]
Filename: "{app}\\{#MyAppExeName}"; Description: "{cm:LaunchProgram,TravelManager}"; Flags: nowait postinstall skipifsilent

[Registry]
; Entries for machine-wide install (administrative)
Root: HKLM; Subkey: "Software\\TravelManager"; ValueType: string; ValueName: "InstallPath"; ValueData: "{app}"; Flags: uninsdeletevalue; Check: IsAdminInstallMode
Root: HKLM; Subkey: "Software\\TravelManager"; ValueType: string; ValueName: "RootTravelsPath"; ValueData: "{code:GetTravelsRoot}"; Flags: uninsdeletevalue; Check: IsAdminInstallMode
Root: HKLM; Subkey: "Software\\Classes\\Directory\\shell\\TravelManager.New"; ValueType: string; ValueData: "Create new travel"; Flags: uninsdeletekey; Check: IsAdminInstallMode
Root: HKLM; Subkey: "Software\\Classes\\Directory\\shell\\TravelManager.New"; ValueType: string; ValueName: "AppliesTo"; ValueData: "System.ItemPathDisplay:='{code:GetTravelsRoot}'"; Flags: uninsdeletevalue; Check: IsAdminInstallMode
Root: HKLM; Subkey: "Software\\Classes\\Directory\\shell\\TravelManager.New\\command"; ValueType: string; ValueData: '"{app}\\{#MyAppExeName}" --new'; Flags: uninsdeletekey; Check: IsAdminInstallMode
Root: HKLM; Subkey: "Software\\Classes\\Directory\\shell\\TravelManager.Edit"; ValueType: string; ValueData: "Edit travel"; Flags: uninsdeletekey; Check: IsAdminInstallMode
Root: HKLM; Subkey: "Software\\Classes\\Directory\\shell\\TravelManager.Edit"; ValueType: string; ValueName: "AppliesTo"; ValueData: "System.ItemPathDisplay:='{code:GetTravelsRoot}\\*'"; Flags: uninsdeletevalue; Check: IsAdminInstallMode
Root: HKLM; Subkey: "Software\\Classes\\Directory\\shell\\TravelManager.Edit\\command"; ValueType: string; ValueData: '"{app}\\{#MyAppExeName}" --edit "%1"'; Flags: uninsdeletekey; Check: IsAdminInstallMode
Root: HKLM; Subkey: "Software\\Classes\\lnkfile\\shell\\TravelManager.Edit"; ValueType: string; ValueData: "Edit travel"; Flags: uninsdeletekey; Check: IsAdminInstallMode
Root: HKLM; Subkey: "Software\\Classes\\lnkfile\\shell\\TravelManager.Edit\\command"; ValueType: string; ValueData: '"{app}\\{#MyAppExeName}" --edit "%1"'; Flags: uninsdeletekey; Check: IsAdminInstallMode
Root: HKLM; Subkey: "Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\FolderTypes\\{8AA0F2C2-7F91-4F62-BF55-3D2C3AA7EBDC}"; ValueType: string; ValueName: "Name"; ValueData: "Travels"; Flags: uninsdeletekey; Check: IsAdminInstallMode
Root: HKLM; Subkey: "Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\FolderTypes\\{8AA0F2C2-7F91-4F62-BF55-3D2C3AA7EBDC}\\TopViews\\{00000000-0000-0000-0000-000000000000}"; ValueType: string; ValueName: "ColumnList"; ValueData: "prop:System.ItemNameDisplay;System.Title;System.Company;System.Category;System.Calendar.Location;System.Duration;System.StartDate;System.EndDate;System.DateCreated"; Flags: uninsdeletevalue; Check: IsAdminInstallMode

; Entries for per-user install
Root: HKCU; Subkey: "Software\\TravelManager"; ValueType: string; ValueName: "InstallPath"; ValueData: "{app}"; Flags: uninsdeletevalue; Check: not IsAdminInstallMode
Root: HKCU; Subkey: "Software\\TravelManager"; ValueType: string; ValueName: "RootTravelsPath"; ValueData: "{code:GetTravelsRoot}"; Flags: uninsdeletevalue; Check: not IsAdminInstallMode
Root: HKCU; Subkey: "Software\\Classes\\Directory\\shell\\TravelManager.New"; ValueType: string; ValueData: "Create new travel"; Flags: uninsdeletekey; Check: not IsAdminInstallMode
Root: HKCU; Subkey: "Software\\Classes\\Directory\\shell\\TravelManager.New"; ValueType: string; ValueName: "AppliesTo"; ValueData: "System.ItemPathDisplay:='{code:GetTravelsRoot}'"; Flags: uninsdeletevalue; Check: not IsAdminInstallMode
Root: HKCU; Subkey: "Software\\Classes\\Directory\\shell\\TravelManager.New\\command"; ValueType: string; ValueData: '"{app}\\{#MyAppExeName}" --new'; Flags: uninsdeletekey; Check: not IsAdminInstallMode
Root: HKCU; Subkey: "Software\\Classes\\Directory\\shell\\TravelManager.Edit"; ValueType: string; ValueData: "Edit travel"; Flags: uninsdeletekey; Check: not IsAdminInstallMode
Root: HKCU; Subkey: "Software\\Classes\\Directory\\shell\\TravelManager.Edit"; ValueType: string; ValueName: "AppliesTo"; ValueData: "System.ItemPathDisplay:='{code:GetTravelsRoot}\\*'"; Flags: uninsdeletevalue; Check: not IsAdminInstallMode
Root: HKCU; Subkey: "Software\\Classes\\Directory\\shell\\TravelManager.Edit\\command"; ValueType: string; ValueData: '"{app}\\{#MyAppExeName}" --edit "%1"'; Flags: uninsdeletekey; Check: not IsAdminInstallMode
Root: HKCU; Subkey: "Software\\Classes\\lnkfile\\shell\\TravelManager.Edit"; ValueType: string; ValueData: "Edit travel"; Flags: uninsdeletekey; Check: not IsAdminInstallMode
Root: HKCU; Subkey: "Software\\Classes\\lnkfile\\shell\\TravelManager.Edit\\command"; ValueType: string; ValueData: '"{app}\\{#MyAppExeName}" --edit "%1"'; Flags: uninsdeletekey; Check: not IsAdminInstallMode
Root: HKCU; Subkey: "Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\FolderTypes\\{8AA0F2C2-7F91-4F62-BF55-3D2C3AA7EBDC}"; ValueType: string; ValueName: "Name"; ValueData: "Travels"; Flags: uninsdeletekey; Check: not IsAdminInstallMode
Root: HKCU; Subkey: "Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\FolderTypes\\{8AA0F2C2-7F91-4F62-BF55-3D2C3AA7EBDC}\\TopViews\\{00000000-0000-0000-0000-000000000000}"; ValueType: string; ValueName: "ColumnList"; ValueData: "prop:System.ItemNameDisplay;System.Title;System.Company;System.Category;System.Calendar.Location;System.Duration;System.StartDate;System.EndDate;System.DateCreated"; Flags: uninsdeletevalue; Check: not IsAdminInstallMode

[Code]
var
  TravelsRoot: string;

function GetTravelsRoot(Param: string): string;
begin
  Result := TravelsRoot;
end;

function GetInstallDir(Param: string): string;
begin
  if IsAdminInstallMode then
    Result := ExpandConstant('{pf}\\TravelManager')
  else
    Result := ExpandConstant('{localappdata}\\TravelManager');
end;

procedure InitializeWizard();
begin
  TravelsRoot := ExpandConstant('{userprofile}\\OneDrive - Koerber AG\\Travels');
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssInstall then
  begin
    TravelsRoot := BrowseForFolder('Select the travels folder', TravelsRoot, 0);
    if TravelsRoot = '' then
      TravelsRoot := ExpandConstant('{userprofile}\\OneDrive - Koerber AG\\Travels');
  end
  else if CurStep = ssPostInstall then
  begin
    SaveStringToFile(TravelsRoot + '\\Desktop.ini', '[.ShellClassInfo]'#13#10'IconResource=' + ExpandConstant('{app}\\{#MyAppExeName},0'), False);
    FileSetAttr(TravelsRoot + '\\Desktop.ini', FILE_ATTRIBUTE_HIDDEN);
    FileSetAttr(TravelsRoot, FILE_ATTRIBUTE_SYSTEM);
  end;
end;

procedure InitializeUninstall();
begin
  if RegQueryStringValue(HKLM, 'Software\\TravelManager', 'RootTravelsPath', TravelsRoot) then
    Exit;
  RegQueryStringValue(HKCU, 'Software\\TravelManager', 'RootTravelsPath', TravelsRoot);
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then
  begin
    if FileExists(TravelsRoot + '\\Desktop.ini') then
      DeleteFile(TravelsRoot + '\\Desktop.ini');
    FileSetAttr(TravelsRoot, FILE_ATTRIBUTE_DIRECTORY);
  end;
end;
