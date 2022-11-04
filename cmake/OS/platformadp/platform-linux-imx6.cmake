#  Project: i-Navi
#  
#
# (c) Copyright 2015-2018
#
# All rights reserved.

# Set path of the toolchain
if (NOT ADP_ROOT_PATH)
   set(ADP_ROOT_PATH "/opt/adp/adp")
   if (NOT EXISTS ${ADP_ROOT_PATH}/di_binary_repository_2014)
      set(ADP_ROOT_PATH "$ENV{HOME}/adp/adp")
   endif()
endif()

if (NOT EXISTS ${ADP_ROOT_PATH}/di_binary_repository_2014)
   message(FATAL_ERROR "ADP root path does not exist or does not contain di_binary_repository_2014: ${ADP_ROOT_PATH}")
endif()

if (NOT EXISTS ${ADP_ROOT_PATH}/ai_security)
   message(WARNING "ADP root path does not contain ai_security: ${ADP_ROOT_PATH}")
endif()

message(STATUS "ADP root path: ${ADP_ROOT_PATH}")

set(SYSROOT ${ADP_ROOT_PATH}/di_binary_repository_2014/opt/tooling/imx6-staging/version)

set(XTOOLS  /opt/tooling/codesourcery/MGC-2015.12-138-arm-gcc-5.2.0/Sourcery_CodeBench_for_ARM_Embedded)
if (NOT EXISTS ${XTOOLS})
   message(FATAL_ERROR "compiler toolchain not found: ${XTOOLS}")
endif()

# Required for the install target. Otherwise the shared object is not found on the target.
SET(CMAKE_INSTALL_RPATH "${SYSROOT}/usr/lib:${CMAKE_INSTALL_RPATH}")

set(CMAKE_CROSSCOMPILING TRUE)
if(NOT CMAKE_BUILD_TYPE)
   set(CMAKE_BUILD_TYPE Release)
endif()

# Set the cross compiler
include(CMakeForceCompiler)
set(CMAKE_C_COMPILER_VERSION 5.2.0)
set(CMAKE_CXX_COMPILER_VERSION 5.2.0)

# cross compiler and build tools:
SET(CMAKE_C_COMPILER   "${XTOOLS}/bin/arm-none-linux-gnueabi-gcc"     CACHE PATH "toolchain gcc program" )
SET(CMAKE_CXX_COMPILER "${XTOOLS}/bin/arm-none-linux-gnueabi-g++"     CACHE PATH "toolchain g++ program" )
SET(CMAKE_AR           "${XTOOLS}/bin/arm-none-linux-gnueabi-ar"      CACHE PATH "toolchain ar program" )
SET(CMAKE_RANLIB       "${XTOOLS}/bin/arm-none-linux-gnueabi-ranlib"  CACHE PATH "toolchain ranlib program" )
SET(CMAKE_NM           "${XTOOLS}/bin/arm-none-linux-gnueabi-nm"      CACHE PATH "toolchain nm program" )
SET(CMAKE_OBJCOPY      "${XTOOLS}/bin/arm-none-linux-gnueabi-objcopy" CACHE PATH "toolchain objcopy program" )
SET(CMAKE_OBJDUMP      "${XTOOLS}/bin/arm-none-linux-gnueabi-objdump" CACHE PATH "toolchain objdump program" )
SET(CMAKE_LINKER       "${XTOOLS}/bin/arm-none-linux-gnueabi-ld"      CACHE PATH "toolchain Linker Program" )
SET(CMAKE_STRIP        "${XTOOLS}/bin/arm-none-linux-gnueabi-strip"   CACHE PATH "toolchain strip program" )

# Search only in toolchain location
set(CMAKE_FIND_ROOT_PATH ${SYSROOT} ${XTOOLS} ${ADP_ROOT_PATH}/ai_security)
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
set(OE_QMAKE_PATH_EXTERNAL_HOST_BINS /usr/bin)

# Set the sysroot
set(CMAKE_C_FLAGS_INIT "--sysroot=${SYSROOT}")
set(CMAKE_CXX_FLAGS_INIT "--sysroot=${SYSROOT}")
set(CMAKE_EXE_LINKER_FLAGS_INIT "--sysroot=${SYSROOT}")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "--sysroot=${SYSROOT}")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "--sysroot=${SYSROOT}")

# Use the correct ARM cpu variant, architecture and tuning, use the fpu
set(CMAKE_C_FLAGS_INIT "${CMAKE_C_FLAGS_INIT} -mcpu=cortex-a9 -march=armv7-a -mtune=cortex-a9 -mfloat-abi=softfp -mfpu=vfpv3-d16 --no-sysroot-suffix")
set(CMAKE_CXX_FLAGS_INIT "${CMAKE_CXX_FLAGS_INIT} -mcpu=cortex-a9 -march=armv7-a -mtune=cortex-a9 -mfloat-abi=softfp -mfpu=vfpv3-d16 --no-sysroot-suffix")

# crappy workarounds for the vivante GPU
set(CMAKE_C_FLAGS_INIT "${CMAKE_C_FLAGS_INIT} -DEGL_API_FB -DLINUX -DWL_EGL_PLATFORM")
set(CMAKE_CXX_FLAGS_INIT "${CMAKE_CXX_FLAGS_INIT} -DEGL_API_FB -DLINUX -DWL_EGL_PLATFORM")
