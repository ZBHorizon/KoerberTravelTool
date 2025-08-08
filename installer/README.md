# Installer

This folder documents the Windows installer for TravelManager. The installer is built with Inno Setup and integrated into the CMake build via a dedicated target and CPack preset.

Folder naming note: the scripts live under installer/ in the repo. This README resides in Installer/ for convenience.

## Contents

- installer/inno_installer.iss.in ? Inno Setup template. CMake configures this into build/installer/inno_installer.iss with absolute paths and version.
- installer/iscc_config.cmake ? Locates ISCC.exe and exposes INNOSETUP_COMPILER for the build.
- CMakeLists.txt ? Wires the installer target and CPack (INNOSETUP) generator.
- CMakePresets.json ? Presets to build and package the installer.

## Prerequisites

- Windows 10 or later
- CMake 3.27+
- Visual Studio toolset v143 (x64) with C++17
- Ninja (used by the Windows Ninja preset)
- Inno Setup 6 (ISCC.exe on PATH or discoverable)

## How it works (build pipeline)

1. Configure and build the app

- The preset windows-ninja configures a Ninja Multi-Config build in build/.
- TravelManager is built (Release for shipping).

2. Generate the Inno script

- CMake configures installer/inno_installer.iss.in into:
  - build/installer/inno_installer.iss
  - Variables injected:
    - PROJECT_NAME, PROJECT_VERSION
    - INSTALL_ROOT = build/install (CMake install tree)
    - RESOURCE_DIR = resources/ (Travel.ico)

3. Compile with ISCC

- The custom target installer:
  - Installs the project into build/install
  - Runs ISCC on build/installer/inno_installer.iss
  - Writes the setup EXE into build/installer/Output

4. Optional: CPack

- The CPack INNOSETUP generator is configured to use the same .iss and output directory.

## Quick start

Using CMake presets (recommended):

- Configure: cmake --preset windows-ninja
- Build + package: cmake --build --preset windows-ninja-release
  - Target windows-ninja-release builds the installer target and produces the EXE in build/installer/Output

Using CPack:

- cpack --preset windows-ninja-package
  - Produces the same installer EXE in build/installer/Output

Manual ISCC (advanced):

- After configure:
  - cmake --build --preset windows-ninja-release --target install
  - iscc "/O%CD%/installer/Output" "installer/inno_installer.iss"
    - Run from build/ so the relative paths resolve to build/installer/inno_installer.iss

## What the installer does

- Installs the app from the build install tree (build/install) into the chosen install directory:
  - Default (per-user): %LocalAppData%\TravelManager
  - Elevated (all users): %ProgramFiles%\TravelManager
- Creates Start Menu shortcuts (app and Uninstall).
- Registers Explorer context-menu items:
  - Directory: ?Create new travel? and ?Edit travel?
  - lnkfile (shortcuts): ?Edit travel?
- Stores configuration in registry:
  - InstallPath and RootTravelsPath under HKCU, and HKLM if installed elevated.
- Creates a Desktop.ini in the selected Travels folder and sets folder attributes (system) to improve presentation.
- Writes the uninstaller (unins\*.exe) and registers it in ?Apps & features?.
- Final page includes a ?Launch TravelManager? checkbox.

## Installer pages

You will see these pages in order:

- Welcome
- Select Destination Location (defaults to per-user or Program Files depending on elevation)
- Select Travels Folder (custom page)
  - Defaults to %USERPROFILE%\OneDrive\Travels if OneDrive is detected, otherwise Documents\Travels.
  - Use the ?New Folder? button if the folder does not exist yet (required by validation).
- Explorer Integration (information page describing context menus)
- Ready to Install
- Installing
- Completing Setup (with ?Launch TravelManager? option)

Privileges:

- PrivilegesRequired=lowest; the wizard shows an option to elevate and install for all users.

## Outputs

- Setup EXE: build/installer/Output/TravelManagerSetup.exe
- Uninstaller: unins\*.exe in the install directory after installation
- Registry keys:
  - HKCU\Software\TravelManager\{InstallPath, RootTravelsPath}
  - HKCU\Software\Classes\Directory\shell\TravelManager.New/Edit (+ command)
  - HKCU\Software\Classes\lnkfile\shell\TravelManager.Edit (+ command)
  - The same under HKLM when installed elevated
- Desktop.ini in the chosen Travels folder (hidden/system), referencing the app?s EXE for icon and tooltip

## Configuration (script highlights)

From installer/inno_installer.iss.in:

- [Setup]
  - AppName = PROJECT_NAME
  - AppVersion = PROJECT_VERSION
  - OutputBaseFilename = TravelManagerSetup
  - SetupIconFile = resources/Travel.ico
  - DefaultDirName = {code:GetInstallDir} (per-user vs all-users)
  - PrivilegesRequired = lowest; PrivilegesRequiredOverridesAllowed = dialog
- [Files]
  - Source: build/install\* -> {app} (recursesubdirs)
- [Icons]
  - Start Menu shortcut for the app; Uninstall shortcut
- [Run]
  - Launch TravelManager after install (postinstall checkbox)
- [Registry]
  - InstallPath and RootTravelsPath; Explorer context menu entries for New/Edit (Directory and lnkfile)
- [Code]
  - Custom pages: Travels folder picker and an info page
  - Validates the selected folder exists (use ?New Folder? if needed)
  - Creates Desktop.ini and sets attributes (+h, +s) on post-install
  - Uninstaller cleans Desktop.ini and attempts to remove the Travels folder if empty

To change behavior:

- Default install path: adjust GetInstallDir in [Code].
- Default Travels root: edit InitializeWizard defaults.
- Shortcuts/tasks: modify [Icons] and optionally add [Tasks].
- Context menus: edit [Registry] entries and commands.
- Icon: replace resources/Travel.ico.

## CMake integration

- installer/iscc_config.cmake
  - Finds ISCC.exe and sets INNOSETUP_COMPILER.
- CMake configure step
  - configure_file() generates build/installer/inno_installer.iss from installer/inno_installer.iss.in and injects:
    - INSTALL_ROOT = build/install
    - RESOURCE_DIR = resources/
- Custom target: installer
  - Depends on TravelManager
  - Runs cmake --install to populate build/install
  - Runs ISCC with output to build/installer/Output
- CPack
  - INNOSETUP generator uses the same script and compiler, writing to build/installer/Output

## Versioning

- The installer version is taken from project(TravelManager VERSION X.Y) in CMakeLists.txt.
- Bump PROJECT_VERSION to update AppVersion and the generated file metadata.

## Troubleshooting

- ISCC.exe not found:
  - Ensure Inno Setup 6 is installed. Add it to PATH or let installer/iscc_config.cmake locate it.
- Wrong files in the installer:
  - The installer packages build/install. Verify cmake --install ran for the correct configuration (Release).
- Folder selection validation fails:
  - Create the folder using the page?s ?New Folder? button before proceeding.
- Permissions/UAC:
  - Installing under Program Files requires elevation; per-user installs under LocalAppData do not.
- Paths with spaces:
  - Quoting is handled in the build scripts; if invoking ISCC manually, quote /O and script paths.

## Uninstall

- Use ?Apps & features? or the Start Menu Uninstall shortcut.
- Removes installed binaries and registry entries. The Travels folder is only removed if empty; user data is preserved by default.
