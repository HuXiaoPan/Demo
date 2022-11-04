#  Project: i-Navi
#  
#
# (c) Copyright 2014
#
# All rights reserved.

# Sample use of on Windows:
#   SET QNX_BASE=<...your path...>
#   SET QNX_TARGET=%QNX_BASE%/target/qnx6
#   SET QNX_HOST=%QNX_BASE%/host/win32/x86
#   SET QNX_LIB_ARCH=armle-v7
#   SET CMAKE_MAKE_PROGRAM=%QNX_HOST%/usr/bin/make.exe
#   SET QTDIR=<...your QT path...>
#   SET PATH=%QTDIR:/=\%\bin;%QNX_HOST:/=\%\usr\bin;%PATH%
#   cmake -DWITH_SIMPLE_HMI=ON -DCMAKE_MAKE_PROGRAM=%CMAKE_MAKE_PROGRAM% -DCMAKE_SYSTEM_PROCESSOR=armv7 -DQNX_USE_LIBCPP=ON \
#         -G "Unix Makefiles" -DCMAKE_TOOLCHAIN_FILE=<path-to-src>/cmake/OS/qnx/qnx-650.cmake <path-to-src>
#   make
#
# By default the target processor is x86, use
#   -DCMAKE_SYSTEM_PROCESSOR=armv7
# or similar to select another target.

# this one is important
SET(CMAKE_SYSTEM_NAME QNX)
SET(CMAKE_SYSTEM_VERSION 6.5.0)

#### Options ##########################################################################################################

set   (QNX_TARGET_ARCHITECTURE "armle-v7" CACHE STRING "QNX target architecture (e.g. 'x86', 'armle', 'armle-v7', ...)")
if( DEFINED QNX_USE_LIBCPP_DEFAULT)
   option(QNX_USE_LIBCPP                                  "Shall Dinkumware stdlib be used?" ${QNX_USE_LIBCPP_DEFAULT})
else()
   option(QNX_USE_LIBCPP                                  "Shall Dinkumware stdlib be used?" OFF)
endif()

#### Configuration ####################################################################################################

if ( QNX_TARGET_ARCHITECTURE STREQUAL "armle" OR QNX_TARGET_ARCHITECTURE STREQUAL "armle-v7")
   set( CMAKE_SYSTEM_PROCESSOR armv7)
elseif( QNX_TARGET_ARCHITECTURE STREQUAL "x86")
   set( CMAKE_SYSTEM_PROCESSOR x86)
endif()
set(CMAKE_CXX_LIBRARY_ARCHITECTURE ${QNX_TARGET_ARCHITECTURE})

IF( CMAKE_HOST_WIN32 )
  SET( HOST_EXECUTABLE_SUFFIX ".exe" )
  FILE(TO_CMAKE_PATH "$ENV{QNX_HOST}"   QNX_HOST)
  FILE(TO_CMAKE_PATH "$ENV{QNX_TARGET}" QNX_TARGET)
ELSE()
  SET(QNX_HOST   $ENV{QNX_HOST})
  SET(QNX_TARGET $ENV{QNX_TARGET})
ENDIF( CMAKE_HOST_WIN32 )
MESSAGE(STATUS "using QNX_HOST ${QNX_HOST}")
MESSAGE(STATUS "using QNX_TARGET ${QNX_TARGET}")

SET(CMAKE_SHARED_LIBRARY_PREFIX "lib")
SET(CMAKE_SHARED_LIBRARY_SUFFIX ".so")
SET(CMAKE_STATIC_LIBRARY_PREFIX "lib")
SET(CMAKE_STATIC_LIBRARY_SUFFIX ".a")

# specify the cross compiler: use gcc directly, not qcc
SET( CMAKE_C_COMPILER   "${QNX_HOST}/usr/bin/nto${CMAKE_SYSTEM_PROCESSOR}-gcc${HOST_EXECUTABLE_SUFFIX}"     CACHE PATH "QNX gcc program" )
SET( CMAKE_CXX_COMPILER "${QNX_HOST}/usr/bin/nto${CMAKE_SYSTEM_PROCESSOR}-g++${HOST_EXECUTABLE_SUFFIX}"     CACHE PATH "QNX g++ program" )

