# tests/CMakeLists.txt

find_package(GTest REQUIRED)
include_directories(${PROJECT_SOURCE_DIR}/include)

add_executable(TripTests
    TripTests.cpp
)
target_link_libraries(TripTests PRIVATE ReiseManager::Core GTest::gtest_main)

enable_testing()
add_test(NAME TripTests COMMAND TripTests)
