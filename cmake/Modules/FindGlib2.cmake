# Find GLIB v2 - find the GLIB includes and libraries
#
# The following variables are provided:
#    GLIB_INCLUDE_DIR - where to find the headers glib-2.0/glib.h, etc.
#    GLIB_LIBRARIES   - folder with libraries to link when using glib-2.0.
#    GLIB_FOUND       - True when glib-2.0 was found.
#
# Usage Example:
#    include_directories(SYSTEM ${GLIB_INCLUDE_DIR})
#    target_link_libraries(myapp ${GLIB_LIBRARIES})

find_path(GLIB_INCLUDE_DIR1 glib.h PATHS /usr/include/glib-2.0 /opt/include/glib-2.0)
find_path(GLIB_INCLUDE_DIR2 glibconfig.h PATHS /usr/include/glib-2.0 /opt/include/glib-2.0 /usr/lib/glib-2.0/include)
find_library(GLIB_LIBRARIES NAMES libglib-2.0.so PATHS /usr/lib /usr/lib/x86_64-linux-gnu)

list(APPEND GLIB_INCLUDE_DIR ${GLIB_INCLUDE_DIR1} ${GLIB_INCLUDE_DIR2})

# handle the QUIET and REQUIRED arguments and set GLIB_FOUND to TRUE when
# all listed variables are TRUE
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GLIB DEFAULT_MSG GLIB_INCLUDE_DIR GLIB_LIBRARIES)

if(GLIB_FOUND)
   message(STATUS "GLIB: ${GLIB_INCLUDE_DIR}")
   message(STATUS "GLIB: ${GLIB_LIBRARIES}")
endif()
