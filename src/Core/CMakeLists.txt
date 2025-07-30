# src/Core/CMakeLists.txt

include(CMakeFiles.txt)

add_library(ReiseManagerCore STATIC)

target_sources(ReiseManagerCore PRIVATE ${TARGET_SOURCE_FILES} ${TARGET_INCLUDE_FILES})

target_include_directories(ReiseManagerCore PUBLIC
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
)

target_compile_features(ReiseManagerCore PUBLIC cxx_std_17)

add_library(ReiseManager::Core ALIAS ReiseManagerCore)
