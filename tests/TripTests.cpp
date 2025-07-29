#include <gtest/gtest.h>
#include "ReiseManager/Core/Trip.h"
#include <chrono>

using namespace ReiseManager::Core;

TEST(TripTests, DurationCalculation) {
    auto start = std::chrono::system_clock::now();
    auto end = start + std::chrono::hours(48);
    Trip::SDNumber sd{"123","456"};
    Trip trip(sd, "Title", "Machine", "Company", "Location", start, end);
    EXPECT_EQ(trip.GetDuration(), 3);
}

TEST(TripTests, FolderName) {
    Trip::SDNumber sd{"SD","01"};
    auto now = std::chrono::system_clock::now();
    Trip trip(sd, "Title", "Machine", "Company", "Location", now, now);
    EXPECT_EQ(trip.ComputeFolderName(), "SD-01");
}

#ifdef _WIN32
TEST(TripTests, ShortcutWriteRead) {
    auto now = std::chrono::system_clock::now();
    Trip trip({"SD","02"}, "Title", "Machine", "Company", "Location", now, now);
    std::filesystem::path tmp = std::filesystem::temp_directory_path() / L"RMTest";
    std::filesystem::create_directory(tmp);
    auto lnk = tmp / L"SD-02.lnk";
    trip.ApplyToShortcut(lnk);
    auto loaded = Trip::FromFolder(tmp / L"SD-02");
    EXPECT_EQ(loaded.GetSDNumber().sd, "SD");
    EXPECT_EQ(loaded.GetTitle(), "Title");
    std::filesystem::remove_all(tmp);
}
#endif
