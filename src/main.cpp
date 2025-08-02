#include <windows.h>
#include <shellapi.h>
#include <vector>
#include <string>
#include <filesystem>
#include <TravelManager/UI/TripDialog.hpp>
#include <TravelManager/Core/Trip.hpp>
#include <TravelManager/Core/Logger.hpp>
#include <shlwapi.h>

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE, LPSTR, int)
{
    int argc;
    LPWSTR *argvW = CommandLineToArgvW(GetCommandLineW(), &argc);
    std::vector<std::string> args;
    for (int i = 1; i < argc; ++i)
    {
        int size = WideCharToMultiByte(CP_UTF8, 0, argvW[i], -1, nullptr, 0, nullptr, nullptr);
        std::string arg(size, '\0');
        WideCharToMultiByte(CP_UTF8, 0, argvW[i], -1, &arg[0], size, nullptr, nullptr);
        args.push_back(arg);
    }
    LocalFree(argvW);

    bool newMode = false;
    std::filesystem::path targetPath;
    for (size_t i = 0; i < args.size(); ++i)
    {
        if (args[i] == "--new")
        {
            newMode = true;
        }
        else if (args[i] == "--edit" && i + 1 < args.size())
        {
            newMode = false;
            targetPath = args[i + 1];
            ++i;
        }
    }

    TravelManager::UI::TripDialog dialog(newMode, targetPath);
    int result = dialog.Show(hInstance, nullptr);
    if (result == IDOK)
    {
        auto trip = dialog.GetTrip();
        wchar_t rootBuf[512];
        DWORD len = sizeof(rootBuf);
        if (ERROR_SUCCESS != RegGetValueW(HKEY_CURRENT_USER, L"Software\\TravelManager", L"RootTravelsPath", RRF_RT_REG_SZ, nullptr, rootBuf, &len))
        {
            ExpandEnvironmentStringsW(L"%USERPROFILE%\\OneDrive - Koerber AG\\Travels", rootBuf, 512);
        }
        std::filesystem::path rootPath(rootBuf);
        auto folderName = trip.ComputeFolderName();

        if (newMode)
        {
            TravelManager::Core::Log("INFO", "Creating trip " + folderName);
            auto tripFolder = rootPath / folderName;
            std::filesystem::create_directory(tripFolder);
            SetFileAttributesW(tripFolder.wstring().c_str(), FILE_ATTRIBUTE_HIDDEN);
            TravelManager::Core::Log("INFO", "Created folder " + tripFolder.string());
            std::filesystem::path linkPath = rootPath / folderName;
            linkPath.replace_extension(L".lnk");
            trip.ApplyToShortcut(linkPath);
            TravelManager::Core::Log("INFO", "Wrote shortcut " + linkPath.string());
        }
        else
        {
            std::filesystem::path old = targetPath;
            if (old.extension() == L".lnk")
            {
                old = old.parent_path() / old.stem();
            }
            auto oldLink = old;
            oldLink.replace_extension(L".lnk");
            std::filesystem::path newFolder = rootPath / folderName;
            if (!std::filesystem::equivalent(old, newFolder))
            {
                std::filesystem::rename(old, newFolder);
                TravelManager::Core::Log("INFO", "Renamed folder to " + newFolder.string());
            }
            std::filesystem::path newLink = rootPath / folderName;
            newLink.replace_extension(L".lnk");
            if (oldLink != newLink && std::filesystem::exists(oldLink))
            {
                std::filesystem::rename(oldLink, newLink);
                TravelManager::Core::Log("INFO", "Renamed shortcut to " + newLink.string());
            }
            trip.ApplyToShortcut(newLink);
            TravelManager::Core::Log("INFO", "Updated metadata");
        }
    }
    return 0;
}
