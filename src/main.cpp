#include <windows.h>
#include <shellapi.h>
#include <vector>
#include <string>
#include <filesystem>
#include <ReiseManager/UI/TripDialog.hpp>
#include <ReiseManager/Core/Trip.hpp>
#include <ReiseManager/Core/Logger.hpp>
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

    ReiseManager::UI::TripDialog dialog(newMode, targetPath);
    int result = dialog.Show(hInstance, nullptr);
    if (result == IDOK)
    {
        auto trip = dialog.GetTrip();
        wchar_t rootBuf[512];
        DWORD len = sizeof(rootBuf);
        if (ERROR_SUCCESS != RegGetValueW(HKEY_CURRENT_USER, L"Software\\ReiseManager", L"RootReisenPath", RRF_RT_REG_SZ, nullptr, rootBuf, &len))
        {
            ExpandEnvironmentStringsW(L"%USERPROFILE%\\OneDrive - K\xF6rber AG\\Reisen", rootBuf, 512);
        }
        std::filesystem::path rootPath(rootBuf);
        auto folderName = trip.ComputeFolderName();

        if (newMode)
        {
            ReiseManager::Core::Log("INFO", "Creating trip " + folderName);
            auto tripFolder = rootPath / folderName;
            std::filesystem::create_directory(tripFolder);
            SetFileAttributesW(tripFolder.wstring().c_str(), FILE_ATTRIBUTE_HIDDEN);
            ReiseManager::Core::Log("INFO", "Created folder " + tripFolder.string());
            std::filesystem::path linkPath = rootPath / folderName;
            linkPath.replace_extension(L".lnk");
            trip.ApplyToShortcut(linkPath);
            ReiseManager::Core::Log("INFO", "Wrote shortcut " + linkPath.string());
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
                ReiseManager::Core::Log("INFO", "Renamed folder to " + newFolder.string());
            }
            std::filesystem::path newLink = rootPath / folderName;
            newLink.replace_extension(L".lnk");
            if (oldLink != newLink && std::filesystem::exists(oldLink))
            {
                std::filesystem::rename(oldLink, newLink);
                ReiseManager::Core::Log("INFO", "Renamed shortcut to " + newLink.string());
            }
            trip.ApplyToShortcut(newLink);
            ReiseManager::Core::Log("INFO", "Updated metadata");
        }
    }
    return 0;
}
