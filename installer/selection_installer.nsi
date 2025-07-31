!define APP_NAME "ReiseManager"

!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "nsDialogs.nsh"

Name "${APP_NAME}"
Outfile "${APP_NAME}Setup.exe"
RequestExecutionLevel user
Icon "..\\resources\\Reise.ico"

!insertmacro MUI_PAGE_WELCOME
Page custom InstModeSelectionPage InstModeSelectionLeave
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_LANGUAGE "German"

Var Dialog
Var InstModeUserRadioButton
Var InstModeAdminRadioButton
Var InstallMode

Function .onInit
    StrCpy $InstallMode "user"  ; Default to user installation
FunctionEnd

Function InstModeSelectionPage
    !insertmacro MUI_HEADER_TEXT "Installationsmodus wählen" "Wählen Sie, ob ${APP_NAME} nur für Sie oder für alle Benutzer installiert werden soll."
    
    nsDialogs::Create 1018
    Pop $Dialog
    
    ${If} $Dialog == error
        Abort
    ${EndIf}
    
    ${NSD_CreateLabel} 0 0 100% 30u "Wie möchten Sie ${APP_NAME} installieren?"
    
    ${NSD_CreateRadioButton} 10u 40u 100% 15u "Nur für mich installieren (keine Administratorrechte erforderlich)"
    Pop $InstModeUserRadioButton
    
    ${NSD_CreateRadioButton} 10u 60u 100% 15u "Für alle Benutzer installieren (Administratorrechte erforderlich)"
    Pop $InstModeAdminRadioButton
    
    ${If} $InstallMode == "user"
        ${NSD_SetState} $InstModeUserRadioButton ${BST_CHECKED}
    ${Else}
        ${NSD_SetState} $InstModeAdminRadioButton ${BST_CHECKED}
    ${EndIf}
    
    nsDialogs::Show
FunctionEnd

Function InstModeSelectionLeave
    ${NSD_GetState} $InstModeAdminRadioButton $0
    ${If} $0 == ${BST_CHECKED}
        StrCpy $InstallMode "admin"
    ${Else}
        StrCpy $InstallMode "user"
    ${EndIf}
FunctionEnd

Section
    SetOutPath "$TEMP"
    
    ${If} $InstallMode == "admin"
        File "${APP_NAME}_AdminSetup.exe"
        ExecWait '"$TEMP\\${APP_NAME}_AdminSetup.exe"'
        Delete "$TEMP\\${APP_NAME}_AdminSetup.exe"
    ${Else}
        File "${APP_NAME}_UserSetup.exe"
        ExecWait '"$TEMP\\${APP_NAME}_UserSetup.exe"'
        Delete "$TEMP\\${APP_NAME}_UserSetup.exe"
    ${EndIf}
SectionEnd
