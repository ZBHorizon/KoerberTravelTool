# tests/CMakeLists.txt

include(FetchContent)
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/refs/tags/v1.14.0.zip
)
set(INSTALL_GTEST OFF CACHE BOOL "Disable installation of googletest" FORCE)
FetchContent_MakeAvailable(googletest)
include_directories(${PROJECT_SOURCE_DIR}/include)

add_executable(TripTests
    TripTests.cpp
)
target_link_libraries(TripTests PRIVATE TravelManager::Core GTest::gtest_main)

enable_testing()
add_test(NAME TripTests COMMAND TripTests)
