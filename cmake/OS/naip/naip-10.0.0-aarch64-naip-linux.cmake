#  Project: i-Navi
#  
#
# (c) Copyright 2014-2016
#
# All rights reserved.

# CMake system name must be something like "Linux".
# This is important for cross-compiling.

message( STATUS "Toolchain file.")

set( CMAKE_SYSTEM_NAME Linux )
set( CMAKE_SYSTEM_PROCESSOR aarch64-naip-linux )
set( HOST_ARCH ${CMAKE_HOST_SYSTEM_PROCESSOR} )
set( TARGET_ARCH aarch64 )
set( NAIP_VERSION 10.0.0 )
set( CMAKE_SYSROOT /opt/naip/${NAIP_VERSION}/salvator-x/sysroots/aarch64-naip-linux)

# Set the cross compiler
include( CMakeForceCompiler )
CMAKE_FORCE_C_COMPILER( ${TARGET_ARCH}-naip-linux-gcc GNU )
CMAKE_FORCE_CXX_COMPILER( ${TARGET_ARCH}-naip-linux-g++ GNU )

set( CMAKE_C_COMPILER /opt/naip/${NAIP_VERSION}/salvator-x/sysroots/${HOST_ARCH}-naipsdk-linux/usr/bin/${TARGET_ARCH}-naip-linux/${TARGET_ARCH}-naip-linux-gcc )
set( CMAKE_CXX_COMPILER /opt/naip/${NAIP_VERSION}/salvator-x/sysroots/${HOST_ARCH}-naipsdk-linux/usr/bin/${TARGET_ARCH}-naip-linux/${TARGET_ARCH}-naip-linux-g++ )
set( CMAKE_C_COMPILER_VERSION 5.2.0)
set( CMAKE_CXX_COMPILER_VERSION 5.2.0)

set( CMAKE_C_FLAGS " --sysroot=${CMAKE_SYSROOT} " CACHE STRING "CFLAGS" )
set( CMAKE_CXX_FLAGS " --sysroot=${CMAKE_SYSROOT} " CACHE STRING "CXXFLAGS" )

# Set the sysroot
add_definitions( --sysroot=${CMAKE_SYSROOT} )
set( CMAKE_EXE_LINKER_FLAGS --sysroot=${CMAKE_SYSROOT} )

# Set qt host binary location
set( OE_QMAKE_PATH_EXTERNAL_HOST_BINS /opt/naip/${NAIP_VERSION}/salvator-x/sysroots/${HOST_ARCH}-naipsdk-linux/usr/bin/qt5 )

# Set pkg-config module path
set( ENV{PKG_CONFIG_SYSROOT_DIR} ${CMAKE_SYSROOT} )
set( ENV{PKG_CONFIG_PATH} ${CMAKE_SYSROOT}/usr/lib/pkgconfig )

# Set SDK version
set( ENV{OECORE_SDK_VERSION} ${NAIP_VERSION} )
set( ENV{OECORE_DISTRO_VERSION} ${NAIP_VERSION} )
set( ENV{SDKTARGETSYSROOT} ${CMAKE_SYSROOT} )

# Search only in toolchain location
set( CMAKE_FIND_ROOT_PATH ${CMAKE_SYSROOT} /opt/naip/${NAIP_VERSION}/salvator-x/sysroots/${HOST_ARCH}-naipsdk-linux )
set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM ONLY )
set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY )
set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY )
set( CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY )

set(CPACK_GENERATOR "TGZ")
set(CMAKE_CROSSCOMPILING TRUE)

