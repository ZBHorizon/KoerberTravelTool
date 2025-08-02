# TravelManager

TravelManager is a Windows desktop application for creating and managing travel folders with rich metadata, integrated into File Explorer.

## Requirements
- Windows 10 or later
- CMake 3.10+
- Visual Studio with C++17 support
- Inno Setup (for installer)

## Build
```powershell
mkdir build; cd build
# Install into the user profile without administrator rights
cmake .. -DBUILD_TESTS=ON -DCMAKE_INSTALL_PREFIX="%LOCALAPPDATA%/TravelManager"
cmake --build . --config Release
cmake --install . --config Release
```

## Install
After building run the custom installer target to generate the setup:
```powershell
cmake --build . --config Release --target installer
```
The resulting `TravelManagerSetup.exe` is placed in the `build` directory and
contains all files from the install tree without any component selection.
The installer allows selecting both the installation directory and the target
`Travels` root folder. It registers Explorer context menus and configures the
Travels folder view to show columns for Name, Title, Company, Category, Location,
Duration, Start Date, End Date and Date Created so you can create or edit trips
directly from File Explorer. During installation an **Uninstall.exe** is
generated in the chosen directory and also registered with "Apps & Features" so
the application can be removed easily.

## Usage
- Right-click the root "Travels" folder and select **Create new travel** to create a new trip.
- Right-click an existing travel folder or its shortcut and select **Edit travel** to edit a trip.
- Command-line options:
  - `--new`
  - `--edit "<path>"`

## Testing
```powershell
ctest --output-on-failure
```
The test suite fetches GoogleTest automatically.
