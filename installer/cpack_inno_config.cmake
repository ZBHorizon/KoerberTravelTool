# CPack configuration for Inno Setup
set(CPACK_GENERATOR "INNO")

if(WIN32)
  find_program(CPACK_INNOSETUP_ISCC iscc HINTS "$ENV{ProgramFiles(x86)}/Inno Setup 6" "$ENV{ProgramFiles}/Inno Setup 6" REQUIRED)
else()
  # Allow configuration on non-Windows hosts where iscc is unavailable
  set(CPACK_INNOSETUP_ISCC iscc)
endif()

set(CPACK_INNOSETUP_SCRIPT "${CMAKE_SOURCE_DIR}/installer/inno_installer.iss")
file(TO_NATIVE_PATH "${CMAKE_SOURCE_DIR}/resources/Travel.ico" CPACK_INNOSETUP_ICON_FILE)
