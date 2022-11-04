# Project: i-Navi
#
#
# Copyright (C) 2013-2017
#
# All rights reserved.

cmake_minimum_required(VERSION 2.8)

### cross compiler options #######################################################################################

include(cmake/na-target.cmake)

### project specific toolchain options ###########################################################################

if(TARGET_ANDROID)

   if(NOT DEFINED ANDROID_STL)
      # Android: link STL as shared library, otherwise there are issues when sharing STL types
      # across library borders (e.g. std::string)
#      set(ANDROID_STL gnustl_shared)
   endif()

   # Android: native API level is 16; this can be overruled by supplying ANDROID_PLATFORM via CMake, i.e.:
   # cmake <blabla> -DANDROID_PLATFORM=21
   set(ANDROID_NATIVE_API_LEVEL 29)

   # Android: minimum API level is 16
   set(ANDROID_SDK_MIN_API_LEVEL 29)

   # Google Play Services >= 5.0.0 are required
   set(GOOGLE_PLAY_SERVICES_MIN_VERSION 5)
endif()

message(STATUS "TARGET_SYALLMODE ==== ${TARGET_SYALLMODE}")
if(TARGET_SYALLMODE STREQUAL "SYALLMODE")
   add_definitions("-DTEMP_TEST_FOR_SWITCH_SDHD_SYSHOW")
endif()

message(STATUS "TARGET_BUILDMODE ==== ${TARGET_BUILDMODE}")
if(TARGET_BUILDMODE STREQUAL "PICKMAP_SERVER")
   add_definitions("-DTARGET_BUILDMODE_PICKMAP_SERVER")
elseif(TARGET_BUILDMODE STREQUAL "PICKMAP_CLIENT")
   add_definitions("-DTARGET_BUILDMODE_PICKMAP_CLIENT")

elseif(TARGET_BUILDMODE STREQUAL "ANDROID_ALLNAVI")
   add_definitions("-DTARGET_BUILDMODE_ANDROID_ALLNAVI")
elseif(TARGET_BUILDMODE STREQUAL "TDA4_ALLNAVI")
   add_definitions("-DTARGET_BUILDMODE_TDA4_ALLNAVI")
endif()

# QNX: build against dinkumware cpp library as default
set(QNX_USE_LIBCPP_DEFAULT ON)

### initialize project ###########################################################################################

project(edna)

### global cmake and compiler configuration ######################################################################

include(cmake/na-default.cmake)

# convenience function for ios app build, so we can have one big library for the navigation core
include(cmake/na_merge_static_libs.cmake)

include(cmake/Modules/NaTools.cmake)
include(cmake/Modules/UpdateGitVersion.cmake)
include(cmake/Modules/NaLicenseInfo.cmake)

find_package(AsciiDoc 0.9.2)
find_package(GenerateProject REQUIRED 1.0)

### global default options #######################################################################################

# we only do this in the non-crosscompiling case
# to prevent that all the documentation gets into the installation package
if(NOT DEFINED WITH_DOCS_IFACE_MGR_DEFAULT)
   if(NOT CMAKE_CROSSCOMPILING OR WITH_DOCS)
      set(WITH_DOCS_IFACE_MGR_DEFAULT    ON         )
   endif()
endif()

if(MGR_OPENGL_EGL_BACKEND_DEFAULT)
   if(NOT NABASE_EGL_BACKEND_DEFAULT)
      message(WARNING "Use of MGR_OPENGL_EGL_BACKEND_DEFAULT is deprecated, use NABASE_EGL_BACKEND_DEFAULT instead")
      set(NABASE_EGL_BACKEND_DEFAULT ${MGR_OPENGL_EGL_BACKEND_DEFAULT})
   else()
      message(WARNING "Use of MGR_OPENGL_EGL_BACKEND_DEFAULT is deprecated, value ignored")
   endif()
endif()

set(JSONWS_ADAPTOR_DEFAULT                ON         )

if(APPLE AND (NOT IOS))

   set(SYSTEM_CURL_DEFAULT                ON         )

elseif(APPLE AND IOS)

   set(BUILD_NA_BCORE_SH_DEFAULT        OFF        )
   set(BUILD_NA_BCORE_CLIENT_SH_DEFAULT OFF        )
   set(LINK_NA_BCORE_STATIC_LIB_DEFAULT ON         )
#  set(ICU_LINKTYPE                       NONE       )     #  can't link shared libs

elseif(TARGET_NAIP)

   set(USE_GLESV2_DEFAULT                 ON         )
   set(SYSTEM_CURL_DEFAULT                ON         )

elseif(TARGET_RASPBIAN)

   set(USE_GLESV2_DEFAULT                 ON         )
   set(MGR_OPENGL_QT_ENABLED_DEFAULT      OFF        )
   set(NABASE_EGL_BACKEND_DEFAULT         "VideoCore")

elseif(ANDROID)

   set(USE_QT_DEFAULT                     OFF        )
   set(USE_MGR_WINDOW_DEFAULT             ON        )
   set(USE_GLESV2_DEFAULT                 ON         )
   set(NABASE_EGL_BACKEND_DEFAULT         "Android"  )
   set(DBUS_ADAPTOR_DEFAULT               OFF        )
   set(JNI_ADAPTOR_DEFAULT                OFF        )
   set(BUILD_NA_BCORE_SH_DEFAULT        ON         )
   set(BUILD_NA_BCORE_CLIENT_SH_DEFAULT ON        )
   set(BUILD_NA_BCORE_EXE_DEFAULT       OFF        )
   set(FCALLCPP_ADAPTOR_DEFAULT           ON        )
#   set(DISABLE_WINDOW_HANDLING_DEFAULT    OFF         )

elseif(WIN32)

   set(LINK_NA_BCORE_SH_DEFAULT         ON         )
   set(USE_MGR_WINDOW_DEFAULT             ON         )
   set(DISABLE_WINDOW_HANDLING_DEFAULT    ON         )

