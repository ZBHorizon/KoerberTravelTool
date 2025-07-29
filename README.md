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
cmake .. -DBUILD_TESTS=ON -DCMAKE_INSTALL_PREFIX="C:/Program Files/ReiseManager"
cmake --build . --config Release
cmake --install . --config Release
```

## Install
Generate the installer using NSIS after building and installing:
```powershell
makensis installer\installer.nsi
```
Run the produced `ReiseManagerSetup.exe`:
```powershell
& "installer/ReiseManagerSetup.exe"
```
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
