# src/CMakeLists.txt

add_subdirectory(Core)

if(WIN32)
    add_subdirectory(UI)

    add_library(TravelResources OBJECT TravelManager.rc)

    add_executable(TravelManager WIN32 main.cpp $<TARGET_OBJECTS:TravelResources>)
    target_link_libraries(TravelManager PRIVATE TravelManager::Core TravelManager::UI)

    install(TARGETS TravelManager RUNTIME DESTINATION bin)
endif()
