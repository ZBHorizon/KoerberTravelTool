#pragma once

#include <windows.h>
#include <string>
#include <ReiseManager/Core/Trip.h>

namespace ReiseManager::UI {

/**
 * Dialog for creating or editing a Trip.
 */
class TripDialog {
public:
    // Mode: true=new, false=edit
    TripDialog(bool modeNew, const std::filesystem::path& targetPath = {});
    int Show(HINSTANCE hInstance, HWND hParent);

    ReiseManager::Core::Trip GetTrip() const;

private:
    bool modeNew_;
    std::filesystem::path targetPath_;
    ReiseManager::Core::Trip trip_;
};

} // namespace ReiseManager::UI