# other programs
SET( CMAKE_MAKE_PROGRAM "${QNX_HOST}/usr/bin/make${HOST_EXECUTABLE_SUFFIX}"                                 CACHE PATH "QNX make program" )
SET( CMAKE_SH           "${QNX_HOST}/usr/bin/sh${HOST_EXECUTABLE_SUFFIX}"                                   CACHE PATH "QNX shell program" )
SET( CMAKE_AR           "${QNX_HOST}/usr/bin/nto${CMAKE_SYSTEM_PROCESSOR}-ar${HOST_EXECUTABLE_SUFFIX}"      CACHE PATH "QNX ar program" )
SET( CMAKE_RANLIB       "${QNX_HOST}/usr/bin/nto${CMAKE_SYSTEM_PROCESSOR}-ranlib${HOST_EXECUTABLE_SUFFIX}"  CACHE PATH "QNX ranlib program" )
SET( CMAKE_NM           "${QNX_HOST}/usr/bin/nto${CMAKE_SYSTEM_PROCESSOR}-nm${HOST_EXECUTABLE_SUFFIX}"      CACHE PATH "QNX nm program" )
SET( CMAKE_OBJCOPY      "${QNX_HOST}/usr/bin/nto${CMAKE_SYSTEM_PROCESSOR}-objcopy${HOST_EXECUTABLE_SUFFIX}" CACHE PATH "QNX objcopy program" )
SET( CMAKE_OBJDUMP      "${QNX_HOST}/usr/bin/nto${CMAKE_SYSTEM_PROCESSOR}-objdump${HOST_EXECUTABLE_SUFFIX}" CACHE PATH "QNX objdump program" )
SET( CMAKE_LINKER       "${QNX_HOST}/usr/bin/nto${CMAKE_SYSTEM_PROCESSOR}-ld${HOST_EXECUTABLE_SUFFIX}"      CACHE PATH "QNX Linker Program" )
#SET( CMAKE_LINKER       "${QNX_HOST}/usr/bin/qcc${HOST_EXECUTABLE_SUFFIX}"                                  CACHE PATH "QNX linker program" )
SET( CMAKE_STRIP        "${QNX_HOST}/usr/bin/nto${CMAKE_SYSTEM_PROCESSOR}-strip${HOST_EXECUTABLE_SUFFIX}"   CACHE PATH "QNX strip program" )

set(CMAKE_CROSSCOMPILING TRUE)

# where is the target environment
SET(CMAKE_FIND_ROOT_PATH  "${QNX_TARGET}")

# search for programs in the build host directories
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# for libraries and headers in the target directories
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

add_definitions("-D_QNX_SOURCE")

# QNX has a default FD_SETSIZE of 256 which is too small for handling databases with many update regions
# Linux has a default of 1024, so we will be using this for QNX as well
add_definitions( "-DFD_SETSIZE=1024")

set(QNX_ADDITIONAL_LIBS)
set(QNX_CPP_STDLIB "-lstdc++")
set(QNX_C_FLAGS   "-fno-strict-aliasing")
set(QNX_CXX_FLAGS "-fno-strict-aliasing")

