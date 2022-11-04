# Find DBUSGLIB - find the DBUSGLIB libraries
#
# The following variables are provided:
#    DBUSGLIB_LIBRARIES   - folder with libraries to link when using dbus-glib.
#    DBUSGLIB_FOUND       - True when dbus-glib was found.

find_library(DBUSGLIB_LIBRARIES NAMES libdbus-glib-1.so PATHS /usr/lib)

# handle the QUIET and REQUIRED arguments and set DBUSGLIB_FOUND to TRUE when
# all listed variables are TRUE
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(DBUSGLIB DEFAULT_MSG DBUSGLIB_LIBRARIES)

if(DBUSGLIB_FOUND)
   message(STATUS "DBUSGLIB: ${DBUSGLIB_LIBRARIES}")
endif()
