#  Project: i-Navi
#  
#
# (c) Copyright 2017
#
# All rights reserved.

# CMake system name must be something like "Linux".
# This is important for cross-compiling.
# CALL: cmake ../edna -DCMAKE_TOOLCHAIN_FILE=../edna/cmake/OS/visteon/monarch/monarch-2.1.2-h3-wayland.cmake -DUSE_QT=OFF -DSYSTEM_CURL=ON -DUSE_GLESV2_DEFAULT=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_INSTALL_PREFIX=/opt/easydrive

set( CMAKE_SYSTEM_NAME Linux )
set( HOST_ARCH ${CMAKE_HOST_SYSTEM_PROCESSOR} )
set( TARGET_ARCH arm )

set( CMAKE_SYSROOT /opt/poky-smartcore2-h3-wayland/2.1.2/sysroots/aarch64-poky-linux)

set(PROJECT visteon-monarch)

set( CMAKE_C_COMPILER   /opt/poky-smartcore2-h3-wayland/2.1.2/sysroots/x86_64-pokysdk-linux/usr/bin/aarch64-poky-linux/aarch64-poky-linux-gcc )
set( CMAKE_CXX_COMPILER /opt/poky-smartcore2-h3-wayland/2.1.2/sysroots/x86_64-pokysdk-linux/usr/bin/aarch64-poky-linux/aarch64-poky-linux-g++ )
#set( CMAKE_C_COMPILER_VERSION 4.9.1)
#set( CMAKE_CXX_COMPILER_VERSION 4.9.1)

set( CMAKE_C_FLAGS " --sysroot=${CMAKE_SYSROOT} " CACHE STRING "CFLAGS" )
set( CMAKE_CXX_FLAGS " --sysroot=${CMAKE_SYSROOT} " CACHE STRING "CXXFLAGS" )

# Set the sysroot
add_definitions( --sysroot=${CMAKE_SYSROOT} )
set( CMAKE_EXE_LINKER_FLAGS --sysroot=${CMAKE_SYSROOT} )

# Set pkg-config module path
set( ENV{PKG_CONFIG_SYSROOT_DIR} ${CMAKE_SYSROOT} )
set( ENV{PKG_CONFIG_PATH} ${CMAKE_SYSROOT}/usr/lib/pkgconfig )

# Search only in toolchain location
set( CMAKE_FIND_ROOT_PATH ${CMAKE_SYSROOT} /opt/poky-smartcore2-h3-wayland/2.1.2/sysroots/x86_64-pokysdk-linux )
set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM ONLY )
set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY )
set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY )
set( CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY )

set(CPACK_GENERATOR "TGZ")
set(CMAKE_CROSSCOMPILING TRUE)