message(STATUS "QNX_USE_LIBCPP: ${QNX_USE_LIBCPP}")
if(QNX_USE_LIBCPP)
   # use cpp lib instead of stdc++
   set( QNX_CXX_FLAGS "${QNX_CXX_FLAGS} -D_EXCEPTION -nostdinc -nostdinc++")
   set( QNX_CXX_FLAGS "${QNX_CXX_FLAGS} -isystem ${CMAKE_SOURCE_DIR}/cmake/OS/qnx/include")
   set( QNX_CXX_FLAGS "${QNX_CXX_FLAGS} -isystem ${QNX_TARGET}/usr/include")
   set( QNX_CXX_FLAGS "${QNX_CXX_FLAGS} -isystem ${QNX_TARGET}/usr/include/cpp/c")
   set( QNX_CXX_FLAGS "${QNX_CXX_FLAGS} -isystem ${QNX_TARGET}/usr/include/cpp")
   set( QNX_CPP_STDLIB "-nodefaultlibs -lcpp -lnbutil -lm -lcxa -lc")

   if(CMAKE_SYSTEM_PROCESSOR STREQUAL "armv7")
      set( QNX_CXX_FLAGS "${QNX_CXX_FLAGS} -isystem ${QNX_HOST}/usr/lib/gcc/arm-unknown-nto-qnx6.5.0eabi/4.4.2/include")
      set( QNX_CPP_STDLIB "${QNX_CPP_STDLIB} -Wl,-L${QNX_HOST}/usr/lib/gcc/arm-unknown-nto-qnx6.5.0eabi/4.4.2")
   elseif(CMAKE_SYSTEM_PROCESSOR STREQUAL "x86")
      set( QNX_CXX_FLAGS "${QNX_CXX_FLAGS} -isystem ${QNX_HOST}/usr/lib/gcc/i486-pc-nto-qnx6.5.0/4.4.2/include")
      set( QNX_CPP_STDLIB "${QNX_CPP_STDLIB} -Wl,-L${QNX_HOST}/usr/lib/gcc/i486-pc-nto-qnx6.5.0/4.4.2")
   endif()

   set( QNX_CPP_STDLIB "${QNX_CPP_STDLIB} -Wl,-L${QNX_TARGET}/${CMAKE_CXX_LIBRARY_ARCHITECTURE}/lib/gcc/4.4.2")
   set( QNX_CPP_STDLIB "${QNX_CPP_STDLIB} -Wl,-L,${QNX_TARGET}/${CMAKE_CXX_LIBRARY_ARCHITECTURE}/lib")
   set( QNX_CPP_STDLIB "${QNX_CPP_STDLIB} -Wl,-L,${QNX_TARGET}/${CMAKE_CXX_LIBRARY_ARCHITECTURE}/usr/lib")
   set( QNX_CPP_STDLIB "${QNX_CPP_STDLIB} -Wl,-rpath,${QNX_TARGET}/${CMAKE_CXX_LIBRARY_ARCHITECTURE}/lib")
   set( QNX_CPP_STDLIB "${QNX_CPP_STDLIB} -Wl,-rpath,${QNX_TARGET}/${CMAKE_CXX_LIBRARY_ARCHITECTURE}/usr/lib")
endif()

list(APPEND QNX_ADDITIONAL_LIBS nbutil gcc)

if (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86")
  # Need an uptodate processor for gcc atomics
  set(QNX_C_FLAGS   "-march=i686 ${QNX_C_FLAGS}")
  set(QNX_CXX_FLAGS "-march=i686 ${QNX_CXX_FLAGS}")
endif()

set(CMAKE_C_FLAGS   "${QNX_C_FLAGS}"   CACHE STRING "C flags")
set(CMAKE_CXX_FLAGS "${QNX_CXX_FLAGS}" CACHE STRING "C++ flags")

set(CMAKE_EXE_LINKER_FLAGS    "--sysroot=${QNX_TARGET} ${QNX_CPP_STDLIB} -Wl,--as-needed"                CACHE STRING "Linkerflags for executables")
set(CMAKE_SHARED_LINKER_FLAGS "--sysroot=${QNX_TARGET} ${QNX_CPP_STDLIB} -Wl,--as-needed -Wl,-Bsymbolic" CACHE STRING "Linkerflags for shared libs")
set(CMAKE_MODULE_LINKER_FLAGS "--sysroot=${QNX_TARGET} ${QNX_CPP_STDLIB} -Wl,--as-needed -Wl,-Bsymbolic" CACHE STRING "Linkerflags for modules"    )
set(CMAKE_LIBRARY_PATH        "${QNX_TARGET}/${CMAKE_CXX_LIBRARY_ARCHITECTURE}/usr/lib"  CACHE STRING "QNX library path"           )

message(STATUS "CMAKE_EXE_LINKER_FLAGS     ${CMAKE_EXE_LINKER_FLAGS}")
message(STATUS "CMAKE_SHARED_LINKER_FLAGS  ${CMAKE_SHARED_LINKER_FLAGS}")
message(STATUS "CMAKE_MODULE_LINKER_FLAGS  ${CMAKE_MODULE_LINKER_FLAGS}")
message(STATUS "CMAKE_LIBRARY_PATH         ${CMAKE_LIBRARY_PATH}")
