# Project: i-Navi
#
#
# Copyright (C) 2013-2017
#
# All rights reserved.

cmake_minimum_required(VERSION 2.8)

project(demo)

include(cmake/test.cmake)
include_directories(/usr/include/GL)

add_subdirectory(src)

add_executable(${PROJECT_NAME}.exe main.cpp)
target_link_libraries(${PROJECT_NAME}.exe -lGL -lGLU -lglut)
