#  Project: i-Navi
#  
#
# (c) Copyright 2014-2017
#
# All rights reserved.

# CMake system name must be something like "Linux".
# This is important for cross-compiling.

message( STATUS "Toolchain file.")

set(TARGET_KC30 ON)

set( CMAKE_SYSTEM_NAME Linux )
set( CMAKE_SYSTEM_PROCESSOR corei7_64 )
set( HOST_ARCH ${CMAKE_HOST_SYSTEM_PROCESSOR} )
set( TARGET_ARCH x86_64 )
set( KC_VERSION 3.0 )
set( CMAKE_SYSROOT /usr/local/oecore-x86_64/sysroots/corei7-64-poky-linux)

# Set the cross compiler
include( CMakeForceCompiler )
CMAKE_FORCE_C_COMPILER( ${TARGET_ARCH}-poky-linux-gcc GNU )
CMAKE_FORCE_CXX_COMPILER( ${TARGET_ARCH}-poky-linux-g++ GNU )

set( CMAKE_C_COMPILER /usr/local/oecore-x86_64/sysroots/x86_64-oesdk-linux/usr/bin/x86_64-poky-linux/${TARGET_ARCH}-poky-linux-gcc )
set( CMAKE_CXX_COMPILER /usr/local/oecore-x86_64/sysroots/x86_64-oesdk-linux/usr/bin/x86_64-poky-linux/${TARGET_ARCH}-poky-linux-g++ )
set( CMAKE_C_COMPILER_VERSION 5.2.0)
set( CMAKE_CXX_COMPILER_VERSION 5.2.0)

set( CMAKE_C_FLAGS " --sysroot=${CMAKE_SYSROOT} " CACHE STRING "CFLAGS" )
set( CMAKE_CXX_FLAGS " --sysroot=${CMAKE_SYSROOT} " CACHE STRING "CXXFLAGS" )

# Set the sysroot
add_definitions( --sysroot=${CMAKE_SYSROOT} )
set( CMAKE_EXE_LINKER_FLAGS --sysroot=${CMAKE_SYSROOT} )

# Set qt host binary location
set( OE_QMAKE_PATH_EXTERNAL_HOST_BINS /usr/local/oecore-x86_64/sysroots/x86_64-oesdk-linux/usr/bin/qt5 )

# Set pkg-config module path
set( ENV{PKG_CONFIG_SYSROOT_DIR} ${CMAKE_SYSROOT} )
set( ENV{PKG_CONFIG_PATH} ${CMAKE_SYSROOT}/usr/lib/pkgconfig )

# Search only in toolchain location
set( CMAKE_FIND_ROOT_PATH ${CMAKE_SYSROOT} /usr/local/oecore-x86_64/sysroots/x86_64-oesdk-linux )
set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM ONLY )
set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY )
set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY )
set( CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY )

set(CMAKE_CROSSCOMPILING TRUE)
