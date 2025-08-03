cmake_minimum_required(VERSION 3.27)
cmake_policy(SET CMP0048 NEW)
project(TravelManager VERSION 0.1 LANGUAGES CXX)

# Options
option(BUILD_TESTS "Build unit tests" OFF)
option(BUILD_DOCUMENTATION "Build documentation" OFF)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Installation prefix inside the build tree
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install" CACHE PATH "Installation Directory" FORCE)
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
 
# Inno Setup installer
include(${CMAKE_SOURCE_DIR}/installer/iscc_config.cmake)

# Configure Inno Setup script with absolute paths
file(TO_NATIVE_PATH "${CMAKE_BINARY_DIR}/install" INSTALL_ROOT)
file(TO_NATIVE_PATH "${CMAKE_SOURCE_DIR}/resources" RESOURCE_DIR)
configure_file(
    ${CMAKE_SOURCE_DIR}/installer/inno_installer.iss.in
    ${CMAKE_BINARY_DIR}/installer/inno_installer.iss
    @ONLY
)

if(CMAKE_CONFIGURATION_TYPES)
    set(INSTALL_CONFIG_ARG "--config $<CONFIG>")
else()
    set(INSTALL_CONFIG_ARG "")
endif()

if(TARGET TravelManager)
    add_custom_target(installer
        DEPENDS TravelManager
        COMMAND "${CMAKE_COMMAND}" --install "${CMAKE_BINARY_DIR}" ${INSTALL_CONFIG_ARG}
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_BINARY_DIR}/installer/Output"
        COMMAND "${INNOSETUP_COMPILER}" "/O${CMAKE_BINARY_DIR}/installer/Output" "${CMAKE_BINARY_DIR}/installer/inno_installer.iss"
        WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/installer"
        COMMENT "Generate TravelManager Setup.exe"
    )
endif()

# CPack configuration using Inno Setup
set(CPACK_PACKAGE_NAME "${PROJECT_NAME}")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
set(CPACK_GENERATOR "INNOSETUP")
set(CPACK_INNOSETUP_SETUP_SCRIPT "${CMAKE_BINARY_DIR}/installer/inno_installer.iss")
set(CPACK_INNOSETUP_COMPILER "${INNOSETUP_COMPILER}")
set(CPACK_OUTPUT_FILE_PREFIX "${CMAKE_BINARY_DIR}/installer/Output")
include(CPack)
