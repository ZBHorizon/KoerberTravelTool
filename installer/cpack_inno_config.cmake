# CPack configuration for Inno Setup
set(CPACK_GENERATOR "INNOSETUP")

if(WIN32)
  set(_iscc_hints "$ENV{ProgramFiles}/Inno Setup 6")
  execute_process(COMMAND cmd /c echo "%ProgramFiles(x86)%"
                  OUTPUT_VARIABLE _pf86
                  OUTPUT_STRIP_TRAILING_WHITESPACE)
  if(_pf86)
    list(APPEND _iscc_hints "${_pf86}/Inno Setup 6")
  endif()
  find_program(CPACK_INNOSETUP_COMPILER iscc
    HINTS ${_iscc_hints}
    REQUIRED
  )
else()
  # Allow configuration on non-Windows hosts where iscc is unavailable
  set(CPACK_INNOSETUP_COMPILER iscc)
endif()

set(CPACK_INNOSETUP_SCRIPT "${CMAKE_SOURCE_DIR}/installer/inno_installer.iss")
file(TO_CMAKE_PATH "${CMAKE_SOURCE_DIR}/resources/Travel.ico" CPACK_INNOSETUP_ICON_FILE)
