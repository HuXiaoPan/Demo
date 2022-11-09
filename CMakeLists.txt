# Project: i-Navi
#
#
# Copyright (C) 2013-2017
#
# All rights reserved.

cmake_minimum_required(VERSION 2.8)

project(demo)

message("pre:"${PROJECT_BINARY_DIR})
message("pre:"${PROJECT_SOURCE_DIR})
include_directories(/usr/include/GL)

link_directories(./test_module)

add_subdirectory(test_module)

add_executable(${PROJECT_NAME}.exe main.cpp)
target_link_libraries(${PROJECT_NAME}.exe -lGL -lGLU -lglut -ltl)
