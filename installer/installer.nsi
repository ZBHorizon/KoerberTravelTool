!define APP_NAME "ReiseManager"
!define APP_EXE "ReiseManager.exe"
!define INSTALL_DIR_REGKEY "HKCU\\Software\\ReiseManager"
!define INSTALL_DIR_REGVALUE "InstallPath"
!define ROOT_DIR_REGVALUE "RootReisenPath"

Outfile "${APP_NAME}Setup.exe"
Icon "..\\resources\\Reise.ico"
UninstallIcon "..\\resources\\Reise.ico"
InstallDir $LOCALAPPDATA\\${APP_NAME}
RequestExecutionLevel user

Page custom SelectRootFolder
Page directory
Page instfiles

Var ReisenRoot

Function SelectRootFolder
    nsDialogs::SelectFolderDialog "Wählen Sie den Reisen-Ordner" "$PROFILE"
    Pop $ReisenRoot
    StrCmp $ReisenRoot "" 0 +2
        StrCpy $ReisenRoot "$PROFILE\\OneDrive - Körber AG\\Reisen"
    ; Dialog immediat nach Auswahl schließen
    Abort
FunctionEnd

Section "Install"
    SetOutPath "$INSTDIR"
    File /r "bin\\*"
    WriteRegStr HKCU "Software\\ReiseManager" "${INSTALL_DIR_REGVALUE}" "$INSTDIR"
    WriteRegStr HKCU "Software\\ReiseManager" "${ROOT_DIR_REGVALUE}" "$ReisenRoot"

    ; create uninstaller
    WriteUninstaller "$INSTDIR\\Uninstall.exe"
    WriteRegStr HKCU "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\ReiseManager" "DisplayName" "ReiseManager"
    WriteRegStr HKCU "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\ReiseManager" "UninstallString" "$INSTDIR\\Uninstall.exe"

    ; context menu "Neue Reise"
    WriteRegStr HKCU "Software\\Classes\\Directory\\shell\\ReiseManager.New" "" "Neue Reise erstellen"
    WriteRegStr HKCU "Software\\Classes\\Directory\\shell\\ReiseManager.New" "AppliesTo" "System.ItemPathDisplay:='$ReisenRoot'"
    WriteRegStr HKCU "Software\\Classes\\Directory\\shell\\ReiseManager.New\\command" "" '"$INSTDIR\\${APP_EXE}" --new'

    ; context menu "Reise bearbeiten" for folders
    WriteRegStr HKCU "Software\\Classes\\Directory\\shell\\ReiseManager.Edit" "" "Reise bearbeiten"
    WriteRegStr HKCU "Software\\Classes\\Directory\\shell\\ReiseManager.Edit" "AppliesTo" "System.ItemPathDisplay:='$ReisenRoot\\*'"
    WriteRegStr HKCU "Software\\Classes\\Directory\\shell\\ReiseManager.Edit\\command" "" '"$INSTDIR\\${APP_EXE}" --edit "%1"'
    ; for lnk files
    WriteRegStr HKCU "Software\\Classes\\lnkfile\\shell\\ReiseManager.Edit" "" "Reise bearbeiten"
    WriteRegStr HKCU "Software\\Classes\\lnkfile\\shell\\ReiseManager.Edit\\command" "" '"$INSTDIR\\${APP_EXE}" --edit "%1"'

    ; custom columns for Reisen folder
    WriteRegStr HKCU "Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\FolderTypes\\{8AA0F2C2-7F91-4F62-BF55-3D2C3AA7EBDC}" "Name" "Reisen"
    WriteRegStr HKCU "Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\FolderTypes\\{8AA0F2C2-7F91-4F62-BF55-3D2C3AA7EBDC}\\TopViews\\{00000000-0000-0000-0000-000000000000}" "ColumnList" "prop:System.ItemNameDisplay;System.Title;System.Company;System.Category;System.Calendar.Location;System.Duration;System.StartDate;System.EndDate;System.DateCreated"
SectionEnd

Section "Uninstall"
    DeleteRegKey HKCU "Software\\Classes\\Directory\\shell\\ReiseManager.New"
    DeleteRegKey HKCU "Software\\Classes\\Directory\\shell\\ReiseManager.Edit"
    DeleteRegKey HKCU "Software\\Classes\\lnkfile\\shell\\ReiseManager.Edit"
    DeleteRegKey HKCU "Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\FolderTypes\\{8AA0F2C2-7F91-4F62-BF55-3D2C3AA7EBDC}"
    DeleteRegKey HKCU "Software\\ReiseManager"
    DeleteRegKey HKCU "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\ReiseManager"
    Delete "$INSTDIR\\Uninstall.exe"
    RMDir /r "$INSTDIR"
SectionEnd
