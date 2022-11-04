# Switches the whole buildtools toolchain, e.g. compiler, standard headers etc.
# to the selected target platform.
#
# Usage:
# --------
# include(cmake/na-target.cmake)
# project(xyz)
# --------


if(CMAKE_C_COMPILER_ID OR CMAKE_CXX_COMPILER_ID)
   message(FATAL_ERROR "na-target.cmake must be included *before* project()")
   # The reason for this is that na-target.cmake totally switches the build environment, e.g. including compiler, headers, etc.,
   # and project() uses those settings.
endif()

##################################################################################################################

# The target platform can be specified in two alternative ways
# (a) Through the environment variable TARGET_PLATFORM
# (b) Through CMake parameter TARGET_{platformname} e.g. -DTARGET_NAIP=ON
if (NOT DEFINED TARGET_PLATFORM AND DEFINED ENV{TARGET_PLATFORM})
   set(TARGET_PLATFORM $ENV{TARGET_PLATFORM})
endif()

# avoid that cmake authors always have to write
#   if(TARGET_NAIP OR (TARGET_PLATFORM STREQUAL "naip"))
#   ...
#   endif()
# by setting the variable TARGET_NAIP from the environment
if(TARGET_PLATFORM STREQUAL "naip" OR NOT $ENV{BCORE_SDK_VERSION} STREQUAL "")
   message("-- Using NAIP SDK $ENV{BCORE_SDK_VERSION} from $ENV{SDKTARGETSYSROOT}")
   option(TARGET_NAIP  "cross compile for NAIP"        ON)
else()
   option(TARGET_NAIP  "cross compile for NAIP"        OFF)
endif()

# avoid that cmake authors always have to write
#   if(TARGET_CONTI OR (TARGET_PLATFORM STREQUAL "conti"))
#   ...
#   endif()
# by setting the variable TARGET_NAIP from the environment
if(TARGET_PLATFORM STREQUAL "conti")
   option(TARGET_CONTI "cross compile for Continental" ON)
else()
   option(TARGET_CONTI "cross compile for Continental" OFF)
endif()

# avoid that cmake authors always have to write
#   if(TARGET_ANDROID OR (TARGET_PLATFORM STREQUAL "android"))
#   ...
#   endif()
# by setting the variable TARGET_ANDROID from the environment
if(TARGET_PLATFORM STREQUAL "android")
   option(TARGET_ANDROID "cross compile for Android" ON)
else()
   option(TARGET_ANDROID "cross compile for Android" OFF)
endif()

if(TARGET_PLATFORM STREQUAL "raspbian")
   option(TARGET_RASPBIAN "cross compile for Raspbian" ON)
else()
   option(TARGET_RASPBIAN "cross compile for Raspbian" OFF)
endif()

if(TARGET_PLATFORM STREQUAL "alpine")
   option(TARGET_ALPINE "cross compile for Alpine target" ON)
else()
   option(TARGET_ALPINE "cross compile for Alpine target" OFF)
endif()

if(TARGET_PLATFORM STREQUAL "legato-ar7")
   option(TARGET_LEGATO_AR7 "cross compile for Legato AR7554" ON)
else()
   option(TARGET_LEGATO_AR7 "cross compile for Legato AR7554" OFF)
endif()

# the value "platformadp" is kept for backwards compatibility with the existing buildbot
# configurations. It should be removed when all BCore branches support the value
# "platform-linux-imx6" and all buildbots are reconfigured
if(TARGET_PLATFORM STREQUAL "platformadp" OR TARGET_PLATFORM STREQUAL "platform-linux-imx6")
   option(TARGET_PLATFORM_LINUX_IMX6 "cross compile for Platform Linux imx6 (target)" ON)
else()
   option(TARGET_PLATFORM_LINUX_IMX6 "cross compile for Platform Linux imx6 (target)" OFF)
endif()

if(TARGET_PLATFORM STREQUAL "platform-linux-x86")
   option(TARGET_PLATFORM_LINUX_X86 "cross compile for Platform Linux x86 (LSIM)" ON)
else()
   option(TARGET_PLATFORM_LINUX_X86 "cross compile for Platform Linux x86 (LSIM)" OFF)
endif()

if(TARGET_PLATFORM STREQUAL "kc-30_x86_64")
   option(TARGET_KC30_x86_64 "cross compile for KC 3.0 x86_64" ON)
else()
   option(TARGET_KC30_x86_64 "cross compile for KC 3.0 x86_64" OFF)
endif()

if(TARGET_PLATFORM STREQUAL "agl_aarch64")
   option(TARGET_AGL_AARCH64 "cross compile for AGL aarch64" ON)
else()
   option(TARGET_AGL_AARCH64 "cross compile for AGL aarch64" OFF)
endif()

if(TARGET_PLATFORM STREQUAL "sabre_imx6")
   option(TARGET_SABRE_IMX6 "cross compile for Sabre imx6 series" ON)
else()
   option(TARGET_SABRE_IMX6 "cross compile for Sabre imx6 series" OFF)
endif()

