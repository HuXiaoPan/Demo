#  Project: i-Navi
#  
#
# (c) Copyright 2017-2018
#
# All rights reserved.

set( CMAKE_CROSSCOMPILING TRUE)
set( CMAKE_SYSTEM_NAME Linux )
set( CMAKE_SYSTEM_PROCESSOR cortexa9hf )

set( TARGET_ARCH  arm )
set( TARGET_PATH  /opt/fsl-imx-xwayland/4.1.15-2.1.0/sysroots/cortexa9hf-neon-poky-linux-gnueabi  CACHE PATH "SDK target path")
set( HOST_ARCH    ${CMAKE_HOST_SYSTEM_PROCESSOR} )
set( HOST_PATH    /opt/fsl-imx-xwayland/4.1.15-2.1.0/sysroots/x86_64-pokysdk-linux                CACHE PATH "SDK host path")

set( CMAKE_SYSROOT ${TARGET_PATH})
set( PROJECT sabre-imx6)

# cross compiler and build tools:
SET( CMAKE_C_COMPILER   "${HOST_PATH}/usr/bin/arm-poky-linux-gnueabi/arm-poky-linux-gnueabi-gcc"     CACHE PATH "toolchain gcc program" )
SET( CMAKE_CXX_COMPILER "${HOST_PATH}/usr/bin/arm-poky-linux-gnueabi/arm-poky-linux-gnueabi-g++"     CACHE PATH "toolchain g++ program" )
SET( CMAKE_AR           "${HOST_PATH}/usr/bin/arm-poky-linux-gnueabi/arm-poky-linux-gnueabi-ar"      CACHE PATH "toolchain ar program" )
SET( CMAKE_RANLIB       "${HOST_PATH}/usr/bin/arm-poky-linux-gnueabi/arm-poky-linux-gnueabi-ranlib"  CACHE PATH "toolchain ranlib program" )
SET( CMAKE_NM           "${HOST_PATH}/usr/bin/arm-poky-linux-gnueabi/arm-poky-linux-gnueabi-nm"      CACHE PATH "toolchain nm program" )
SET( CMAKE_OBJCOPY      "${HOST_PATH}/usr/bin/arm-poky-linux-gnueabi/arm-poky-linux-gnueabi-objcopy" CACHE PATH "toolchain objcopy program" )
SET( CMAKE_OBJDUMP      "${HOST_PATH}/usr/bin/arm-poky-linux-gnueabi/arm-poky-linux-gnueabi-objdump" CACHE PATH "toolchain objdump program" )
SET( CMAKE_LINKER       "${HOST_PATH}/usr/bin/arm-poky-linux-gnueabi/arm-poky-linux-gnueabi-ld"      CACHE PATH "toolchain Linker Program" )
SET( CMAKE_STRIP        "${HOST_PATH}/usr/bin/arm-poky-linux-gnueabi/arm-poky-linux-gnueabi-strip"   CACHE PATH "toolchain strip program" )

set( CMAKE_C_FLAGS   " -march=armv7-a -mfpu=neon  -mfloat-abi=hard -mcpu=cortex-a9 --sysroot=${CMAKE_SYSROOT} " CACHE STRING "CFLAGS" )
set( CMAKE_CXX_FLAGS " -march=armv7-a -mfpu=neon  -mfloat-abi=hard -mcpu=cortex-a9 --sysroot=${CMAKE_SYSROOT} " CACHE STRING "CXXFLAGS" )

# Set the sysroot
set( CMAKE_EXE_LINKER_FLAGS --sysroot=${CMAKE_SYSROOT} )

# Set pkg-config module path
set( ENV{PKG_CONFIG_SYSROOT_DIR} ${CMAKE_SYSROOT} )
set( ENV{PKG_CONFIG_PATH} ${CMAKE_SYSROOT}/usr/lib/pkgconfig )

# Search only in toolchain location
set( CMAKE_FIND_ROOT_PATH ${TARGET_PATH} ${HOST_PATH})
set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER )
set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY )
set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY )

# Set qt host binary location
set( OE_QMAKE_PATH_EXTERNAL_HOST_BINS ${HOST_PATH}/usr/bin/qt5)
set( OE_QMAKE_PATH_HOST_PREFIX ${HOST_PATH})

# crappy workarounds for the vivante GPU
add_definitions( -DEGL_API_FB -DLINUX -DWL_EGL_PLATFORM)
