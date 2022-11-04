#  Project: i-Navi
#  
#
# (c) Copyright 2013-2015
#
# All rights reserved.

# Set path of the toolchain
set( ADK_PREFIX /opt/conti/ADK/JOEM_03.06.00.09137_132200/freescale-smartdevice-adk )
set( ADK_TOOL_PREFIX /opt/conti/SDK/MG_20130830_M9_4.5.20_MentorLicense/IMX6x/MV_Tools )

# Required for the install target. Otherwise the shared object is not found on the target.
SET(CMAKE_INSTALL_RPATH "/usr/lib/ORH_HMI_CORE:${CMAKE_INSTALL_RPATH}")

# Search only in toolchain location
set( CMAKE_FIND_ROOT_PATH ${ADK_PREFIX}/armv7a-mv-linux ${ADK_PREFIX}/i686-linux ${ADK_TOOL_PREFIX}/tools/arm-gnueabi )
set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM ONLY )
set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY )
set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY )
set( CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY )

# CMake system name must be something like "Linux".
# This is important for cross-compiling.
set( CMAKE_SYSTEM_NAME Linux )
set( CMAKE_SYSTEM_PROCESSOR arm )

# Set the cross compiler
include( CMakeForceCompiler )
CMAKE_FORCE_C_COMPILER( arm-montavista-linux-gnueabi-gcc GNU )
CMAKE_FORCE_CXX_COMPILER( arm-montavista-linux-gnueabi-g++ GNU )
set( CMAKE_C_COMPILER ${ADK_TOOL_PREFIX}/tools/arm-gnueabi/bin/arm-montavista-linux-gnueabi-gcc )
set( CMAKE_CXX_COMPILER ${ADK_TOOL_PREFIX}/tools/arm-gnueabi/bin/arm-montavista-linux-gnueabi-g++ )
set( CMAKE_C_COMPILER_VERSION 4.4.1)
set( CMAKE_CXX_COMPILER_VERSION 4.4.1)

# Set the sysroot
add_definitions( --sysroot=${ADK_PREFIX}/armv7a-mv-linux)
set( CMAKE_EXE_LINKER_FLAGS --sysroot=${ADK_PREFIX}/armv7a-mv-linux)

# Set qt host binary location
set( OE_QMAKE_PATH_EXTERNAL_HOST_BINS ${ADK_PREFIX}/i686-linux/usr/bin/ )

# Set pkg-config module path
set( ENV{PKG_CONFIG_SYSROOT_DIR} ${ADK_PREFIX}/armv7a-mv-linux )
set( ENV{PKG_CONFIG_PATH} ${ADK_PREFIX}/armv7a-mv-linux/usr/lib/pkgconfig:${ADK_PREFIX}/armv7a-mv-linux/usr/share/pkgconfig )

link_directories(${ADK_PREFIX}/armv7a-mv-linux/usr/lib/ORH_HMI_CORE)
link_directories(${ADK_PREFIX}/armv7a-mv-linux/usr/lib)
include_directories(${ADK_PREFIX}/armv7a-mv-linux/usr/include/ORH_HMI_CORE)
include_directories(${ADK_PREFIX}/armv7a-mv-linux/usr/include/JOEM_NAV)
