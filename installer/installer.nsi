!define APP_NAME "ReiseManager"
!define APP_EXE "ReiseManager.exe"
!define INSTALL_DIR_REGKEY "Software\\ReiseManager"
!define INSTALL_DIR_REGVALUE "InstallPath"
!define ROOT_DIR_REGVALUE "RootReisenPath"

!define MULTIUSER_MUI
!define MULTIUSER_EXECUTIONLEVEL Highest
!define MULTIUSER_INSTALLMODE_INSTDIR "${APP_NAME}"
!define MULTIUSER_INSTALLMODE_DEFAULT_REGISTRY_KEY "${INSTALL_DIR_REGKEY}"
!define MULTIUSER_INSTALLMODE_DEFAULT_REGISTRY_VALUENAME "${INSTALL_DIR_REGVALUE}"

!include "MUI2.nsh"
!include "MultiUser.nsh"
!include "LogicLib.nsh"
!include "nsDialogs.nsh"

Outfile "${APP_NAME}Setup.exe"
Icon "..\\resources\\Reise.ico"
UninstallIcon "..\\resources\\Reise.ico"
InstallDir "$LOCALAPPDATA\\${APP_NAME}"

!insertmacro MULTIUSER_PAGE_INSTALLMODE
!insertmacro MUI_PAGE_DIRECTORY
Page custom SelectRootFolder
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "German"

Var ReisenRoot

Function .onInit
    !insertmacro MULTIUSER_INIT
FunctionEnd

Function un.onInit
    !insertmacro MULTIUSER_UNINIT
FunctionEnd

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
    WriteRegStr ShCtx "${INSTALL_DIR_REGKEY}" "${INSTALL_DIR_REGVALUE}" "$INSTDIR"
    WriteRegStr ShCtx "${INSTALL_DIR_REGKEY}" "${ROOT_DIR_REGVALUE}" "$ReisenRoot"

    ; create uninstaller
    WriteUninstaller "$INSTDIR\\Uninstall.exe"
    WriteRegStr ShCtx "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\ReiseManager" "DisplayName" "ReiseManager"
    WriteRegStr ShCtx "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\ReiseManager" "UninstallString" "$INSTDIR\\Uninstall.exe"

    ; context menu "Neue Reise"
    WriteRegStr ShCtx "Software\\Classes\\Directory\\shell\\ReiseManager.New" "" "Neue Reise erstellen"
    WriteRegStr ShCtx "Software\\Classes\\Directory\\shell\\ReiseManager.New" "AppliesTo" "System.ItemPathDisplay:='$ReisenRoot'"
    WriteRegStr ShCtx "Software\\Classes\\Directory\\shell\\ReiseManager.New\\command" "" '"$INSTDIR\\${APP_EXE}" --new'

    ; context menu "Reise bearbeiten" for folders
    WriteRegStr ShCtx "Software\\Classes\\Directory\\shell\\ReiseManager.Edit" "" "Reise bearbeiten"
    WriteRegStr ShCtx "Software\\Classes\\Directory\\shell\\ReiseManager.Edit" "AppliesTo" "System.ItemPathDisplay:='$ReisenRoot\\*'"
    WriteRegStr ShCtx "Software\\Classes\\Directory\\shell\\ReiseManager.Edit\\command" "" '"$INSTDIR\\${APP_EXE}" --edit "%1"'
    ; for lnk files
    WriteRegStr ShCtx "Software\\Classes\\lnkfile\\shell\\ReiseManager.Edit" "" "Reise bearbeiten"
    WriteRegStr ShCtx "Software\\Classes\\lnkfile\\shell\\ReiseManager.Edit\\command" "" '"$INSTDIR\\${APP_EXE}" --edit "%1"'

    ; custom columns for Reisen folder
    WriteRegStr ShCtx "Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\FolderTypes\\{8AA0F2C2-7F91-4F62-BF55-3D2C3AA7EBDC}" "Name" "Reisen"
    WriteRegStr ShCtx "Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\FolderTypes\\{8AA0F2C2-7F91-4F62-BF55-3D2C3AA7EBDC}\\TopViews\\{00000000-0000-0000-0000-000000000000}" "ColumnList" "prop:System.ItemNameDisplay;System.Title;System.Company;System.Category;System.Calendar.Location;System.Duration;System.StartDate;System.EndDate;System.DateCreated"
SectionEnd

Section "Uninstall"
    DeleteRegKey ShCtx "Software\\Classes\\Directory\\shell\\ReiseManager.New"
    DeleteRegKey ShCtx "Software\\Classes\\Directory\\shell\\ReiseManager.Edit"
    DeleteRegKey ShCtx "Software\\Classes\\lnkfile\\shell\\ReiseManager.Edit"
    DeleteRegKey ShCtx "Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\FolderTypes\\{8AA0F2C2-7F91-4F62-BF55-3D2C3AA7EBDC}"
    DeleteRegKey ShCtx "${INSTALL_DIR_REGKEY}"
    DeleteRegKey ShCtx "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\ReiseManager"
    Delete "$INSTDIR\\Uninstall.exe"
    RMDir /r "$INSTDIR"
SectionEnd