elseif(TARGET_KC22)

   set(BUILD_NA_BCORE_CLIENT_SH_DEFAULT OFF        )
   set(USE_MGR_WINDOW_DEFAULT             OFF        )
   set(FCALLCPP_ADAPTOR_DEFAULT           OFF        )

elseif(TARGET_LEGATO_AR7)

   set(USE_GLESV2_DEFAULT                 OFF        )
   set(USE_MGR_OPENGL_QT_DEFAULT          OFF        )
   set(USE_MGR_OPENGL_EGL_DEFAULT         OFF        )
   set(OPT_NABASE_GRAPHICS_DEFAULT        OFF        )
   set(DBUS_ADAPTOR_DEFAULT               OFF        )
   set(USE_QT_DEFAULT                     OFF        )
   set(USE_MGR_WINDOW                     OFF        )
   set(EGL_LIBRARIES                      ""         )
   set(LINK_NA_BCORE_SH_DEFAULT         OFF        )
   set(LINK_NA_BCORE_CLIENT_SH_DEFAULT  OFF        )
   set(LINK_NA_BCORE_EXE_DEFAULT        OFF        )
   set(BUILD_NA_BCORE_SH_DEFAULT        OFF        )
   set(BUILD_NA_BCORE_CLIENT_SH_DEFAULT OFF        )
   set(BUILD_NA_BCORE_EXE_DEFAULT       OFF        )

elseif(TARGET_SABRE_IMX6)

   set(SYSTEM_ICU_DEFAULT                 OFF        )
   set(USE_GLESV2_DEFAULT                 ON         )

elseif(TARGET_AGL_AARCH64)

   set(USE_QT_DEFAULT                     ON         )
   set(USE_MGR_WINDOW_DEFAULT             ON         )
   set(USE_GLESV2_DEFAULT                 ON         )
   set(NABASE_EGL_BACKEND_DEFAULT         "Qt"       )
   set(BUILD_NA_BCORE_SH_DEFAULT        ON         )
   set(BUILD_NA_BCORE_EXE_DEFAULT       OFF        )
   set(DBUS_ADAPTOR_DEFAULT               ON         )
   set(JNI_ADAPTOR_DEFAULT                OFF        )
   set(FCALLCPP_ADAPTOR_DEFAULT           ON         )
   set(SYSTEM_ICU_DEFAULT                 ON         )
   set(SYSTEM_OPENSSL_DEFAULT             ON         )
   set(SYSTEM_CURL_DEFAULT                ON         )
   set(USE_MGR_WINDOW_DEFAULT             ON         )

elseif(TARGET_APTIV_LINUX)

   set(USE_QT_DEFAULT                     OFF        )
   set(USE_GLESV2_DEFAULT                 ON         )
   set(NABASE_EGL_BACKEND_DEFAULT         "Wayland"  )

elseif(TARGET_TDA4_LINUX)
   set(USE_GLESV2_DEFAULT                 ON         )

elseif(TARGET_TDA4_QNX)
   set(USE_GLESV2_DEFAULT                 ON         )
endif()

if(NOT CMAKE_CROSSCOMPILING AND (WIN32 OR (CMAKE_SYSTEM_NAME STREQUAL "Linux")))
   # enable TempoGiusto plugins
   set(WITH_PLUGINS_DEFAULT               ON         )
endif()

if(NA_COVERAGE_BUILD)
   set(SYSTEM_BOOST_DEFAULT    ON)
   set(SYSTEM_CURL_DEFAULT     ON)
   set(SYSTEM_ICU_DEFAULT      ON)
   set(SYSTEM_JPEG_DEFAULT     ON)
   set(SYSTEM_LZ4_DEFAULT      ON)
   set(SYSTEM_OPENSSL_DEFAULT  ON)
   set(SYSTEM_PNG_DEFAULT      ON)
   set(SYSTEM_PROTOBUF_DEFAULT ON)
#  set(SYSTEM_TINYXML_DEFAULT  ON)
   set(SYSTEM_ZLIB_DEFAULT     ON)
endif()

### global configuration options #################################################################################

GLOBAL_OPTION(USE_DYNAMIC_DEPLOY  ON  "Use dynamic deploy (on) or legacy deploy (off)" )
GLOBAL_OPTION(USE_GLESV2          OFF "Use OpenGl ES 2.0 instead of OpenGL"            )
GLOBAL_OPTION(USE_GLESV3_0        OFF "Add OpenGl ES 3.0 features, if USE_GLESV2 is enabled")
GLOBAL_OPTION(USE_GLESV3_1        OFF "Add OpenGl ES 3.1 features, if USE_GLESV2 is enabled")
GLOBAL_OPTION(USE_FLITE           OFF "Use Flite from the operating system"            )
GLOBAL_OPTION(USE_NUANCE          ON  "Use Nuance from the operating system"           )
GLOBAL_OPTION(USE_QT              ON  "Depend on Qt"                                   )
GLOBAL_OPTION(USE_QT_GLESV2       OFF "Use GLESV2 from QT instead of external/angle"   )
GLOBAL_OPTION(USE_DLT_LIB         ON  "Use DLT library"                                )

