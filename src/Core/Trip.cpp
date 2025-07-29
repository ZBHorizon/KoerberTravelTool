#include "ReiseManager/Core/Trip.h"
#include <stdexcept>
#include <filesystem>

using namespace ReiseManager::Core;

Trip::Trip(const SDNumber& sdnum, const std::string& title, const std::string& machine,
           const std::string& company, const std::string& location,
           const std::chrono::system_clock::time_point& start,
           const std::chrono::system_clock::time_point& end)
    : sdnum_(sdnum), title_(title), machine_(machine), company_(company),
      location_(location), start_(start), end_(end) {
    if (end < start) {
        throw std::invalid_argument("End date must be on or after start date");
    }
}

const Trip::SDNumber& Trip::GetSDNumber() const { return sdnum_; }
const std::string& Trip::GetTitle() const { return title_; }
const std::string& Trip::GetMachine() const { return machine_; }
const std::string& Trip::GetCompany() const { return company_; }
const std::string& Trip::GetLocation() const { return location_; }
int Trip::GetDuration() const {
    return std::chrono::duration_cast<std::chrono::hours>(end_ - start_).count() / 24 + 1;
}
const std::chrono::system_clock::time_point& Trip::GetStartDate() const { return start_; }
const std::chrono::system_clock::time_point& Trip::GetEndDate() const { return end_; }

std::string Trip::ComputeFolderName() const {
    return sdnum_.sd + "-" + sdnum_.position;
}

Trip Trip::FromFolder(const std::filesystem::path& folderPath) {
    // ...existing code...
    return Trip({"SD","00"}, "Title", "Machine", "Company", "Location", std::chrono::system_clock::now(), std::chrono::system_clock::now());
}

void Trip::ApplyToShortcut(const std::filesystem::path& shortcutPath) const {
    // ...existing code for setting Windows file properties...
}
