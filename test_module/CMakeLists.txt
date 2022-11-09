cmake_minimum_required(VERSION 2.8)

project(test_lib)

message("sub:"${PROJECT_BINARY_DIR})
message("sub:"${PROJECT_SOURCE_DIR})
message("sub:"${CMAKE_CURRENT_SOURCE_DIR})
message("sub:"${PROJECT_NAME})
message("sub:"${CMAKE_SOURCE_DIR})

include_directories(${PROJECT_SOURCE_DIR}/include)

aux_source_directory(${PROJECT_SOURCE_DIR}/src SRC_LIST)

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/libs)

add_library(tl SHARED ${SRC_LIST})