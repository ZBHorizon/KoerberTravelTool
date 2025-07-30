# ReiseManager

ReiseManager is a Windows desktop application for creating and managing travel (Reise) folders with rich metadata, integrated into File Explorer.

## Requirements
- Windows 10 or later
- CMake 3.10+
- Visual Studio with C++17 support
- NSIS (for installer)

## Build
```powershell
mkdir build; cd build
# Installation im Benutzerprofil ohne Admin-Rechte
cmake .. -DBUILD_TESTS=ON -DCMAKE_INSTALL_PREFIX="%LOCALAPPDATA%/ReiseManager"
cmake --build . --config Release
cmake --install . --config Release
```

## Install
After building run CPack to generate the installer:
```powershell
cpack --preset windows-ninja-package
```
The resulting `ReiseManagerSetup.exe` is placed in the `build` directory and
contains all files from the install tree without any component selection.
The installer allows selecting both the installation directory and the target
`Reisen` root folder. It registers Explorer context menus and configures the
Reisen folder view to show columns for Name, Titel, Firma, Kategorien, Ort,
Dauer, Startdatum, Enddatum and Erstelldatum so you can create or edit trips
directly from File Explorer. During installation an **Uninstall.exe** is
generated in the chosen directory and also registered with "Apps & Features" so
the application can be removed easily.

## Usage
- Right-click the root "Reisen" folder and select **Neue Reise erstellen** to create a new trip.
- Right-click an existing trip folder or its shortcut and select **Reise bearbeiten** to edit a trip.
- Command-line options:
  - `--new`
  - `--edit "<path>"`

## Testing
```powershell
ctest --output-on-failure
```
The test suite fetches GoogleTest automatically.
