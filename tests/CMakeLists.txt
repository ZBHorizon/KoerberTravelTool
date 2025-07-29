# tests/CMakeLists.txt

include(FetchContent)
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/refs/tags/v1.14.0.zip
)
FetchContent_MakeAvailable(googletest)
include_directories(${PROJECT_SOURCE_DIR}/include)

add_executable(TripTests
    TripTests.cpp
)
target_link_libraries(TripTests PRIVATE ReiseManager::Core GTest::gtest_main)

enable_testing()
add_test(NAME TripTests COMMAND TripTests)
