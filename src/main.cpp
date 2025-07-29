#include <windows.h>
#include <shellapi.h>
#include <vector>
#include <string>
#include <filesystem>
#include "ReiseManager/UI/TripDialog.h"
#include "ReiseManager/Core/Trip.h"

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE, LPSTR, int) {
    int argc;
    LPWSTR* argvW = CommandLineToArgvW(GetCommandLineW(), &argc);
    std::vector<std::string> args;
    for (int i = 1; i < argc; ++i) {
        int size = WideCharToMultiByte(CP_UTF8, 0, argvW[i], -1, nullptr, 0, nullptr, nullptr);
        std::string arg(size, '\0');
        WideCharToMultiByte(CP_UTF8, 0, argvW[i], -1, &arg[0], size, nullptr, nullptr);
        args.push_back(arg);
    }
    LocalFree(argvW);

    bool newMode = false;
    std::filesystem::path targetPath;
    for (size_t i = 0; i < args.size(); ++i) {
        if (args[i] == "--new") {
            newMode = true;
        } else if (args[i] == "--edit" && i + 1 < args.size()) {
            newMode = false;
            targetPath = args[i + 1];
            ++i;
        }
    }

    ReiseManager::UI::TripDialog dialog(newMode, targetPath);
    int result = dialog.Show(hInstance, nullptr);
    if (result == IDOK) {
        // TODO: Retrieve Trip and perform create/edit operations
        auto trip = dialog.GetTrip();
    }
    return 0;
}
