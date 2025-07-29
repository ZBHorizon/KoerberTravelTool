# src/Core/CMakeLists.txt

add_library(ReiseManagerCore
    Trip.cpp
    Logger.cpp
)
target_include_directories(ReiseManagerCore
    PUBLIC ${PROJECT_SOURCE_DIR}/include
)
add_library(ReiseManager::Core ALIAS ReiseManagerCore)
