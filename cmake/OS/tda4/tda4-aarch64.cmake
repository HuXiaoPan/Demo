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
set( CMAKE_SYSTEM_PROCESSOR aarch64 )
set( HOST_ARCH ${CMAKE_HOST_SYSTEM_PROCESSOR} )
set( TARGET_ARCH aarch64 )

set( CMAKE_SYSROOT /opt/arago/sysroots/aarch64-linux)

# Search only in toolchain location
set( CMAKE_FIND_ROOT_PATH ${CMAKE_SYSROOT} /opt/arago/sysroots/x86_64-arago-linux )
set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER )
set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY )
set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY )
set( CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY )

set(NA_GCC_CXX_STD "-std=c++11")
set(CPACK_GENERATOR "TGZ")
set(CMAKE_CROSSCOMPILING TRUE)