GLOBAL_OPTION(SYSTEM_BOOST        OFF "Use Boost from the operating system"            )
GLOBAL_OPTION(SYSTEM_CURL         OFF "Use libcurl from the operating system"          )
GLOBAL_OPTION(SYSTEM_DLT          OFF "Use libdlt from the operating system"           )
GLOBAL_OPTION(SYSTEM_ICU          OFF "Use libicu* from the operating system"          )
GLOBAL_OPTION(SYSTEM_JPEG         OFF "Use libjpeg from the operating system"          )
GLOBAL_OPTION(SYSTEM_LZ4          OFF "Use liblz4 from the operating system"           )
GLOBAL_OPTION(SYSTEM_OPENSSL      OFF "Use openssl from the operating system"          )
GLOBAL_OPTION(SYSTEM_PNG          OFF "Use libpng from the operating system"           )
GLOBAL_OPTION(SYSTEM_ZLIB         OFF "Use libtlib from the operating system"          )
GLOBAL_OPTION(SYSTEM_PROTOBUF     OFF "Use protobuf from the operating system"         )
GLOBAL_OPTION(SYSTEM_TINYXML      OFF "Use tinyxml from the operating system"          )
GLOBAL_OPTION(SYSTEM_ZLIB         OFF "Use zlib from the operating system"             )

GLOBAL_OPTION(WITH_PLUGINS        OFF "Build TempoGiusto plugins"                      )
GLOBAL_OPTION(WITH_ASAN           OFF "Build with ASAN"                                )

GLOBAL_OPTION(USE_QT_LAYERMANAPP  OFF "Use QtLayermanagerApp"                          )
GLOBAL_OPTION(USE_MGR_WINDOW      ON  "Use external WindowManager"                     )

if(USE_DYNAMIC_DEPLOY)
   add_definitions("-DUSE_DYNAMIC_DEPLOY")
endif()

### linktype configuration options   ##########################################################

# Those who have options at the right of their setting, are configurable.
# Only the mentioned settings are allowed
# NONE   = The module shall not be used
# STATIC = The module gets linked statically
# SHARED = The module from the source tree will be compiled as a shared lib and linked at program start
# SYSTEM = The module is taken as shared library from the operating system and linked at program start
# The setting values must be written in capital letters (=uppercase)

# TODO: Setting these values to something else than STATIC currently is NOT possible yet.
#       There will be 2 problems when you do that:
#       (a) a clean build will fail with error
#           fatal error LNK1104: cannot open file '..\..\..\external\libjpeg\Debug\libjpeg.lib'
#       (b) unittest(s) execution will fail due to "missing DLL" - reason is that the resulting DLL
#           will not be found by the unittest executable

if(NOT DLT_LIB_LINKTYPE)
   SetIfUndefined(DLT_LIB_LINKTYPE  STATIC)     #  (static,shared)
endif()

# Honor "global default options" for specific targets mentioned above
if(SYSTEM_BOOST)
   SetIfUndefined(BOOST_LINKTYPE    SYSTEM)     #  (static,SHARED,system)
endif()

if(SYSTEM_CURL)
  SetIfUndefined(CURL_LINKTYPE      SYSTEM)     #  (static,SHARED,system)
endif()

if(SYSTEM_OPENSSL)
   SetIfUndefined(OPENSSL_LINKTYPE  SYSTEM)     #  (static,SHARED,system)
endif()

if(SYSTEM_JPEG)
   SetIfUndefined(JPEG_LINKTYPE     SYSTEM)     #  (static,SHARED,system)
endif()

if(SYSTEM_LZ4)
   SetIfUndefined(LZ4_LINKTYPE      SYSTEM)     #  (static,SHARED,system)
endif()

if(SYSTEM_PNG)
   SetIfUndefined(PNG_LINKTYPE      SYSTEM)     #  (static,SHARED,system)
endif()

if(SYSTEM_ZLIB)
   SetIfUndefined(ZLIB_LINKTYPE     SYSTEM)     #  (static,SHARED,system)
endif()

if(SYSTEM_PROTOBUF)
   SetIfUndefined(PROTOBUF_LINKTYPE SYSTEM)     #  (static,shared,system)
endif()

if(   SYSTEM_ICU
   OR TARGET_PLATFORM_LINUX_IMX6
   OR TARGET_PLATFORM_LINUX_X86
   OR TARGET_KC22
   OR TARGET_KC30)
   SetIfUndefined(ICU_LINKTYPE      SYSTEM)
endif()

if(ANDROID)
   # problems on some Android targets with different icu libs (cannot link, missing some symbols)
   set(ICU_LINKTYPE STATIC)
   # see http://userguide.icu-project.org/packaging#TOC-Link-to-ICU-statically
   add_definitions(-DU_STATIC_IMPLEMENTATION)
endif()

if(   SYSTEM_TINYXML
#  OR TARGET_PLATFORM_LINUX_IMX6
   OR TARGET_PLATFORM_LINUX_X86)
   SetIfUndefined(TINYXML_LINKTYPE  SYSTEM)
endif()

if (SYSTEM_ZLIB)
   SetIfUndefined(ZLIB_LINKTYPE     SYSTEM)
endif()

#SetIfUndefined(7Z_LINKTYPE          STATIC)     #  (static,shared)
SetIfUndefined(ASSIMP_LINKTYPE      STATIC)     #  (static,shared)
SetIfUndefined(BOOST_LINKTYPE       STATIC)     #  (static,shared,system)
SetIfUndefined(CRYPTOPP_LINKTYPE    STATIC)     #  (static,shared)
SetIfUndefined(CURL_LINKTYPE        SHARED)     #  (static,shared,system)
SetIfUndefined(GLEW_LINKTYPE        STATIC)     #  (static,shared)
SetIfUndefined(ICU_LINKTYPE         SHARED)     #  (none,shared,system)
SetIfUndefined(JSONCPP_LINKTYPE     STATIC)     #  (static,shared)
SetIfUndefined(JPEG_LINKTYPE        STATIC)     #  (static,shared,system)
SetIfUndefined(JSONCPP_LINKTYPE     STATIC)     #  (static,shared)
SetIfUndefined(LZ4_LINKTYPE         STATIC)     #  (static,shared)
SetIfUndefined(KTX_LINKTYPE         STATIC)     #  (static,shared)
SetIfUndefined(LUA_LINKTYPE         STATIC)     #  (static,shared)
SetIfUndefined(MINIZIP_LINKTYPE     STATIC)     #  (static,shared)
SetIfUndefined(OPENSSL_LINKTYPE     STATIC)     #  (static,shared,system)
SetIfUndefined(PNG_LINKTYPE         STATIC)     #  (static,shared,system)
SetIfUndefined(PROTOBUF_LINKTYPE    STATIC)     #  (static,shared,system)
SetIfUndefined(SQLITENDS_LINKTYPE   STATIC)     #  (static,shared)
SetIfUndefined(TINYXML_LINKTYPE     STATIC)     #  (static,shared,system)
SetIfUndefined(ZLIB_LINKTYPE        STATIC)     #  (static,shared,system)

