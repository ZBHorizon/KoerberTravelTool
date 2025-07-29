# src/CMakeLists.txt

add_subdirectory(Core)
add_subdirectory(UI)

add_executable(ReiseManager main.cpp)
target_link_libraries(ReiseManager PRIVATE ReiseManager::Core ReiseManager::UI)

install(TARGETS ReiseManager RUNTIME DESTINATION bin)
