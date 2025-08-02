#pragma once

#include <windows.h>
#include <string>
#include <filesystem>
#include <TravelManager/Core/Trip.hpp>

namespace TravelManager::UI
{

    /**
     * Dialog for creating or editing a Trip.
     */
    class TripDialog
    {
    public:
        /**
         * Construct a new dialog.
         * @param modeNew  true for creating a new trip, false to edit an existing one
         * @param targetPath path of folder or shortcut when editing
         */
        TripDialog(bool modeNew, const std::filesystem::path &targetPath = {});
        /**
         * Display the dialog as a modal window.
         *
         * @param hInstance application instance handle
         * @param hParent   parent window handle
         * @return IDOK if the user confirmed the dialog, IDCANCEL otherwise
         */
        int Show(HINSTANCE hInstance, HWND hParent);

        /**
         * Retrieve the trip metadata entered by the user.
         * Only valid if Show() returned IDOK.
         */
        TravelManager::Core::Trip GetTrip() const;

    private:
        bool modeNew_;
        std::filesystem::path targetPath_;
        TravelManager::Core::Trip trip_;

        // handles and result for the simple input window
        HWND hwnd_ = nullptr;
        HWND edSd_ = nullptr;
        HWND edPos_ = nullptr;
        HWND edTitle_ = nullptr;
        HWND edMachine_ = nullptr;
        HWND edCompany_ = nullptr;
        HWND edLocation_ = nullptr;
        HWND dateStart_ = nullptr;
        HWND dateEnd_ = nullptr;
        HWND staticDuration_ = nullptr;
        int dialogResult_ = IDCANCEL;
    };

} // namespace TravelManager::UI