### determine version ############################################################################################

GetVersionGit()
set(BCORE_VERSION ${VERSION_GIT_FULL})
message(STATUS "BCORE_VERSION = ${BCORE_VERSION}")

### dump all cmake variables #####################################################################################

# un-comment when you need this for debugging our build process
#DumpAllCMakeVariables()

### global header search pathes ##################################################################################

na_include_directories(BEFORE SYSTEM external)     # 'external' folder
na_include_directories(BEFORE ${CMAKE_BINARY_DIR}) # root folder of generated products (e.g. for generated headers)
na_include_directories(BEFORE ${CMAKE_SOURCE_DIR}) # root folder of sources

### documentation ################################################################################################

# No if(WITH_DOCS) here - if necessary, this is done *inside* the 'doc' subdirectory.
# Even better would be to have dedicated make targets doc_*, but the problem with those currently is
# That they *always* get built instead of just when you explicitly build them.
add_subdirectory(doc)

### ApiFiddler ###################################################################################################

include(ApiFiddler)

### libicu #######################################################################################################
if(NOT TARGET_TDA4_LINUX AND NOT TARGET_TDA4_QNX)
   if(ICU_LINKTYPE STREQUAL "SYSTEM")
      if(CMAKE_VERSION VERSION_LESS "3.7.0")
         find_package(NaICU REQUIRED COMPONENTS i18n uc data)
      else()
         #set(ICU_DEBUG ON)
         find_package(ICU REQUIRED COMPONENTS i18n uc data)
      endif()
   elseif(NOT ICU_LINKTYPE STREQUAL "NONE")
      # Needs to be included before boost so boost can use libicu
      add_subdirectory(external/icu)
      na_include_directories(BEFORE SYSTEM ${ICU_INCLUDE_DIRS})
   endif()
   if(ICU_FOUND)
      add_definitions("-DNA_HAVE_ICU")
      message(STATUS "ICU: ${ICU_VERSION}")
      message(STATUS "ICU: ${ICU_INCLUDE_DIRS}")
      message(STATUS "ICU: ${ICU_LIBRARIES}")
   else()
      message(STATUS "ICU: not available")
   endif()
endif()
### zlib #########################################################################################################

# BOOST configuration depends on zlib, so include before boost
if(ZLIB_LINKTYPE STREQUAL "SYSTEM")
   find_package(ZLIB REQUIRED)
else()
   add_subdirectory(external/zlib)
   set(ZLIB_INCLUDE_DIR external/zlib)
   set(ZLIB_FOUND TRUE)
endif()

if(ZLIB_FOUND)
   na_include_directories(BEFORE SYSTEM ${ZLIB_INCLUDE_DIR})
   message(STATUS "ZLIB: ${ZLIB_INCLUDE_DIR}")
   message(STATUS "ZLIB: ${ZLIB_LIBRARY}")
endif()

### boost ########################################################################################################

if(BOOST_LINKTYPE STREQUAL "SYSTEM")
   find_package(Boost 1.55.0 COMPONENTS filesystem regex thread system REQUIRED ) #  container
else()
   find_package(LocalBoost)
   add_subdirectory(external/boost)
endif()

if(Boost_FOUND)
   add_definitions("-DNA_HAVE_BOOST")
   # Additional BOOST configuration switches
   list(APPEND BOOST_CONFIG_DEFINES BOOST_ALL_NO_LIB)
   list(REMOVE_DUPLICATES BOOST_CONFIG_DEFINES)
   set_property(DIRECTORY APPEND PROPERTY COMPILE_DEFINITIONS ${BOOST_CONFIG_DEFINES})
   na_include_directories(BEFORE ${Boost_INCLUDE_DIRS})
   message(STATUS "Boost_VERSION       = ${Boost_MAJOR_VERSION}.${Boost_MINOR_VERSION}.${Boost_SUBMINOR_VERSION}")
   message(STATUS "Boost_INCLUDE_DIRS  = ${Boost_INCLUDE_DIRS}")
   message(STATUS "Boost_LIBRARIES     = ${Boost_LIBRARIES}")
   message(STATUS "BOOST_CONFIG_DEFINES= ${BOOST_CONFIG_DEFINES}")
   unset(BOOST_CONFIG_DEFINES)
endif()

### Qt ###########################################################################################################

if(USE_QT)
   message(STATUS "Use Qt")
   include(cmake/na-qt5-gui-default.cmake)
   include(cmake/na-qt5-network-default.cmake)

   # needed for QtQuickWindow in WidgetManager
   find_package(Qt5Quick REQUIRED)
   add_definitions(${Qt5Quick_DEFINITIONS})
   na_include_directories(BEFORE SYSTEM ${Qt5Quick_INCLUDE_DIRS})
endif()

### WidgetManager ################################################################################################

if(NOT NABASE_EGL_BACKEND_DEFAULT)
   if(USE_QT)
      set(NABASE_EGL_BACKEND_DEFAULT "Qt")
   endif()
endif()

### dlt ##########################################################################################################

if(WIN32 OR APPLE OR IOS OR ANDROID OR TARGET_LG_QNX OR TARGET_TDA4_LINUX OR TARGET_TDA4_QNX)
   # no DLT library currently exists
   message(STATUS "DLT: library not available.")
