# src/UI/CMakeLists.txt

include(CMakeFiles.txt)

add_library(TravelManagerUI STATIC)

target_sources(TravelManagerUI PRIVATE ${TARGET_SOURCE_FILES} ${TARGET_INCLUDE_FILES})

target_include_directories(TravelManagerUI PUBLIC
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
)

target_compile_features(TravelManagerUI PUBLIC cxx_std_17)

target_link_libraries(TravelManagerUI PRIVATE TravelManager::Core)

if(WIN32)
    target_link_libraries(TravelManagerUI PUBLIC comctl32)
endif()

add_library(TravelManager::UI ALIAS TravelManagerUI)
