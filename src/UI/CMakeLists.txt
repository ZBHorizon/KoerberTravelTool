# src/UI/CMakeLists.txt

include(CMakeFiles.txt)

add_library(ReiseManagerUI STATIC)

target_sources(ReiseManagerUI PRIVATE ${TARGET_SOURCE_FILES} ${TARGET_INCLUDE_FILES})

target_include_directories(ReiseManagerUI PUBLIC
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
)

target_compile_features(ReiseManagerUI PUBLIC cxx_std_17)

target_link_libraries(ReiseManagerUI PRIVATE ReiseManager::Core)

if(WIN32)
    target_link_libraries(ReiseManagerUI PUBLIC comctl32)
endif()

add_library(ReiseManager::UI ALIAS ReiseManagerUI)
