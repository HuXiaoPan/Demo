#message(STATUS "In ${CMAKE_CURRENT_LIST_FILE}")

#message(STATUS "Old value of CMAKE_CXX_FLAGS: ${CMAKE_CXX_FLAGS}")

include(${CMAKE_CURRENT_LIST_DIR}/na-MSVC.cmake)

set(_COMPILE_CXX " /TP")

__windows_compiler_msvc(CXX)

#message(STATUS "New value of CMAKE_CXX_FLAGS: ${CMAKE_CXX_FLAGS}")
