# Find gdk-pixbuf v2 - find the gdk-pixbuf includes
#
# The following variables are provided:
#    GDK-PIXBUF_INCLUDE_DIR - where to find the headers gdk-pixbuf/gdk-pixbuf.h, etc.
#    GDK-PIXBUF_LIBRARIES   - folder with libraries to link when using glib-2.0.
#    GDK-PIXBUF_FOUND       - True when glib-2.0 was found.
#
# Usage Example:
#    include_directories(SYSTEM ${GDK-PIXBUF_INCLUDE_DIR})
#    target_link_libraries(myapp ${GDK-PIXBUF_LIBRARIES})


find_path(GDK-PIXBUF_INCLUDE_DIR gdk-pixbuf/gdk-pixbuf.h PATHS /usr/include/gdk-pixbuf-2.0 /opt/include/gdk-pixbuf-2.0)
find_library(GDK-PIXBUF_LIBRARIES NAMES libgdk_pixbuf-2.0.so PATHS /usr/lib /usr/lib/x86_64-linux-gnu)

# handle the QUIET and REQUIRED arguments and set GLIB_FOUND to TRUE when
# all listed variables are TRUE
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GDK-PIXBUF DEFAULT_MSG GDK-PIXBUF_INCLUDE_DIR GDK-PIXBUF_LIBRARIES)

if(GDK-PIXBUF_FOUND)
   message(STATUS "GLIB: ${GDK-PIXBUF_INCLUDE_DIR}")
   message(STATUS "GLIB: ${GDK-PIXBUF_LIBRARIES}")
endif()
