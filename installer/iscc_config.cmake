# Locate Inno Setup compiler
if(WIN32)
  set(_iscc_hints "$ENV{ProgramFiles}/Inno Setup 6")
  execute_process(COMMAND cmd /c echo "%ProgramFiles(x86)%" OUTPUT_VARIABLE _pf86 OUTPUT_STRIP_TRAILING_WHITESPACE)
  if(_pf86)
    list(APPEND _iscc_hints "${_pf86}/Inno Setup 6")
  endif()
  find_program(INNOSETUP_COMPILER iscc HINTS ${_iscc_hints} REQUIRED)
else()
  # Fallback for non-Windows hosts without Inno Setup
  set(INNOSETUP_COMPILER iscc)
endif()
