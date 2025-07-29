# src/CMakeLists.txt

add_subdirectory(Core)

if(WIN32)
    add_subdirectory(UI)

    add_library(ReiseResources OBJECT ReiseManager.rc)

    add_executable(ReiseManager main.cpp $<TARGET_OBJECTS:ReiseResources>)
    target_link_libraries(ReiseManager PRIVATE ReiseManager::Core ReiseManager::UI)

    install(TARGETS ReiseManager RUNTIME DESTINATION bin)
endif()
