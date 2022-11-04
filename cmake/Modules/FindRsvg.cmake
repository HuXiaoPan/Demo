# Find RSVG v2 - find the RSVG includes and libraries
#
# The following variables are provided:
#    RSVG_INCLUDE_DIR - where to find the headers librsvg-2.0/rsvg.h, etc.
#    RSVG_LIBRARIES   - folder with libraries to link when using rsvg-2.0.
#    RSVG_FOUND       - True when rsvg-2.0 was found.
#
# Usage Example:
#    include_directories(SYSTEM ${RSVG_INCLUDE_DIR})
#    target_link_libraries(myapp ${RSVG_LIBRARIES})

find_path(RSVG_INCLUDE_DIR librsvg-2.0/librsvg/rsvg.h PATHS /usr/include/librsvg-2.0 /opt/include/librsvg-2.0)
find_library(RSVG_LIBRARIES NAMES librsvg-2.so PATHS /usr/lib /usr/lib/x86_64-linux-gnu)

# handle the QUIET and REQUIRED arguments and set RSVG_FOUND to TRUE when
# all listed variables are TRUE
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(RSVG DEFAULT_MSG RSVG_INCLUDE_DIR RSVG_LIBRARIES)

if(RSVG_FOUND)
   message(STATUS "RSVG: ${RSVG_INCLUDE_DIR}")
   message(STATUS "RSVG: ${RSVG_LIBRARIES}")
endif()