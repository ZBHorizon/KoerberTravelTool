#pragma once

#include <string>
#include <chrono>
#include <filesystem>

namespace ReiseManager::Core {

/**
 * Represents a Reise (trip) with metadata.
 */
class Trip {
public:
    struct SDNumber { std::string sd; std::string position; };

    Trip(const SDNumber& sdnum, const std::string& title, const std::string& machine,
         const std::string& company, const std::string& location,
         const std::chrono::system_clock::time_point& start,
         const std::chrono::system_clock::time_point& end);

    const SDNumber& GetSDNumber() const;
    const std::string& GetTitle() const;
    const std::string& GetMachine() const;
    const std::string& GetCompany() const;
    const std::string& GetLocation() const;
    int GetDuration() const;
    const std::chrono::system_clock::time_point& GetStartDate() const;
    const std::chrono::system_clock::time_point& GetEndDate() const;
    std::string ComputeFolderName() const;

    static Trip FromFolder(const std::filesystem::path& folderPath);
    void ApplyToShortcut(const std::filesystem::path& shortcutPath) const;

private:
    SDNumber sdnum_;
    std::string title_;
    std::string machine_;
    std::string company_;
    std::string location_;
    std::chrono::system_clock::time_point start_;
    std::chrono::system_clock::time_point end_;
};

} // namespace ReiseManager::Core