if(TARGET_PLATFORM STREQUAL "am5728")
   option(TARGET_AM5728 "cross compile for Continental" ON)
else()
   option(TARGET_AM5728 "cross compile for Continental" OFF)
endif()

if(TARGET_PLATFORM STREQUAL "aptiv-linux")
   option(TARGET_APTIV_LINUX "cross compile for aptiv-linux" ON)
else()
   option(TARGET_APTIV_LINUX "cross compile for aptiv-linux" OFF)
endif()

if(TARGET_PLATFORM STREQUAL "tda4_linux")
   option(TARGET_TDA4_LINUX "cross compile for tda4_linux" ON)
else()
   option(TARGET_TDA4_LINUX "cross compile for tda4_linux" OFF)
endif()

if(TARGET_PLATFORM STREQUAL "tda4_qnx")
   option(TARGET_TDA4_QNX "cross compile for tda4_qnx" ON)
else()
   option(TARGET_TDA4_QNX "cross compile for tda4_qnx" OFF)
endif()

##################################################################################################################

if(TARGET_PLATFORM STREQUAL "fedora32bit")
   set(CPACK_GENERATOR "RPM")
endif()

if(TARGET_PLATFORM STREQUAL "ubuntu64bit")
   set(CPACK_GENERATOR "DEB")
endif()

if(TARGET_PLATFORM STREQUAL "ubuntu32bit")
   set(CPACK_GENERATOR "DEB")
endif()

#if TARGET_NAIP is set, use naip cross compile toolchain
if(TARGET_NAIP)

  # set default location of toolchain
  set(DEFAULT_TOOLCHAIN_FILE "${CMAKE_SOURCE_DIR}/cmake/OS/naip/naip-10.0.0-cortexa9hf-vfp-neon.cmake")

  if(NOT CMAKE_TOOLCHAIN_FILE)
     SET(CMAKE_TOOLCHAIN_FILE ${DEFAULT_TOOLCHAIN_FILE})
  endif()

  set(SYSTEM_CURL_DEFAULT "ON")
  set(SYSTEM_OPENSSL_DEFAULT "ON")
  set(USE_QT_DEFAULT "OFF")
  set(NABASE_EGL_BACKEND "Wayland")
  set(USE_GLESV2_DEFAULT "ON")
  set(WITH_PLUGINS_DEFAULT "OFF")
  set(WITH_DOCS_DEFAULT "OFF")
  set(CPACK_GENERATOR "TGZ")

elseif(TARGET_CONTI)

  set(DEFAULT_TOOLCHAIN_FILE "${CMAKE_SOURCE_DIR}/cmake/OS/oip/oip-03.06.00.09137-armv7a.cmake")

  set(CMAKE_TOOLCHAIN_FILE $ENV{CONTI_TOOLCHAIN_FILE})

  if(NOT CMAKE_TOOLCHAIN_FILE)
    SET(CMAKE_TOOLCHAIN_FILE ${DEFAULT_TOOLCHAIN_FILE})
  endif()

  set(CPACK_GENERATOR "TGZ")

elseif(TARGET_ANDROID)

  set(DEFAULT_TOOLCHAIN_FILE "${CMAKE_SOURCE_DIR}/cmake/OS/android/android.toolchain.cmake")
  include( ${CMAKE_SOURCE_DIR}/cmake/OS/android/TryRunResults.cmake)

  include_directories( SYSTEM ${CMAKE_SOURCE_DIR}/cmake/OS/android/include)

  if( NOT CMAKE_TOOLCHAIN_FILE)
     # let's guess the toolchain file
     if( ANDROID_NDK)
        if( EXISTS ${ANDROID_NDK}/build/cmake/android.toolchain.cmake)
           message( STATUS "no Android toolchain file provided, will use toolchain file from NDK: ${ANDROID_NDK}/build/cmake/android.toolchain.cmake")
           set( CMAKE_TOOLCHAIN_FILE ${ANDROID_NDK}/build/cmake/android.toolchain.cmake)
        else()
           message( FATAL_ERROR "you appear to compile with an NDK which doesn't provide a CMake toolchain file (<r13b) , please supply toolchain file via CMAKE_TOOLCHAIN_FILE variable")
        endif()
     else()
        message( FATAL_ERROR "no toolchain file specified, please provide it via CMAKE_TOOLCHAIN_FILE or by pointing ANDROID_NDK to a path containing an NDK >=r13b")
     endif()
  endif()

elseif(TARGET_RASPBIAN)

  set(DEFAULT_TOOLCHAIN_FILE "${CMAKE_SOURCE_DIR}/cmake/OS/raspberrypi/toolchain-raspberrypi.cmake")
  include( "${CMAKE_SOURCE_DIR}/cmake/OS/raspberrypi/TryRunResults_edna_configured.cmake")

  if(NOT CMAKE_TOOLCHAIN_FILE)
    set( CMAKE_TOOLCHAIN_FILE ${DEFAULT_TOOLCHAIN_FILE})
  endif()

