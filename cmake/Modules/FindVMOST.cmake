INCLUDE(FindPkgConfig)

set(VMOST_LIB_SEARCH_PATHS "/lib" "/usr/lib" "/usr/local/lib")

find_path( VMOST_INCLUDE_DIR 
           NAMES  "vmost.h"
           PATHS  "/include/vmost"
                  "/usr/include/vmost"
                  "/usr/local/include/vmost"
         )

find_path( VMOST_GLIB2_INCLUDE_DIR 
           NAMES  "glib.h"
           PATHS  "/include/glib-2.0"
                  "/usr/include/glib-2.0"
                  "/usr/local/include/glib-2.0"
         )

find_library( VMOST_BASE_LIBRARY
              NAMES "vmost"
              PATHS ${VMOST_LIB_SEARCH_PATHS}
)

find_library( VMOST_CLIENT_LIBRARY
              NAMES "vmostclient"
              PATHS ${VMOST_LIB_SEARCH_PATHS}
            )

#message( STATUS "VMOST_INCLUDE_DIR    : ${VMOST_INCLUDE_DIR}")
#message( STATUS "VMOST_BASE_LIBRARY   : ${VMOST_BASE_LIBRARY}")
#message( STATUS "VMOST_CLIENT_LIBRARY : ${VMOST_CLIENT_LIBRARY}")

if( VMOST_INCLUDE_DIR AND VMOST_GLIB2_INCLUDE_DIR AND VMOST_BASE_LIBRARY AND VMOST_CLIENT_LIBRARY)
   set( VMOST_FOUND TRUE CACHE BOOL "VMOST found flag" )
   set( VMOST_LIBRARIES "${VMOST_BASE_LIBRARY}" "${VMOST_CLIENT_LIBRARY}" CACHE STRING "VMOST libraries")
   set( VMOST_INCLUDE_DIRS "${VMOST_INCLUDE_DIR}" "${VMOST_GLIB2_INCLUDE_DIR}" "${VMOST_GLIB2_INCLUDE_DIR}/include" CACHE STRING "VMOST and GLIB2 headers")
endif()

#message( STATUS "VMOST_LIBRARIES: ${VMOST_LIBRARIES}")

pkg_check_modules (GLIB2   glib-2.0)
pkg_check_modules (VMOST   vmost)

if( VMOST_FOUND )
   if( NOT VMOST_FIND_QUIETLY )
      message( STATUS "Found VMOST: ${VMOST_LIBRARIES}" )
   endif()
else()
   if( VMOST_FIND_REQUIRED )
      message( FATAL_ERROR "Could not find VMOST" )
   endif()
endif()