else()
   if(USE_DLT_LIB)
      if(SYSTEM_DLT)
         find_package(DltLib REQUIRED )
         # DLTLIBRARY_LIBRARIES should be set by find_package
      else()
         add_subdirectory(external/dlt-daemon/lib)
         # manually set DLTLIBRARY_LIBRARIES
         set(DLTLIBRARY_LIBRARIES dltlib)
      endif()
      na_include_directories(BEFORE SYSTEM ${DLTLIBRARY_INCLUDE_DIRS})
      add_definitions("-DUSE_DLT_LIB")
      message(STATUS "DLTLIBRARY_INCLUDE_DIRS = ${DLTLIBRARY_INCLUDE_DIRS}")
      message(STATUS "DLTLIBRARY_LIBRARIES    = ${DLTLIBRARY_LIBRARIES}")
      message(STATUS "DLT_LIB_LINKTYPE        = ${DLT_LIB_LINKTYPE}")
   else()
      message(STATUS "DLT: library not used.")
   endif()
endif()

### protobuf #####################################################################################################

find_package(LocalProtobuf)
if(NOT PROTOBUF_LINKTYPE STREQUAL "SYSTEM")
   na_include_directories(BEFORE SYSTEM ${PROTOBUF_INCLUDE_DIRS})
endif()

### minizip ######################################################################################################

add_subdirectory(external/minizip)
na_include_directories(BEFORE SYSTEM external/minizip)

### mecab ########################################################################################################
#delete by donggq 20190519
#add_subdirectory(external/mecab)
#if(MECAB_FOUND)
#   message(STATUS "MECAB: ${MECAB_INCLUDE_DIRS}")
#   message(STATUS "MECAB: ${MECAB_LIBRARIES}")
#   add_definitions("-DNA_HAVE_MECAB")
#endif()


### lz4 ##########################################################################################################

if(LZ4_LINKTYPE STREQUAL "SYSTEM")
   find_package(LZ4 REQUIRED)
else()
  add_subdirectory(external/lz4)
  na_include_directories(BEFORE SYSTEM external/lz4/lib)
endif()

if(LZ4_FOUND)
   na_include_directories(BEFORE SYSTEM ${LZ4_INCLUDE_DIR})
   message(STATUS "LZ4: ${LZ4_INCLUDE_DIR}")
   message(STATUS "LZ4: ${LZ4_LIBRARY}")
endif()

### sqlitends ####################################################################################################

add_subdirectory(external/sqlitends)
na_include_directories(BEFORE SYSTEM external/sqlitends)

### parkingdbadaptor ####################################################################################################

add_subdirectory(external/parkingdbadaptor)
na_include_directories(BEFORE SYSTEM external/parkingdbadaptor)
na_include_directories(BEFORE SYSTEM external/parkingdbadaptor/include)
na_include_directories(BEFORE SYSTEM external/parkingdbadaptor/OSAdaptor/include)

### jni ##########################################################################################################

# locate JNI headers and libraries
if(NOT ANDROID)
  find_package(JNI)
  if( JNI_FOUND)
    na_include_directories(BEFORE ${JNI_INCLUDE_DIRS})
  endif()
else()
  # the standard script does not work with Android
  set( JNI_INCLUDE_DIRS "")
  set( JNI_LIBRARIES "-landroid")
  set( JNI_FOUND TRUE)
endif()

### libjpeg ######################################################################################################

if(JPEG_LINKTYPE STREQUAL "SYSTEM")
   find_package(JPEG REQUIRED)
   set(JPEG_LIBNAME ${JPEG_LIBRARY})
else()
   add_subdirectory(external/libjpeg)
   set(JPEG_INCLUDE_DIR external/libjpeg)
   set(JPEG_LIBNAME libjpeg)
   set(JPEG_FOUND TRUE)
endif()

if(JPEG_FOUND)
   na_include_directories(BEFORE SYSTEM ${JPEG_INCLUDE_DIR})
   message(STATUS "JPEG: ${JPEG_INCLUDE_DIR}")
   message(STATUS "JPEG: ${JPEG_LIBRARY}")
   message(STATUS "JPEG: ${JPEG_LIBNAME}")
endif()

### libpng #######################################################################################################

if(PNG_LINKTYPE STREQUAL "SYSTEM")
   find_package(PNG REQUIRED)
   set(PNG_LIB_NAME ${PNG_LIBRARY})
   set(PNG_LIB_NAME_STATIC ${PNG_LIB_NAME})
else()
   if(PNG_LINKTYPE STREQUAL "STATIC")
      set(PNG_STATIC ON)
   endif()

   if(PNG_LINKTYPE STREQUAL "SHARED")
      set(PNG_SHARED ON)
   endif()

   set(PNG_TESTS        OFF)
   set(SKIP_INSTALL_ALL ON)

   add_subdirectory(external/libpng)
   set(PNG_INCLUDE_DIRS external/libpng)

   if( NOT DEFINED PNG_LIB_NAME_STATIC)
      set(PNG_LIB_NAME_STATIC ${PNG_LIB_NAME})
   endif()
   set(PNGLIB_FOUND TRUE)
   set(PNG_FOUND TRUE)
endif()

if(PNG_FOUND)
   na_include_directories(BEFORE SYSTEM ${PNG_INCLUDE_DIRS})
   message(STATUS "PNG: ${PNG_INCLUDE_DIRS}")
   message(STATUS "PNG: ${PNG_LIBRARY}")
   message(STATUS "PNG_LIB_NAME        ->" ${PNG_LIB_NAME})
   message(STATUS "PNG_LIB_NAME_STATIC ->" ${PNG_LIB_NAME_STATIC})
endif()

### lua ##########################################################################################################

add_subdirectory(external/lua)
na_include_directories(BEFORE SYSTEM external/lua)

