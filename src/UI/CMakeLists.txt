# src/UI/CMakeLists.txt

add_library(ReiseManagerUI
    TripDialog.cpp
)
target_include_directories(ReiseManagerUI
    PUBLIC ${PROJECT_SOURCE_DIR}/include
)
target_link_libraries(ReiseManagerUI
    PRIVATE ReiseManager::Core
)
add_library(ReiseManager::UI ALIAS ReiseManagerUI)
