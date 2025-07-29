!define APP_NAME "ReiseManager"
!define APP_EXE "ReiseManager.exe"
!define INSTALL_DIR_REGKEY "HKCU\\Software\\ReiseManager"
!define INSTALL_DIR_REGVALUE "InstallPath"
!define ROOT_DIR_REGVALUE "RootReisenPath"

Outfile "${APP_NAME}Setup.exe"
InstallDir $LOCALAPPDATA\\${APP_NAME}
RequestExecutionLevel user

Page directory
Page instfiles

Section "Install"
    SetOutPath "$INSTDIR"
    File /r "${CMAKE_SOURCE_DIR}\\bin\\*"
    WriteRegStr HKCU "Software\\ReiseManager" "${INSTALL_DIR_REGVALUE}" "$INSTDIR"
    ; Prompt user for Reisen root folder
    nsDialogs::Create 1018
    Pop $Dialog
    ; TODO: Add UI to select Reisen root and write to registry
    WriteRegStr HKCU "Software\\ReiseManager" "${ROOT_DIR_REGVALUE}" "$USERPROFILE\\OneDrive - Körber AG\\Reisen"
SectionEnd