### tinyxml ######################################################################################################

if(TINYXML_LINKTYPE STREQUAL "SYSTEM")
   find_package(TinyXML REQUIRED)
else()
  na_include_directories(BEFORE SYSTEM external/tinyxml)
  add_subdirectory(external/tinyxml)
  set(TinyXML_FOUND TRUE)
  set(TinyXML_INCLUDE_DIRS external/tinyxml)
  set(TinyXML_LIBRARIES tinyxml)
endif()

if(TinyXML_FOUND)
   message(STATUS "TinyXML: ${TinyXML_INCLUDE_DIRS}")
   message(STATUS "TinyXML: ${TinyXML_LIBRARIES}")
endif()

### jsoncpp ######################################################################################################

na_include_directories(BEFORE SYSTEM external/jsoncpp/dist/json)
add_subdirectory(external/jsoncpp/dist)

### OpenSSL ######################################################################################################

if(OPENSSL_LINKTYPE STREQUAL "SYSTEM")
   find_package(OpenSSL 1.0.2 EXACT REQUIRED)
   if(OPENSSL_FOUND AND NOT DEFINED OPENSSL_LIBRARIES)
      set(OPENSSL_LIBRARIES ${OPENSSL_SSL_LIBRARY};${OPENSSL_CRYPTO_LIBRARY})
   endif()
else()
   find_package(LocalOpenSSL)
endif()

if(OPENSSL_FOUND)
   na_include_directories(BEFORE SYSTEM ${OPENSSL_INCLUDE_DIR})
   message(STATUS "OpenSSL: ${OPENSSL_INCLUDE_DIR}")
   message(STATUS "OpenSSL: ${OPENSSL_LIBRARIES}")
   message(STATUS "OpenSSL: ${OPENSSL_VERSION}")
endif()

### curl #########################################################################################################

if(CURL_LINKTYPE STREQUAL "SYSTEM")
   find_package(CURL REQUIRED)
   set(CURL_LIBNAME ${CURL_LIBRARY})
else()
   add_subdirectory(external/curl)
   set(CURL_INCLUDE_DIRS external/curl/include)
   set(CURL_LIBNAME libcurl)
   set(CURL_LIBRARY libcurl)
   set(CURL_FOUND TRUE)
endif()

if(CURL_FOUND)
   na_include_directories(BEFORE SYSTEM ${CURL_INCLUDE_DIRS})
   message(STATUS "Curl: ${CURL_INCLUDE_DIRS}")
   message(STATUS "Curl: ${CURL_LIBRARY}")
endif()

message(STATUS "Curl: CURL_STATICLIB: ${CURL_STATICLIB}")
message(STATUS "Curl: CURL_LINKTYPE:  ${CURL_LINKTYPE}")

### ANGLE ########################################################################################################

if(WIN32)
   if (USE_QT_GLESV2)
      # we want to use th EGL-libs(angle) from QT
      find_package(Qt5OpenGL REQUIRED)
      if (Qt5OpenGL_FOUND)
         add_definitions(${Qt5OpenGL_DEFINITIONS})
         # use GL_GLEXT_PROTOTYPES
         add_definitions(-DGL_GLEXT_PROTOTYPES)

         include_directories(SYSTEM ${Qt5OpenGL_INCLUDE_DIRS})

         # append ANGLE directories CMAKE search paths
         list(APPEND CMAKE_INCLUDE_PATH "${_qt5Core_install_prefix}/include/QtANGLE")
         list(APPEND CMAKE_LIBRARY_PATH "${_qt5Core_install_prefix}/lib")

         install(FILES "${_qt5Core_install_prefix}/bin/libEGL.dll"         DESTINATION bin)
         install(FILES "${_qt5Core_install_prefix}/bin/libGLESv2.dll"      DESTINATION bin)
      else()
         message(WARNING "Qt5OpenGL/EGL not found. Fallback to external/angle")
         add_subdirectory(external/angle)
      endif()
   else()
      # on Win32, GLES and EGL libraries are provided by ANGLE
      add_subdirectory(external/angle)
   endif()
endif()

### glew / GLESv2 & GLESv3 #######################################################################################

if(USE_GLESV3_0 OR USE_GLESV3_1)
   if(NOT USE_GLESV2)
      message(FATAL_ERROR, "The switch USE_GLES3_* requires the switch USE_GLESV2 to be enabled!")
   endif()
endif()

if(NOT TARGET_LEGATO_AR7) # TODO use feature switch instead
   if(USE_GLESV2)
      add_definitions("-DUSE_GLESV2")
      add_definitions("-DKTX_OPENGL_ES2")
      find_package(GLES2 REQUIRED)
      if(GLES2_FOUND)
         na_include_directories(BEFORE SYSTEM ${GLES2_INCLUDE_DIRS})
      endif()

      if(USE_GLESV3_0 OR USE_GLESV3_1)
         if(USE_GLESV3_1)
            add_definitions("-DUSE_GLESV3_1")
         elseif(USE_GLESV3_0)
            add_definitions("-DUSE_GLESV3_0")
         endif()
         find_package(GLES3 REQUIRED)
         if(GLES3_FOUND)
            na_include_directories(BEFORE SYSTEM ${GLES3_INCLUDE_DIRS})
         endif()
      endif()

   else() # fallback to glew
      find_package(OpenGL)
      add_definitions("-DGLEW_NO_GLU")
      add_definitions("-DGLEW_STATIC")
      add_subdirectory(external/glew)
      na_include_directories(BEFORE SYSTEM external/glew/include)
   endif()
endif()

### EGL ##########################################################################################################