elseif(TARGET_ALPINE)

  set(DEFAULT_TOOLCHAIN_FILE "/opt/apn/cmake/toolchain-apn.cmake")
  include( "/opt/apn/cmake/TryRunResults_configured.cmake")

  if(NOT CMAKE_TOOLCHAIN_FILE)
    set( CMAKE_TOOLCHAIN_FILE ${DEFAULT_TOOLCHAIN_FILE})
  endif()

elseif(TARGET_LEGATO_AR7)

  set(DEFAULT_TOOLCHAIN_FILE "${CMAKE_SOURCE_DIR}/cmake/OS/legato/legato-ar7.cmake")

  if(NOT CMAKE_TOOLCHAIN_FILE)
    set( CMAKE_TOOLCHAIN_FILE ${DEFAULT_TOOLCHAIN_FILE})
  endif()

elseif(TARGET_PLATFORM_LINUX_IMX6)

  set(DEFAULT_TOOLCHAIN_FILE "${CMAKE_SOURCE_DIR}/cmake/OS/platformadp/platform-linux-imx6.cmake")

  if(NOT CMAKE_TOOLCHAIN_FILE)
    set( CMAKE_TOOLCHAIN_FILE ${DEFAULT_TOOLCHAIN_FILE})
  endif()

  set(CPACK_GENERATOR "TGZ")

elseif(TARGET_PLATFORM_LINUX_X86)

  set(DEFAULT_TOOLCHAIN_FILE "${CMAKE_SOURCE_DIR}/cmake/OS/platformadp/platform-linux-x86.cmake")

  if(NOT CMAKE_TOOLCHAIN_FILE)
    set( CMAKE_TOOLCHAIN_FILE ${DEFAULT_TOOLCHAIN_FILE})
  endif()

  set(CPACK_GENERATOR "TGZ")

elseif(TARGET_KC30_x86_64)

  set(DEFAULT_TOOLCHAIN_FILE "${CMAKE_SOURCE_DIR}/cmake/OS/kc/kc-3.0-poky-linux.cmake")

  if(NOT CMAKE_TOOLCHAIN_FILE)
    set( CMAKE_TOOLCHAIN_FILE ${DEFAULT_TOOLCHAIN_FILE})
  endif()

  set(CPACK_GENERATOR "TGZ")

elseif(TARGET_AGL_AARCH64)

  set(DEFAULT_TOOLCHAIN_FILE "${CMAKE_SOURCE_DIR}/cmake/OS/agl/agl-4.0.0-aarch64.cmake")

  if(NOT CMAKE_TOOLCHAIN_FILE)
    set( CMAKE_TOOLCHAIN_FILE ${DEFAULT_TOOLCHAIN_FILE})
  endif()

  set(CPACK_GENERATOR "TGZ")

elseif(TARGET_SABRE_IMX6)

  set(DEFAULT_TOOLCHAIN_FILE "${CMAKE_SOURCE_DIR}/cmake/OS/sabre/imx6.cmake")

  if(NOT CMAKE_TOOLCHAIN_FILE)
    set( CMAKE_TOOLCHAIN_FILE ${DEFAULT_TOOLCHAIN_FILE})
  endif()

  set(CPACK_GENERATOR "TGZ")

elseif(TARGET_AM5728)

  set(DEFAULT_TOOLCHAIN_FILE "${CMAKE_SOURCE_DIR}/cmake/OS/ti/am5728-linux.cmake")

  if(NOT CMAKE_TOOLCHAIN_FILE)
    set( CMAKE_TOOLCHAIN_FILE ${DEFAULT_TOOLCHAIN_FILE})
  endif()

  set(CPACK_GENERATOR "TGZ")

elseif(TARGET_APTIV_LINUX)

  set(DEFAULT_TOOLCHAIN_FILE "${CMAKE_SOURCE_DIR}/cmake/OS/aptiv/corei7-64-poky-linux.cmake")

  if(NOT CMAKE_TOOLCHAIN_FILE)
    set( CMAKE_TOOLCHAIN_FILE ${DEFAULT_TOOLCHAIN_FILE})
  endif()

  set(CPACK_GENERATOR "TGZ")

elseif(TARGET_TDA4_LINUX)

  set(DEFAULT_TOOLCHAIN_FILE "${CMAKE_SOURCE_DIR}/cmake/OS/tda4/tda4-aarch64.cmake")

  if(NOT CMAKE_TOOLCHAIN_FILE)
    set( CMAKE_TOOLCHAIN_FILE ${DEFAULT_TOOLCHAIN_FILE})
  endif()

elseif(TARGET_TDA4_QNX)

  set(DEFAULT_TOOLCHAIN_FILE ${CMAKE_TOOLCHAIN_FILE})
  message(STATUS "@@@@@@@TARGET_TDA4_QNX DEFAULT_TOOLCHAIN_FILE= ${DEFAULT_TOOLCHAIN_FILE}")
  if(NOT CMAKE_TOOLCHAIN_FILE)
    set( CMAKE_TOOLCHAIN_FILE ${DEFAULT_TOOLCHAIN_FILE})
  endif()
endif()
