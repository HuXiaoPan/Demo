cmake_minimum_required(VERSION 2.8)

project(glad)

include_directories(${PROJECT_SOURCE_DIR}/include)

aux_source_directory(${PROJECT_SOURCE_DIR}/src SRC_LIST)

add_library(glad ${SRC_LIST})