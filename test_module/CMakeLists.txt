cmake_minimum_required(VERSION 2.8)

project(test_lib)

message("sub:"${PROJECT_BINARY_DIR})
message("sub:"${PROJECT_SOURCE_DIR})
include_directories(include)

aux_source_directory (src SRC_LIST)

add_library(tl SHARED ${SRC_LIST})