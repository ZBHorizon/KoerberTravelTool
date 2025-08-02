execute_process(
  COMMAND "${CMAKE_COMMAND}" --install "${CMAKE_BINARY_DIR}" --config Release
  RESULT_VARIABLE res
)
if(NOT res EQUAL 0)
  message(FATAL_ERROR "Install step failed")
endif()

execute_process(
  COMMAND iscc "${CMAKE_SOURCE_DIR}/installer/inno_installer.iss"
  WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/installer"
  RESULT_VARIABLE res
)
if(NOT res EQUAL 0)
  message(FATAL_ERROR "Inno Setup compiler failed")
endif()
