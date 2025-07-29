#include "ReiseManager/UI/TripDialog.h"
#include <commctrl.h>
#include <stdexcept>

using namespace ReiseManager::UI;

TripDialog::TripDialog(bool modeNew, const std::filesystem::path& targetPath)
    : modeNew_(modeNew), targetPath_(targetPath) {
}

int TripDialog::Show(HINSTANCE hInstance, HWND hParent) {
    // ...existing code: create dialog resource and handle controls...
    return dialogProc(hInstance, hParent); // placeholder
}

ReiseManager::Core::Trip TripDialog::GetTrip() const {
    return trip_;
}
