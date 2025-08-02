cmake_minimum_required(VERSION 3.27)
cmake_policy(SET CMP0048 NEW)
project(TravelManager VERSION 0.1 LANGUAGES CXX)

# Options
option(BUILD_TESTS "Build unit tests" ON)
option(BUILD_DOCUMENTATION "Build documentation" OFF)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Installation prefix
if(NOT CMAKE_INSTALL_PREFIX)
    set(CMAKE_INSTALL_PREFIX "${CMAKE_SOURCE_DIR}/install" CACHE PATH "Installation Directory" FORCE)
endif()
 
include(GNUInstallDirs)

# Include directories
include_directories(${PROJECT_SOURCE_DIR}/include)

# Subdirectories
add_subdirectory(src)
if(BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()

# Install resources
install(DIRECTORY resources/ DESTINATION share/TravelManager/resources)

# Generate Doxygen documentation (if Doxygen is available)
find_package(Doxygen QUIET)
if(BUILD_DOCUMENTATION AND DOXYGEN_FOUND)
    add_custom_target(doc
        COMMAND ${DOXYGEN_EXECUTABLE} ${CMAKE_SOURCE_DIR}/Doxyfile
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        COMMENT "Generating API documentation with Doxygen"
        VERBATIM
    )
endif()
 
# CPack packaging with Inno Setup
set(CPACK_PACKAGE_NAME "${PROJECT_NAME}")
set(CPACK_PACKAGE_VENDOR "KoerberTravelTool")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "TravelManager Installer")
set(CPACK_PACKAGE_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${PROJECT_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${PROJECT_VERSION_PATCH})
set(CPACK_GENERATOR "External")
include(CPack)

if(CMAKE_CONFIGURATION_TYPES)
    set(CPACK_CONFIG_ARG "-C $<CONFIG>")
else()
    set(CPACK_CONFIG_ARG "")
endif()

add_custom_target(installer
    COMMAND "${CMAKE_CPACK_COMMAND}" ${CPACK_CONFIG_ARG}
            -D CPACK_PROJECT_CONFIG_FILE=${CMAKE_SOURCE_DIR}/installer/cpack_inno_config.cmake
    COMMENT "Generate TravelManager Setup.exe"
)
