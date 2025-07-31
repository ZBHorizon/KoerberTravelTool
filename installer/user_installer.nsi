!define APP_NAME "ReiseManager"
!define INSTALL_MODE "User"

Outfile "${APP_NAME}_${INSTALL_MODE}Setup.exe"
InstallDir "$LOCALAPPDATA\\${APP_NAME}"
RequestExecutionLevel user

; Define registry root for user install
Var RegRoot
!define RegRoot "HKCU"

; Include the base installer
!include "installer.nsi"

Function .onInit
    ; Default to user profile location
    StrCpy $RegRoot "HKCU"
FunctionEnd
