!define APP_NAME "ReiseManager"
!define APP_EXE "ReiseManager.exe"
!define INSTALL_DIR_REGKEY "Software\\ReiseManager"
!define INSTALL_DIR_REGVALUE "InstallPath"
!define ROOT_DIR_REGVALUE "RootReisenPath"

!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "nsDialogs.nsh"

Icon "..\\resources\\Reise.ico"
UninstallIcon "..\\resources\\Reise.ico"

!insertmacro MUI_PAGE_DIRECTORY
Page custom SelectRootFolder
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "German"

Var ReisenRoot

Function SelectRootFolder
    nsDialogs::SelectFolderDialog "Wählen Sie den Reisen-Ordner" "$PROFILE"
    Pop $ReisenRoot
    StrCmp $ReisenRoot "" 0 +2
        StrCpy $ReisenRoot "$PROFILE\\OneDrive - Körber AG\\Reisen"
    ; Dialog immediat nach Auswahl schließen
    Abort
FunctionEnd

Section "Common"
    SetOutPath "$INSTDIR"
    File /r "bin\\*"
    
    ; create uninstaller
    WriteUninstaller "$INSTDIR\\Uninstall.exe"
    WriteRegStr $RegRoot "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\ReiseManager" "DisplayName" "ReiseManager"
    WriteRegStr $RegRoot "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\ReiseManager" "UninstallString" "$INSTDIR\\Uninstall.exe"

    ; Store the installation path and Reisen folder
    WriteRegStr $RegRoot "${INSTALL_DIR_REGKEY}" "${INSTALL_DIR_REGVALUE}" "$INSTDIR"
    WriteRegStr $RegRoot "${INSTALL_DIR_REGKEY}" "${ROOT_DIR_REGVALUE}" "$ReisenRoot"

    ; context menu "Neue Reise"
    WriteRegStr $RegRoot "Software\\Classes\\Directory\\shell\\ReiseManager.New" "" "Neue Reise erstellen"
    WriteRegStr $RegRoot "Software\\Classes\\Directory\\shell\\ReiseManager.New" "AppliesTo" "System.ItemPathDisplay:='$ReisenRoot'"
    WriteRegStr $RegRoot "Software\\Classes\\Directory\\shell\\ReiseManager.New\\command" "" '"$INSTDIR\\${APP_EXE}" --new'

    ; context menu "Reise bearbeiten" for folders
    WriteRegStr $RegRoot "Software\\Classes\\Directory\\shell\\ReiseManager.Edit" "" "Reise bearbeiten"
    WriteRegStr $RegRoot "Software\\Classes\\Directory\\shell\\ReiseManager.Edit" "AppliesTo" "System.ItemPathDisplay:='$ReisenRoot\\*'"
    WriteRegStr $RegRoot "Software\\Classes\\Directory\\shell\\ReiseManager.Edit\\command" "" '"$INSTDIR\\${APP_EXE}" --edit "%1"'
    
    ; for lnk files
    WriteRegStr $RegRoot "Software\\Classes\\lnkfile\\shell\\ReiseManager.Edit" "" "Reise bearbeiten"
    WriteRegStr $RegRoot "Software\\Classes\\lnkfile\\shell\\ReiseManager.Edit\\command" "" '"$INSTDIR\\${APP_EXE}" --edit "%1"'

    ; custom columns for Reisen folder
    WriteRegStr $RegRoot "Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\FolderTypes\\{8AA0F2C2-7F91-4F62-BF55-3D2C3AA7EBDC}" "Name" "Reisen"
    WriteRegStr $RegRoot "Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\FolderTypes\\{8AA0F2C2-7F91-4F62-BF55-3D2C3AA7EBDC}\\TopViews\\{00000000-0000-0000-0000-000000000000}" "ColumnList" "prop:System.ItemNameDisplay;System.Title;System.Company;System.Category;System.Calendar.Location;System.Duration;System.StartDate;System.EndDate;System.DateCreated"
SectionEnd

Section "Uninstall"
    DeleteRegKey $RegRoot "Software\\Classes\\Directory\\shell\\ReiseManager.New"
    DeleteRegKey $RegRoot "Software\\Classes\\Directory\\shell\\ReiseManager.Edit"
    DeleteRegKey $RegRoot "Software\\Classes\\lnkfile\\shell\\ReiseManager.Edit"
    DeleteRegKey $RegRoot "Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\FolderTypes\\{8AA0F2C2-7F91-4F62-BF55-3D2C3AA7EBDC}"
    DeleteRegKey $RegRoot "${INSTALL_DIR_REGKEY}"
    DeleteRegKey $RegRoot "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\ReiseManager"
    Delete "$INSTDIR\\Uninstall.exe"
    RMDir /r "$INSTDIR"
SectionEnd
