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
    Trip trip(sd, "Title", "Machine", "Company", "Location", std::chrono::system_clock::now(), std::chrono::system_clock::now());
    EXPECT_EQ(trip.ComputeFolderName(), "SD-01");
}
