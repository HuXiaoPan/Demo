# - Try to find OpenSSL include dirs and libraries
#
# This is a wrapper around find_package( OpenSSL )
#
# Currently tries
# - ${PROJECT_SOURCE_DIR}/external/openssl
#
# before checking for system installed OpenSSL
#
# Usage of this module as follows:
#
#   find_package( LocalOpenSSL )
#   if(OPENSSL_FOUND)
#      # see FindOpenSSL.cmake for details
#   endif()

# First try to find a local OpenSSL installation
if(SYSTEM_OPENSSL)
   set(DISABLE_EXTERNAL_OPENSSL ON)
endif()

# Check if use of OpenSSL from external/openssl is allowed
if ( NOT DEFINED DISABLE_EXTERNAL_OPENSSL )
   if( NOT DEFINED DISABLE_EXTERNAL_LIBS )
      set(DISABLE_EXTERNAL_OPENSSL OFF)
   else()
      set(DISABLE_EXTERNAL_OPENSSL ${DISABLE_EXTERNAL_LIBS})
   endif()
endif()

if(DISABLE_EXTERNAL_OPENSSL)
   include("${CMAKE_ROOT}/Modules/FindOpenSSL.cmake")
else()

   # NO_CMAKE_FIND_ROOT_PATH is necessary to _avoid_ prepending the
   # ROOT_PATH if cross-compiling.
   find_path(local_OPENSSL_INCLUDE_DIR
      NAMES  openssl/ssl.h
      PATHS  ${CMAKE_SOURCE_DIR}/external/openssl/include
      NO_DEFAULT_PATH
      NO_CMAKE_FIND_ROOT_PATH
   )

   if(local_OPENSSL_INCLUDE_DIR)

      # Make sure the variables are set to our values.
      set( OPENSSL_FOUND TRUE
           CACHE BOOL "OpenSSL found flag."
           FORCE
      )

      set(OPENSSL_ROOT_DIR ${CMAKE_SOURCE_DIR}/external/openssl
           CACHE PATH "OpenSSL root directory."
           FORCE
      )

      set( OPENSSL_INCLUDE_DIR ${local_OPENSSL_INCLUDE_DIR}
           CACHE PATH "OpenSSL include directory."
           FORCE
      )

      set(local_SSL_LIBS "")
      list(APPEND local_SSL_LIBS crypto)
      list(APPEND local_SSL_LIBS ssl)

      set( OPENSSL_LIBRARIES ${local_SSL_LIBS}
           CACHE STRING "OpenSSL libraries."
           FORCE
      )

      mark_as_advanced(OPENSSL_FOUND OPENSSL_ROOT_DIR OPENSSL_INCLUDE_DIR OPENSSL_LIBRARIES)

      # Avoid double add_subdirecty() in one build when FindLocalOpenSSL is included multiple times.
      get_property(local_OPENSSL_addedSubdirectory GLOBAL PROPERTY local_OPENSSL_addedSubdirectory)
      if(NOT local_OPENSSL_addedSubdirectory)
         # external openSSL is used, get the implementation
         add_subdirectory(${OPENSSL_ROOT_DIR})
         set_property(GLOBAL PROPERTY local_OPENSSL_addedSubdirectory true)
      endif()

   else()
      set( OPENSSL_FOUND FALSE
           CACHE BOOL "OpenSSL found flag."
           FORCE
      )
   endif()

   if (LocalOpenSSL_FIND_REQUIRED AND NOT OPENSSL_FOUND)
      message(SEND_ERROR "OpenSSL not found!")
   endif()
endif()
