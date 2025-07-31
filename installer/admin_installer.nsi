!define APP_NAME "ReiseManager"
!define INSTALL_MODE "Admin"

Outfile "${APP_NAME}_${INSTALL_MODE}Setup.exe"
InstallDir "$PROGRAMFILES\\${APP_NAME}"
RequestExecutionLevel admin

; Define registry root for admin install
Var RegRoot
!define RegRoot "HKLM"

; Include the base installer
!include "installer.nsi"

Function .onInit
    ; Default to machine-wide installation
    StrCpy $RegRoot "HKLM"
FunctionEnd
