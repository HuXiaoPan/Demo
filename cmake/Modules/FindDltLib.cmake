# FindDltLib - find the dlt-lib includes and libraries
#
# The following variables are provided:
#    DLTLIBRARY_INCLUDE_DIRS - where to find the headers dlt.h etc.
#    DLTLIBRARY_LIBRARIES    - libraries to link when using dlt-lib.
#    DLTLIBRARY_FOUND        - True when the dlt-lib was found.
#
# Usage Example:
#    include_directories(SYSTEM ${DLTLIBRARY_INCLUDE_DIRS})
#    target_link_libraries(myapp ${DLTLIBRARY_LIBRARIES})
#
# Set the variable DLT_LIB_LINKTYPE to STATIC or SHARED to configure if the dlt-lib
# will be used for static or dynamic linking
# Set the variable DLT_LIB_PATH to configure the path where the dlt-lib headers
# and library are searched for.

if (NOT DLT_LIB_PATH)
   message(STATUS "DLTLIBRARY: using default search path")
   find_path(DLTLIBRARY_INCLUDE_DIRS dlt.h PATHS /usr/include/dlt /opt/include/dlt)
   if (${DLT_LIB_LINKTYPE} STREQUAL "STATIC")
      find_library(DLTLIBRARY_LIBRARIES NAMES libdltlib.a libdlt.a PATHS /usr/lib)
   else()
      find_library(DLTLIBRARY_LIBRARIES NAMES libdlt.so   PATHS /usr/lib)
   endif()
else()
   message(STATUS "DLTLIBRARY: using dlt-lib path ${DLT_LIB_PATH}")
   find_path(DLTLIBRARY_INCLUDE_DIRS dlt.h PATHS ${DLT_LIB_PATH}/include/dlt NO_DEFAULT_PATH NO_CMAKE_FIND_ROOT_PATH)
   if (${DLT_LIB_LINKTYPE} STREQUAL "STATIC")
      find_library(DLTLIBRARY_LIBRARIES NAMES libdltlib.a libdlt.a PATHS ${DLT_LIB_PATH}/lib NO_DEFAULT_PATH NO_CMAKE_FIND_ROOT_PATH)
   else()
      find_library(DLTLIBRARY_LIBRARIES NAMES libdlt.so   PATHS ${DLT_LIB_PATH}/lib NO_DEFAULT_PATH NO_CMAKE_FIND_ROOT_PATH)
   endif()
endif()

# handle the QUIET and REQUIRED arguments and set DLTLIBRARY_FOUND to TRUE when
# all listed variables are TRUE
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(DLTLIBRARY DEFAULT_MSG DLTLIBRARY_INCLUDE_DIRS DLTLIBRARY_LIBRARIES)

if(DLTLIBRARY_FOUND)
   message(STATUS "DLTLIBRARY_INCLUDE_DIRS: ${DLTLIBRARY_INCLUDE_DIRS}")
   message(STATUS "DLTLIBRARY_LIBRARIES: ${DLTLIBRARY_LIBRARIES}")
endif()
