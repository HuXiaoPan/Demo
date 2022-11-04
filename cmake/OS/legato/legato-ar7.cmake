#  Project: i-Navi
#  
#
# (c) Copyright 2015 - 2017
#
# All rights reserved.

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR ar7)


SET(CMAKE_SHARED_LIBRARY_PREFIX "lib")
SET(CMAKE_SHARED_LIBRARY_SUFFIX ".so")
SET(CMAKE_STATIC_LIBRARY_PREFIX "lib")
SET(CMAKE_STATIC_LIBRARY_SUFFIX ".a")


# some toolchain path definitions
SET(TOOLCHAIN_HOME   "$ENV{AR7_TOOLCHAIN_DIR}")
SET(TOOLCHAIN_PREFIX "arm-poky-linux-gnueabi-")
SET(AR7_SYSROOT      "${TOOLCHAIN_HOME}/../sysroots/armv7a-vfp-neon-poky-linux-gnueabi")
SET(CMAKE_FIND_ROOT_PATH "${AR7_SYSROOT}")

if(NOT LEGATO_BASE)
   SET(LEGATO_BASE "/opt/legato/packages/legato.framework.16.1.8.m1/resources/legato")
endif()

if(EXISTS "${LEGATO_BASE}")
   message(STATUS "Found Legato in: ${LEGATO_BASE}")
else()
   message(FATAL_ERROR "Couldn't find Legato in: ${LEGATO_BASE}")
endif()

# cross compiler and build tools:
SET(CMAKE_C_COMPILER   "${TOOLCHAIN_HOME}/${TOOLCHAIN_PREFIX}gcc"     CACHE PATH "toolchain gcc program" )
SET(CMAKE_CXX_COMPILER "${TOOLCHAIN_HOME}/${TOOLCHAIN_PREFIX}g++"     CACHE PATH "toolchain g++ program" )
SET(CMAKE_AR           "${TOOLCHAIN_HOME}/${TOOLCHAIN_PREFIX}ar"      CACHE PATH "toolchain ar program" )
SET(CMAKE_RANLIB       "${TOOLCHAIN_HOME}/${TOOLCHAIN_PREFIX}ranlib"  CACHE PATH "toolchain ranlib program" )
SET(CMAKE_NM           "${TOOLCHAIN_HOME}/${TOOLCHAIN_PREFIX}nm"      CACHE PATH "toolchain nm program" )
SET(CMAKE_OBJCOPY      "${TOOLCHAIN_HOME}/${TOOLCHAIN_PREFIX}objcopy" CACHE PATH "toolchain objcopy program")
SET(CMAKE_OBJDUMP      "${TOOLCHAIN_HOME}/${TOOLCHAIN_PREFIX}objdump" CACHE PATH "toolchain objdump program" )
SET(CMAKE_LINKER       "${TOOLCHAIN_HOME}/${TOOLCHAIN_PREFIX}ld"      CACHE PATH "toolchain Linker Program" )
SET(CMAKE_STRIP        "${TOOLCHAIN_HOME}/${TOOLCHAIN_PREFIX}strip"   CACHE PATH "toolchain strip program" )


set(CMAKE_CROSSCOMPILING TRUE)
if(NOT CMAKE_BUILD_TYPE)
   set(CMAKE_BUILD_TYPE Release)
endif()


SET(LEGATO_INCLUDES "-isystem ${LEGATO_BASE}/interfaces")
SET(LEGATO_INCLUDES "${LEGATO_INCLUDES} -isystem ${LEGATO_BASE}/framework/c/inc")
SET(LEGATO_INCLUDES "${LEGATO_INCLUDES} -isystem ${LEGATO_BASE}/interfaces/positioning")

SET(LEGATO_LIBS "-L${LEGATO_BASE}/build/ar7/framework/lib")

SET(AR7_INCLUDES "-isystem ${AR7_SYSROOT}")
SET(AR7_INCLUDES "${AR7_INCLUDES} -isystem ${AR7_SYSROOT}/usr/include")


SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${LEGATO_INCLUDES} ${AR7_INCLUDES} ${LEGATO_LIBS}"                  CACHE STRING "c++ flags")
SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} ${LEGATO_INCLUDES} ${AR7_INCLUDES} ${LEGATO_LIBS}"      CACHE STRING "c++ Debug flags")
SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} ${LEGATO_INCLUDES} ${AR7_INCLUDES} ${LEGATO_LIBS}"  CACHE STRING "c++ Release flags")
SET(CMAKE_C_FLAGS "${CMAKE_CXX_FLAGS}"                                                                      CACHE STRING "c flags")
SET(CMAKE_C_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG}"                                                          CACHE STRING "c Debug flags")
SET(CMAKE_C_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}"                                                      CACHE STRING "c Release flags")

# libm is required due to missing fpu
SET(M_LIBRARY "${AR7_SYSROOT}/lib/libm.so.6")


if (NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/opt/easydrive")
endif()
