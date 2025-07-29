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
    /**
     * SD number consisting of an SD identifier and a position.
     */
    struct SDNumber { std::string sd; std::string position; };

    /** Construct a new Trip with all metadata. */
    Trip(const SDNumber& sdnum, const std::string& title, const std::string& machine,
         const std::string& company, const std::string& location,
         const std::chrono::system_clock::time_point& start,
         const std::chrono::system_clock::time_point& end);

    /** @name Accessors */
    ///@{
    const SDNumber& GetSDNumber() const;      ///< SD number of the trip
    const std::string& GetTitle() const;      ///< User friendly title
    const std::string& GetMachine() const;    ///< Machine/category string
    const std::string& GetCompany() const;    ///< Company name
    const std::string& GetLocation() const;   ///< Location
    int GetDuration() const;                  ///< Duration in days
    const std::chrono::system_clock::time_point& GetStartDate() const; ///< Start date
    const std::chrono::system_clock::time_point& GetEndDate() const;   ///< End date
    std::string ComputeFolderName() const;    ///< "SD-Position" folder name
    ///@}

    /** Load trip metadata from an existing trip folder. */
    static Trip FromFolder(const std::filesystem::path& folderPath);
    /** Write metadata to a Windows shortcut. */
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
