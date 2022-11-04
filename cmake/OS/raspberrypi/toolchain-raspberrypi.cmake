#  Project: i-Navi
#  
#
# (c) Copyright 2016
#
# All rights reserved.

# CMake system name must be something like "Linux".
# This is important for cross-compiling.

message( STATUS "Raspberry Pi Toolchain file.")

set( CMAKE_SYSTEM_NAME Linux )
set( HOST_ARCH ${CMAKE_HOST_SYSTEM_PROCESSOR} )
set( TARGET_ARCH armv7 ) #TODO is this one really needed?

set( RASPBIAN_ARCH gcc-linaro-arm-linux-gnueabihf-raspbian)
set( RASPBIAN_SYSROOT /opt/raspbian/arm-bcm2708/${RASPBIAN_ARCH}/arm-linux-gnueabihf/libc)
set( CMAKE_SYSROOT ${RASPBIAN_SYSROOT} )# this is needed for other cmake-files
set( RASPBIAN_HOST_TOOLS /opt/raspbian/arm-bcm2708/${RASPBIAN_ARCH})

# Set the cross compiler
set(CMAKE_C_COMPILER   "${RASPBIAN_HOST_TOOLS}/bin/arm-linux-gnueabihf-gcc" CACHE PATH "toolchain gcc program")
set(CMAKE_CXX_COMPILER "${RASPBIAN_HOST_TOOLS}/bin/arm-linux-gnueabihf-g++" CACHE PATH "toolchain g++ program")
set(CMAKE_AR           "${RASPBIAN_HOST_TOOLS}/bin/arm-linux-gnueabihf-gcc-ar" CACHE PATH "toolchain ar program")

# Set Cortex A7, when Raspberry Pi 2 is selected
IF( RASPBERRY_VERSION STREQUAL "2")
   set(CMAKE_C_FLAGS " -mcpu=cortex-a7 -mthumb-interwork -mfloat-abi=hard -mfpu=neon -mtune=cortex-a9 -DHAS_NO_GL_RENDER_BUFFER_STORAGE_MULTI_SAMPLE_IMG " CACHE STRING "CFLAGS")
   set(CMAKE_CXX_FLAGS " -mcpu=cortex-a7 -mthumb-interwork -mfloat-abi=hard -mfpu=neon -mtune=cortex-a9 -DHAS_NO_GL_RENDER_BUFFER_STORAGE_MULTI_SAMPLE_IMG " CACHE STRING "CXXFLAGS")
ELSE()
   set(CMAKE_C_FLAGS " -DHAS_NO_GL_RENDER_BUFFER_STORAGE_MULTI_SAMPLE_IMG " CACHE STRING "CFLAGS")
   set(CMAKE_CXX_FLAGS " -DHAS_NO_GL_RENDER_BUFFER_STORAGE_MULTI_SAMPLE_IMG " CACHE STRING "CXXFLAGS")
ENDIF()

# Function glRenderbufferStorageMultisampleIMG not implemented
add_definitions( -DHAS_NO_GL_RENDER_BUFFER_STORAGE_MULTI_SAMPLE_IMG )

# Set the sysroot
add_definitions( --sysroot=${CMAKE_SYSROOT} )
set( CMAKE_EXE_LINKER_FLAGS --sysroot=${CMAKE_SYSROOT} )

# Search only in toolchain location
set( CMAKE_FIND_ROOT_PATH ${CMAKE_SYSROOT} /opt/raspbian/arm-bcm2708/arm-bcm2708-linux-gnueabi/bin/ )
set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM ONLY )
set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY )
set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY )
set( CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY )

set(CMAKE_CROSSCOMPILING TRUE)
set(TARGET_RASPBIAN ON)

# Set pkg-config module path
set( ENV{PKG_CONFIG_SYSROOT_DIR} ${RASPBIAN_SYSROOT} )
set( ENV{PKG_CONFIG_PATH} ${RASPBIAN_HOST_TOOLS}/bin/arm-linux-gnueabihf-pkg-config )
