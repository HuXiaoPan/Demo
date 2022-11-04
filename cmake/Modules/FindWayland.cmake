# - Find GLES v2 (OpenGL Embedded Systems 2.0)
# Find the native GLES headers and libraries.
#
#  WAYLAND_INCLUDE_DIRS - where to find the headers WAYLAND/gl2.h, etc.
#  WAYLAND_LIBRARIES    - List of libraries to link when using WAYLAND.
#  WAYLAND_FOUND        - True when WAYLAND found.
#
# Usage Example:
# --------------------------------------------------------------------------------
# find_package(WAYLAND REQUIRED)
# include_directories(SYSTEM ${WAYLAND_INCLUDE_DIRS})
#
# target_link_libraries(myapp ${WAYLAND_LIBRARIES})
# --------------------------------------------------------------------------------

FIND_PATH( WAYLAND_INCLUDE_DIRS wayland-client.h PATHS /usr/include)
FIND_LIBRARY( WAYLAND_LIB_CLIENT wayland-client PATHS /usr/lib /usr/lib/x86_64-linux-gnu )
FIND_LIBRARY( WAYLAND_LIB_EGL    NAMES wayland-egl EGL PATHS /usr/lib /usr/lib/x86_64-linux-gnu )

set( WAYLAND_LIBRARIES ${WAYLAND_LIB_CLIENT} ${WAYLAND_LIB_EGL} )

#message(STATUS "WAYLAND INCLUDE DIRS: ${WAYLAND_INCLUDE_DIRS}.")
#message(STATUS "WAYLAND LIBRARIES: ${WAYLAND_LIBRARIES}.")

# handle the QUIET and REQUIRED arguments and set WAYLAND_FOUND to TRUE when
# all listed variables are TRUE
INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(WAYLAND DEFAULT_MSG WAYLAND_INCLUDE_DIRS WAYLAND_LIBRARIES)
