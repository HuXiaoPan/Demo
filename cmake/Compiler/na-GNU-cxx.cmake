#MESSAGE(STATUS "In ${CMAKE_CURRENT_LIST_FILE}")

INCLUDE(${CMAKE_CURRENT_LIST_DIR}/na-GNU.cmake OPTIONAL)

if(CMAKE_CXX_COMPILER_VERSION)
  gcc_default(CXX ${CMAKE_CXX_COMPILER_VERSION})
endif()
