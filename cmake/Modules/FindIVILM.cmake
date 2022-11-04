set(IVILM_LIB_SEARCH_PATHS "/lib" "/usr/lib")

find_path( IVILM_INCLUDE_DIR 
           NAMES  "ilm/ilm_common.h"
           PATHS  "/include"
                  "/usr/include"
         )

find_library( IVILM_CLIENT_LIBRARY
              NAMES "ilmClient"
              PATHS ${IVILM_LIB_SEARCH_PATHS}
            )

find_library( IVILM_COMMON_LIBRARY
              NAMES "ilmCommon"
              PATHS ${IVILM_LIB_SEARCH_PATHS}
)

find_library( IVILM_CONTROL_LIBRARY
              NAMES "ilmControl"
              PATHS ${IVILM_LIB_SEARCH_PATHS}
)

#message( STATUS "IVILM_INCLUDE_DIR    : ${IVILM_INCLUDE_DIR}")
#message( STATUS "IVILM_CLIENT_LIBRARY : ${IVILM_CLIENT_LIBRARY}")
#message( STATUS "IVILM_COMMON_LIBRARY : ${IVILM_COMMON_LIBRARY}")
#message( STATUS "IVILM_CONTROL_LIBRARY: ${IVILM_CONTROL_LIBRARY}")

if( IVILM_INCLUDE_DIR AND IVILM_CLIENT_LIBRARY AND IVILM_COMMON_LIBRARY AND IVILM_CONTROL_LIBRARY)
   set( IVILM_FOUND TRUE CACHE BOOL "IVI Layer Manager found flag" )
   set( IVILM_LIBRARIES "${IVILM_CLIENT_LIBRARY}" "${IVILM_COMMON_LIBRARY}" "${IVILM_CONTROL_LIBRARY}" CACHE STRING "IVI Layer Manager libraries")
endif()

#message( STATUS "IVILM_LIBRARIES: ${IVILM_LIBRARIES}")

if( IVILM_FOUND )
   if( NOT IVILM_FIND_QUIETLY )
      message( STATUS "Found ivilm: ${IVILM_LIBRARIES}" )
   endif()
else()
   if( IVILM_FIND_REQUIRED )
      message( FATAL_ERROR "Could not find ivilm" )
   endif()
endif()
