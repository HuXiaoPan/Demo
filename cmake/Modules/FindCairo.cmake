# Find CAIRO - find the CAIRO includes and libraries
#
# The following variables are provided:
#    CAIRO_INCLUDE_DIR - where to find the headers cairo/cairo.h, etc.
#    CAIRO_LIBRARIES   - folder with libraries to link when using cairo.
#    CAIRO_FOUND       - True when cairo was found.
#
# Usage Example:
#    include_directories(SYSTEM ${CAIRO_INCLUDE_DIR})
#    target_link_libraries(myapp ${CAIRO_LIBRARIES})

find_path(CAIRO_INCLUDE_DIR cairo.h PATHS /usr/include/cairo /opt/include/cairo)
find_library(CAIRO_LIBRARIES NAMES libcairo.so PATHS /usr/lib /usr/lib/x86_64-linux-gnu)

# handle the QUIET and REQUIRED arguments and set CAIRO_FOUND to TRUE when
# all listed variables are TRUE
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(CAIRO DEFAULT_MSG CAIRO_INCLUDE_DIR CAIRO_LIBRARIES)

if(CAIRO_FOUND)
   message(STATUS "CAIRO: ${CAIRO_INCLUDE_DIR}")
   message(STATUS "CAIRO: ${CAIRO_LIBRARIES}")
endif()
