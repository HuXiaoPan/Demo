cmake_minimum_required(VERSION 2.8)

project(test_OPGL)

include_directories(${PROJECT_SOURCE_DIR}/include)
include_directories(GLAD/include/glad)

add_subdirectory(GLAD)

aux_source_directory(${PROJECT_SOURCE_DIR}/src SRC_LIST)

add_library(test_OPGL ${SRC_LIST})
target_link_libraries(test_OPGL glad -lglfw3 -lGL -lX11 -pthread -ldl)

add_custom_command(TARGET test_OPGL POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/res ${CMAKE_CURRENT_BINARY_DIR}/../bin/res
  COMMENT "cp success!"
  )