# Project: i-Navi
#
#
# Copyright (C) 2013-2017
#
# All rights reserved.

cmake_minimum_required(VERSION 2.8)

project(demo)

message("main:"${PROJECT_BINARY_DIR})
message("main:"${PROJECT_SOURCE_DIR})
message("main:"${CMAKE_CURRENT_SOURCE_DIR})
message("main:"${PROJECT_NAME})

add_subdirectory(module_01)

option(SYSTEM_PROTOBUF OFF)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin)

add_executable(${PROJECT_NAME}.exe main.cpp)
