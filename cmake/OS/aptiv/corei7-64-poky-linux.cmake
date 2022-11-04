

SET(TOOLCHAIN_HOME  "/opt/poky-infotainment/2.3.3-20180504/sysroots/x86_64-pokysdk-linux")
SET(TOOLCHAIN_PATH  "usr/bin/x86_64-poky-linux")
SET(TOOLCHAIN_PREFIX "x86_64-poky-linux-")
SET(TARGET_PREFIX "x86_64-poky-linux-")

set(TARGET_APTIV ON)

set( CMAKE_SYSTEM_NAME Linux )
set( CMAKE_SYSTEM_PROCESSOR corei7_64 )
set( HOST_ARCH ${CMAKE_HOST_SYSTEM_PROCESSOR} )
set( TARGET_ARCH x86_64 )
set( APTIV_VERSION 3.0 )
set( CMAKE_SYSROOT /opt/poky-infotainment/2.3.3-20180504/sysroots/corei7-64-poky-linux)


# Set the cross compiler
include( CMakeForceCompiler )
set(CMAKE_C_COMPILER_VERSION 5.4.0)
set(CMAKE_CXX_COMPILER_VERSION 5.4.0)

# cross compiler and build tools:
SET(CMAKE_AR           "${TOOLCHAIN_HOME}/${TOOLCHAIN_PATH}/${TOOLCHAIN_PREFIX}ar"      CACHE PATH "toolchain ar program" )
SET(CMAKE_AS           "${TOOLCHAIN_HOME}/${TOOLCHAIN_PATH}/${TOOLCHAIN_PREFIX}as"      CACHE PATH "toolchain as program" )
SET(CMAKE_C_COMPILER   "${TOOLCHAIN_HOME}/${TOOLCHAIN_PATH}/${TOOLCHAIN_PREFIX}gcc"     CACHE PATH "toolchain gcc program" )
SET(CMAKE_CXX_COMPILER "${TOOLCHAIN_HOME}/${TOOLCHAIN_PATH}/${TOOLCHAIN_PREFIX}g++"     CACHE PATH "toolchain g++ program" )
SET(CMAKE_LINKER       "${TOOLCHAIN_HOME}/${TOOLCHAIN_PATH}/${TOOLCHAIN_PREFIX}ld"      CACHE PATH "toolchain linker Program" )
SET(CMAKE_NM           "${TOOLCHAIN_HOME}/${TOOLCHAIN_PATH}/${TOOLCHAIN_PREFIX}nm"      CACHE PATH "toolchain nm program" )
SET(CMAKE_OBJCOPY      "${TOOLCHAIN_HOME}/${TOOLCHAIN_PATH}/${TOOLCHAIN_PREFIX}objcopy" CACHE PATH "toolchain objcopy program")
SET(CMAKE_OBJDUMP      "${TOOLCHAIN_HOME}/${TOOLCHAIN_PATH}/${TOOLCHAIN_PREFIX}objdump" CACHE PATH "toolchain objdump program" )
SET(CMAKE_RANLIB       "${TOOLCHAIN_HOME}/${TOOLCHAIN_PATH}/${TOOLCHAIN_PREFIX}ranlib"  CACHE PATH "toolchain ranlib program" )
SET(CMAKE_STRIP        "${TOOLCHAIN_HOME}/${TOOLCHAIN_PATH}/${TOOLCHAIN_PREFIX}strip"   CACHE PATH "toolchain strip program" )

set (LD ${CMAKE_LINKER})


set(CMAKE_CROSSCOMPILING TRUE)
if(NOT CMAKE_BUILD_TYPE)
   set(CMAKE_BUILD_TYPE Release)
endif()



set(POKY_INCLUDES "-isystem ${CMAKE_SOURCE_DIR}/cmake/OS/aptiv/include")
set(POKY_INCLUDES "${POKY_INCLUDES} -m64 -march=corei7 -mtune=corei7 -mfpmath=sse -msse4.2")
set(POKY_INCLUDES "${POKY_INCLUDES} --sysroot=${CMAKE_SYSROOT}")


set(POKY_LDFLAGS "--sysroot=${CMAKE_SYSROOT}  -Wl,-O1")


SET(CMAKE_C_FLAGS "${CMAKE_CXX_FLAGS} ${POKY_INCLUDES} ${POKY_LDFLAGS}"  CACHE STRING "c++ flags")
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${POKY_INCLUDES} ${POKY_LDFLAGS}"  CACHE STRING "c++ flags")



# Set the sysroot
add_definitions(--sysroot=${CMAKE_SYSROOT})
set(CMAKE_EXE_LINKER_FLAGS --sysroot=${CMAKE_SYSROOT})
set(CMAKE_SHARED_LINKER_FLAGS --sysroot=${CMAKE_SYSROOT})

# Search only in toolchain location
set( CMAKE_FIND_ROOT_PATH ${CMAKE_SYSROOT} ${TOOLCHAIN_HOME} )
set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM ONLY )
set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY )
set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY )
set( CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY )



