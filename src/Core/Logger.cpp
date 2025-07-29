#include "ReiseManager/Core/Logger.h"
#include <fstream>
#include <chrono>
#include <iomanip>
#include <sstream>
#include <filesystem>
#ifdef _WIN32
#include <windows.h>
#endif

using namespace ReiseManager::Core;

static std::filesystem::path GetLogPath() {
#ifdef _WIN32
    wchar_t* appdata = nullptr;
    size_t len = 0;
    _wdupenv_s(&appdata, &len, L"LOCALAPPDATA");
    std::filesystem::path p = appdata ? appdata : L".";
    free(appdata);
    p /= L"ReiseManager.log";
    return p;
#else
    return "ReiseManager.log";
#endif
}

void Log(const std::string& level, const std::string& message) {
    auto tp = std::chrono::system_clock::now();
    std::time_t tt = std::chrono::system_clock::to_time_t(tp);
    std::tm tm;
#ifdef _WIN32
    localtime_s(&tm, &tt);
#else
    localtime_r(&tt, &tm);
#endif
    std::ostringstream oss;
    oss << std::put_time(&tm, "%Y-%m-%d %H:%M:%S");
    std::ofstream out(GetLogPath(), std::ios::app);
    out << oss.str() << " [" << level << "] " << message << std::endl;
}
