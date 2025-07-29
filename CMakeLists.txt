cmake_minimum_required(VERSION 3.10)
project(ReiseManager LANGUAGES CXX)

# Options
option(BUILD_TESTS "Build unit tests" ON)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Installation prefix
if(NOT CMAKE_INSTALL_PREFIX)
    set(CMAKE_INSTALL_PREFIX "${CMAKE_SOURCE_DIR}/install" CACHE PATH "Installation Directory" FORCE)
endif()

# Include directories
include_directories(${PROJECT_SOURCE_DIR}/include)

# Subdirectories
add_subdirectory(src)
if(BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()

# Install resources
install(DIRECTORY resources/ DESTINATION share/ReiseManager/resources)

# Generate Doxygen documentation (if Doxygen is available)
find_package(Doxygen QUIET)
if(DOXYGEN_FOUND)
    add_custom_target(doc
        COMMAND ${DOXYGEN_EXECUTABLE} ${CMAKE_SOURCE_DIR}/Doxyfile
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        COMMENT "Generating API documentation with Doxygen"
        VERBATIM
    )
endif()
