set(CPACK_NSIS_EXECUTIONLEVEL "user")
set(CPACK_NSIS_DEFINES [[
Var InstallScope
Var ReisenRoot
Page custom SelectInstallScope
Page directory
Page custom SelectRootFolder

Function SelectInstallScope
    MessageBox MB_ICONQUESTION|MB_YESNO "ReiseManager für alle Benutzer installieren?\nDiese Option benötigt Administratorrechte." IDYES InstallAll
    StrCpy $InstallScope "current"
    StrCpy $INSTDIR "$LOCALAPPDATA\ReiseManager"
    Abort
InstallAll:
    StrCpy $InstallScope "all"
    StrCpy $INSTDIR "$PROGRAMFILES64\ReiseManager"
    Abort
FunctionEnd

Function SelectRootFolder
    MessageBox MB_OK "Wählen Sie nun den Reisen-Ordner, in dem Ihre Reisen gespeichert werden."
    nsDialogs::SelectFolderDialog "Reisen-Ordner wählen" "$PROFILE"
    Pop $ReisenRoot
    StrCmp $ReisenRoot "" 0 +2
        StrCpy $ReisenRoot "$PROFILE\OneDrive - Körber AG\Reisen"
    Abort
FunctionEnd
]])

set(CPACK_NSIS_EXTRA_INSTALL_COMMANDS [[
    WriteRegStr HKCU "Software\ReiseManager" "InstallPath" "$INSTDIR"
    WriteRegStr HKCU "Software\ReiseManager" "RootReisenPath" "$ReisenRoot"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\ReiseManager" "DisplayName" "ReiseManager"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\ReiseManager" "UninstallString" "$INSTDIR\Uninstall.exe"
    WriteRegStr HKCU "Software\Classes\Directory\shell\ReiseManager.New" "" "Neue Reise erstellen"
    WriteRegStr HKCU "Software\Classes\Directory\shell\ReiseManager.New" "AppliesTo" "System.ItemPathDisplay='$ReisenRoot'"
    WriteRegStr HKCU "Software\Classes\Directory\shell\ReiseManager.New\command" "" '"$INSTDIR\ReiseManager.exe" --new'
    WriteRegStr HKCU "Software\Classes\Directory\shell\ReiseManager.Edit" "" "Reise bearbeiten"
    WriteRegStr HKCU "Software\Classes\Directory\shell\ReiseManager.Edit" "AppliesTo" "System.ItemPathDisplay='$ReisenRoot\*'"
    WriteRegStr HKCU "Software\Classes\Directory\shell\ReiseManager.Edit\command" "" '"$INSTDIR\ReiseManager.exe" --edit "%1"'
    WriteRegStr HKCU "Software\Classes\lnkfile\shell\ReiseManager.Edit" "" "Reise bearbeiten"
    WriteRegStr HKCU "Software\Classes\lnkfile\shell\ReiseManager.Edit\command" "" '"$INSTDIR\ReiseManager.exe" --edit "%1"'
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\{8AA0F2C2-7F91-4F62-BF55-3D2C3AA7EBDC}" "Name" "Reisen"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\{8AA0F2C2-7F91-4F62-BF55-3D2C3AA7EBDC}\TopViews\{00000000-0000-0000-0000-000000000000}" "ColumnList" "prop:System.ItemNameDisplay;System.Title;System.Company;System.Category;System.Calendar.Location;System.Duration;System.StartDate;System.EndDate;System.DateCreated"
]])

set(CPACK_NSIS_EXTRA_UNINSTALL_COMMANDS [[
    DeleteRegKey HKCU "Software\Classes\Directory\shell\ReiseManager.New"
    DeleteRegKey HKCU "Software\Classes\Directory\shell\ReiseManager.Edit"
    DeleteRegKey HKCU "Software\Classes\lnkfile\shell\ReiseManager.Edit"
    DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\{8AA0F2C2-7F91-4F62-BF55-3D2C3AA7EBDC}"
    DeleteRegKey HKCU "Software\ReiseManager"
    DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\ReiseManager"
    Delete "$INSTDIR\Uninstall.exe"
    RMDir /r "$INSTDIR"
]])