find_package(EGL)
if(EGL_FOUND)
   message(STATUS "EGL_INCLUDE_DIRS: ${EGL_INCLUDE_DIRS}")
   message(STATUS "EGL_LIBRARIES:    ${EGL_LIBRARIES}")

   add_definitions("-DMESA_EGL_NO_X11_HEADERS") # prevents X11 to swamp the environment with macros via MESA egl/gles headers
   add_definitions("-DEGL_NO_X11")
   add_definitions("-DHAVE_EGL")
   na_include_directories(BEFORE SYSTEM ${EGL_INCLUDE_DIRS})
endif()

### VideoCore ####################################################################################################

find_package(VideoCore QUIET)

### Websocketpp ##################################################################################################

add_subdirectory(external/websocketpp)
na_include_directories(BEFORE external/websocketpp)
set(WEBSOCKETPP_FOUND TRUE)

### X11 ##########################################################################################################

find_package(X11)

### Wayland ######################################################################################################
if(NOT TARGET_TDA4_LINUX AND NOT TARGET_TDA4_QNX)
find_package(Wayland QUIET)
endif()
### libktx #######################################################################################################

if(NOT TARGET_LEGATO_AR7)
   na_include_directories(BEFORE SYSTEM external/libktx/include)
   add_subdirectory(external/libktx)
endif()

### assimp #######################################################################################################

na_include_directories(BEFORE SYSTEM external/assimp/include)
add_subdirectory(external/assimp/code)

### flite ########################################################################################################

# TODO: this is duplicated in funit/speech - cleanup!
if(USE_FLITE)
   find_package(Flite QUIET)
   if(FLITE_FOUND)
      add_definitions("-DUSE_FLITE")
      na_include_directories(BEFORE SYSTEM ${FLITE_INCLUDE_DIR})
   endif()
endif()

### 7z ###########################################################################################################

#add_subdirectory(external/7z)

### cryptopp #####################################################################################################

# unfortunately these defines are used in a header, so all #includers need it :(
add_definitions(-DNO_OS_DEPENDENCE)

# Don't build assembler code at all.
# It breaks the build on too many platforms.
# If someone needs this, please change the if statement accordingly to
# only activate it for this platform.
#if(NOT <supported platform>)
   add_definitions(-DCRYPTOPP_DISABLE_ASM)
   add_definitions(-DCRYPTOPP_DISABLE_SSE2)
#endif()

### armadillo ####################################################################################################

if(ANDROID)
   # no full support for C++11
   add_definitions(-DARMA_DONT_USE_CXX11)
endif()

#add_subdirectory(external/armadillo)
#na_include_directories(BEFORE SYSTEM external/armadillo/include)

### IMAR #########################################################################################################

#add_subdirectory(external/imar)
#set(IMAR_FMS_FOUND TRUE)

### GPIO #########################################################################################################

#if(TARGET_RASPBIAN)
#   add_subdirectory(external/gpio)
#   set(GPIO_RASPBIAN_FOUND TRUE)
#endif()

### Tinkerforge ##################################################################################################

#add_subdirectory(external/tinkerforge)
#set(TINKERFORGE_BINDINGS_FOUND TRUE)

### dbus #########################################################################################################

#if(DBUS_ADAPTOR) # cannot evaluate this switch here at this time because it will be set with a value in iface/adaptor (below), i.e., *later*! todo: cleanup
   find_package(DBUS)
   if(DBUS_FOUND)
      na_include_directories(BEFORE SYSTEM ${DBUS_INCLUDE_DIRS})
   endif()
#endif()


if(TARGET_TDA4_LINUX)
   #add_subdirectory(external/tidisplayadaptor)
   na_include_directories(BEFORE SYSTEM external/tidisplayadaptor/include)
   set(TIDISPLAYADAPTOR_FOUND TRUE)
   set(TIDISPLAYADAPTOR_INCLUDE_DIRS external/tidisplayadaptor/include)
   set(TIDISPLAYADAPTOR_LIBRARIES ti_display_adaptor)
   message(STATUS "TARGET is TDA4 with linux OS ")
elseif(TARGET_TDA4_QNX)
   link_directories(
      # $ENV{SDKROOT}/usr/lib
      $ENV{SDKROOT}/tilib
      # $ENV{TISDKROOT}/imaging/lib/J7/A72/QNX/release
      # $ENV{TISDKROOT}/vision_apps/lib/J7/A72/QNX/release
      # $ENV{TISDKROOT}/vision_apps/out/J7/A72/QNX/release
      # $ENV{TISDKROOT}/tiovx/lib/J7/A72/QNX/release
      # $ENV{TISDKROOT}/tiovx/lib/J7/A72/SYSBIOS/release
   )
   set(DISPLAY_MANAGER_FOUND TRUE)
   message(STATUS "TARGET is TDA4 with qnx OS")
endif()

### base libraries ###############################################################################################

# determine which socket and thread implementation should be used
set(NABASE_USE_SOCKETS BOOST) # use QT, BOOST or OFF, if 'BOOST' selected NABASE_USE_THREADS != OFF necessary
set(NABASE_USE_THREADS BOOST) # use QT, BOOST or OFF
set(WITH_LOGGING_LIB ON )
set(USE_LOGGING_SH   OFF)
if(USE_LOGGING_SH)
   if(NOT WITH_LOGGING_LIB)
      message(FATAL_ERROR "setting USE_LOGGING_SH==ON requires that you also set WITH_LOGGING_LIB==ON")
   endif()
   add_definitions("-DUSE_LOGGING_SH")
endif()
message(STATUS "USE_LOGGING_SH: ${USE_LOGGING_SH}")

if(USE_QT)
   set(NACL_USE_QT        ON)
else()
   set(NACL_USE_QT        OFF)
endif()

# include nacl first, so that OPT_NABASE_USE_NACL is ON
add_subdirectory(nacl)
add_subdirectory(nabase)
add_subdirectory(nanav)
add_subdirectory(nacm)

### iface ########################################################################################################

add_subdirectory(iface/mgr)
add_subdirectory(iface/adaptor)
add_subdirectory(iface/config)

