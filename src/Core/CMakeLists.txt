# src/Core/CMakeLists.txt

include(CMakeFiles.txt)

add_library(TravelManagerCore STATIC)

target_sources(TravelManagerCore PRIVATE ${TARGET_SOURCE_FILES} ${TARGET_INCLUDE_FILES})

target_include_directories(TravelManagerCore PUBLIC
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
)

target_compile_features(TravelManagerCore PUBLIC cxx_std_17)

if(WIN32)
    target_link_libraries(TravelManagerCore PUBLIC propsys)
endif()

add_library(TravelManager::Core ALIAS TravelManagerCore)
