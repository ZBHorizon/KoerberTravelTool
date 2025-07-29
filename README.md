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
```

## Install
```powershell
& "installer/ReiseManagerSetup.exe"
```

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