### funits #######################################################################################################

add_subdirectory(funit/adas)
add_subdirectory(funit/addr)
add_subdirectory(funit/fts)
add_subdirectory(funit/location)
add_subdirectory(funit/traffictools)
add_subdirectory(funit/maneuver-calc)
add_subdirectory(funit/announce)
add_subdirectory(funit/mapview)
add_subdirectory(funit/streetview)
add_subdirectory(funit/guidanceviewer)
add_subdirectory(funit/nds)
add_subdirectory(funit/dbupdate)
add_subdirectory(funit/online-poi)
add_subdirectory(funit/poi)
add_subdirectory(funit/positioning)
add_subdirectory(funit/route)
add_subdirectory(funit/traffic)
add_subdirectory(funit/speech)
add_subdirectory(funit/laser)
add_subdirectory(funit/deststorage)
add_subdirectory(funit/vics)
add_subdirectory(funit/lane)
add_subdirectory(funit/toll)
add_subdirectory(funit/roadbook)
add_subdirectory(funit/learning)
#add_subdirectory(funit/learningnavigation)
add_subdirectory(funit/warning)
add_subdirectory(funit/tracker)
add_subdirectory(funit/hppcompiler)
add_subdirectory(funit/softupdate)

### managers #####################################################################################################

add_subdirectory(mgr/adas)
add_subdirectory(mgr/addr)
if(ANDROID AND JNI_ADAPTOR)
   add_subdirectory(mgr/android)
endif()
add_subdirectory(mgr/configuration)
add_subdirectory(mgr/fts)
add_subdirectory(mgr/dbupdate)
add_subdirectory(mgr/deststorage)
add_subdirectory(mgr/guidance)
add_subdirectory(mgr/announce)
add_subdirectory(mgr/guidanceviewer)
add_subdirectory(mgr/route)
add_subdirectory(mgr/mapviewer)
add_subdirectory(mgr/imgcomposer)
add_subdirectory(mgr/streetview)
add_subdirectory(mgr/mpd)
add_subdirectory(mgr/onecloud)
add_subdirectory(mgr/online-poi)
add_subdirectory(mgr/onoff)
add_subdirectory(mgr/otto)
add_subdirectory(mgr/poi)
add_subdirectory(mgr/traffic)
add_subdirectory(mgr/positioning)
add_subdirectory(mgr/tts)
add_subdirectory(mgr/nds)
add_subdirectory(mgr/location)
add_subdirectory(mgr/vics)
add_subdirectory(mgr/lane)
add_subdirectory(mgr/toll)
add_subdirectory(mgr/roadbook)
add_subdirectory(mgr/learning)
#add_subdirectory(mgr/learningnavigation)
add_subdirectory(mgr/blocking)
add_subdirectory(mgr/warning)
add_subdirectory(mgr/tracker)
add_subdirectory(mgr/telematics)
add_subdirectory(mgr/softupdate)

### resources ####################################################################################################

add_subdirectory(res/mapview/common)
add_subdirectory(res/mapview/nais)

add_subdirectory(res/streetview/common)
add_subdirectory(res/streetview/nais)

add_subdirectory(res/guidanceview/nais)

add_subdirectory(res/poi)

add_subdirectory(res/fts)

add_subdirectory(res/traffic/nais)

add_subdirectory(res/sds)

add_subdirectory(res/guidance/nais)

add_subdirectory(res/warning)

### SDK Example Part 1 ###########################################################################################

# It is totally ugly to have to set this define here.
# The reason is that bcore/sdk evaluates it, although it is NOT part of the SDK Example >:(((((
add_definitions("-DSDK_EXAMPLE_GETS_BUILT_FROM_INSIDE_BCORE") # TODO get rid of this

### SDK ##########################################################################################################

add_subdirectory(bcore/sdk) # TODO: abolish the use of define SDK_EXAMPLE_GETS_BUILT_FROM_INSIDE_BCORE inside it

### SDK Example Part 2 ###########################################################################################

if(FCALLCPP_ADAPTOR AND (USE_QT OR USE_QT_GLESV2) AND (BUILD_NA_BCORE_SH OR APPLE))
   if(WIN32 OR (CMAKE_SYSTEM_NAME STREQUAL "Linux") OR ANDROID OR APPLE OR TARGET_LG_QNX)
      add_subdirectory(bcore/sdk_example)
   endif()
endif()

### tools ########################################################################################################

add_subdirectory(tools/nainstr)

### generate license summary #####################################################################################

add_subdirectory(doc/licenses)

### package generation ###########################################################################################

if(NOT CPACK_GENERATOR)
   if(WIN32 OR ANDROID)
      set(CPACK_GENERATOR "ZIP")
   else()
      set(CPACK_GENERATOR "TGZ")
   endif()
endif()

set(CPACK_PACKAGE_NAME             "na_bcore"                            )
set(CPACK_PACKAGE_RELEASE          1                                       )
set(CPACK_PACKAGE_CONTACT          "")
set(CPACK_PACKAGE_VENDOR           "EasyDrive"                               )
set(CPACK_PACKAGE_VERSION          "${BCORE_VERSION}"                    )
set(CPACK_PACKAGING_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX}                 )

set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-${CPACK_PACKAGE_RELEASE}.${CMAKE_SYSTEM_NAME}.${CMAKE_SYSTEM_PROCESSOR}")

# RPM specific options
# set(CPACK_RPM_PACKAGE_REQUIRES "qt5-qtbase >= 5.2.1, qt5-qtbase-gui >= 5.2.1, dbus-libs >= 1.4.18, libcurl >= 7.22.0")
set(CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST_ADDITION /usr/etc /usr/lib/systemd /usr/lib/systemd/system)

# DEB specific options
set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE ${CMAKE_SYSTEM_PROCESSOR})

include(CPack)
