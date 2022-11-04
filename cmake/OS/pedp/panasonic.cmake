#  Project: i-Navi
#  
#
# (c) Copyright 2015
#
# All rights reserved.

# Set path of the toolchain
set(SYSROOT /opt/sysroots/pedp+) #/mnt/edt-projects/edt/panasonic/sw/tc2/ready/sysroot/)
set(XTOOLS  /opt/x-tools/aarch64-linux/) # /mnt/edt-projects/edt/panasonic/sw/tc2/ready/compiler/aarch64-linux/)

# Required for the install target. Otherwise the shared object is not found on the target.
SET(CMAKE_INSTALL_RPATH "${SYSROOT}/usr/lib:${CMAKE_INSTALL_RPATH}")
#set(CMAKE_PREFIX_PATH "${SYSROOT}/usr/local/Qt5-cross-host/")

set(CMAKE_CROSSCOMPILING TRUE)
if(NOT CMAKE_BUILD_TYPE)
   set(CMAKE_BUILD_TYPE Release)
endif()

# Set the cross compiler
include(CMakeForceCompiler)
set(CMAKE_C_COMPILER_VERSION 4.8.3)
set(CMAKE_CXX_COMPILER_VERSION 4.8.3)

# cross compiler and build tools:
SET(CMAKE_C_COMPILER   "${XTOOLS}/bin/aarch64-linux-gcc"     CACHE PATH "toolchain gcc program" )
SET(CMAKE_CXX_COMPILER "${XTOOLS}/bin/aarch64-linux-g++"     CACHE PATH "toolchain g++ program" )
SET(CMAKE_AR           "${XTOOLS}/bin/aarch64-linux-ar"      CACHE PATH "toolchain ar program" )
SET(CMAKE_RANLIB       "${XTOOLS}/bin/aarch64-linux-ranlib"  CACHE PATH "toolchain ranlib program" )
SET(CMAKE_NM           "${XTOOLS}/bin/aarch64-linux-nm"      CACHE PATH "toolchain nm program" )
SET(CMAKE_OBJCOPY      "${XTOOLS}/bin/aarch64-linux-objcopy" CACHE PATH "toolchain objcopy program" )
SET(CMAKE_OBJDUMP      "${XTOOLS}/bin/aarch64-linux-objdump" CACHE PATH "toolchain objdump program" )
SET(CMAKE_LINKER       "${XTOOLS}/bin/aarch64-linux-ld"      CACHE PATH "toolchain Linker Program" )
SET(CMAKE_STRIP        "${XTOOLS}/bin/aarch64-linux-strip"   CACHE PATH "toolchain strip program" )

# Search only in toolchain location
set(CMAKE_FIND_ROOT_PATH ${SYSROOT} ${XTOOLS})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# CMake system name must be something like "Linux".
# This is important for cross-compiling.
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)

set(ENV{PKG_CONFIG_SYSROOT_DIR} "${SYSROOT}")
set(ENV{PKG_CONFIG_PATH} "${SYSROOT}/usr/lib/pkgconfig:${SYSROOT}/usr/share/pkgconfig")

# location of host qmake
#set(OE_QMAKE_PATH_EXTERNAL_HOST_BINS /usr/local/Qt5.2.1/5.2.1/gcc_64/bin/)
#set(OE_QMAKE_PATH_EXTERNAL_HOST_BINS /mnt/edt-projects/edt/panasonic/sw/tc2/ready/work/platform/usr/local/Qt-5.4.1/bin/)
#set(OE_QMAKE_PATH_EXTERNAL_HOST_BINS /opt/sysroots/pedp+/usr/local/Qt5-cross-host/bin/qmake)

# Set the sysroot
add_definitions(--sysroot=${SYSROOT})
set(CMAKE_EXE_LINKER_FLAGS --sysroot=${SYSROOT})

set(CURL_LINKTYPE "SYSTEM")
set(USE_GLESV2 On)
