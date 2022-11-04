#message(STATUS "In ${CMAKE_CURRENT_LIST_FILE}")

#message(STATUS "Old value of CMAKE_C_FLAGS: ${CMAKE_C_FLAGS}")

include(${CMAKE_CURRENT_LIST_DIR}/na-MSVC.cmake)

__windows_compiler_msvc(C)

#message(STATUS "New value of CMAKE_C_FLAGS: ${CMAKE_C_FLAGS}")
