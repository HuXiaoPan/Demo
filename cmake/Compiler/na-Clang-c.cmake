#MESSAGE(STATUS "In ${CMAKE_CURRENT_LIST_FILE}")

if(APPLE)
  # Apple's fork of clang compiler: uses a different version scheme
  INCLUDE(${CMAKE_CURRENT_LIST_DIR}/na-Clang-Apple.cmake OPTIONAL)

  if(CMAKE_C_COMPILER_VERSION)
    clang_apple_default(C ${CMAKE_C_COMPILER_VERSION})
  endif()

else()

  # standard Clang
  INCLUDE(${CMAKE_CURRENT_LIST_DIR}/na-Clang.cmake OPTIONAL)

  if(CMAKE_C_COMPILER_VERSION)
    clang_default(C ${CMAKE_C_COMPILER_VERSION})
  endif()
endif()
