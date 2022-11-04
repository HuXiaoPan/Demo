#  Project: i-Navi
#  
#
# (c) Copyright 2014-2017
#
# All rights reserved.

# CMake system name must be something like "Linux".
# This is important for cross-compiling.

message( STATUS "Toolchain file.")

set( CMAKE_SYSTEM_NAME Linux )
set( CMAKE_C_FLAGS $ENV{CFLAGS} CACHE STRING "" FORCE )
set( CMAKE_CXX_FLAGS $ENV{CXXFLAGS}  CACHE STRING "" FORCE )
set( CMAKE ASM_FLAGS ${CMAKE_C_FLAGS} CACHE STRING "" FORCE )
set( CMAKE_LDFLAGS_FLAGS ${CMAKE_CXX_FLAGS} CACHE STRING "" FORCE )

set( CMAKE_FIND_ROOT_PATH $ENV{OECORE_TARGET_SYSROOT} $ENV{OECORE_NATIVE_SYSROOT} )
set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER )
set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY )
set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY )
set( CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY )

# Set qt host binary location
set( OE_QMAKE_PATH_EXTERNAL_HOST_BINS $ENV{OE_QMAKE_HOST_BINDIR_QT} )

# Set CMAKE_SYSTEM_PROCESSOR from the sysroot name (assuming processor-distro-os).
if ($ENV{SDKTARGETSYSROOT} MATCHES "/sysroots/([a-zA-Z0-9_-]+)-.+-.+")
  set(CMAKE_SYSTEM_PROCESSOR ${CMAKE_MATCH_1})
endif()

set(CMAKE_CROSSCOMPILING TRUE)

set(NA_GCC_CXX_STD "-std=c++11")
