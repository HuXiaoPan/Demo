# - Find GLES v2 (OpenGL Embedded Systems 2.0)
# Find the native GLES headers and libraries.
#
#  GLES2_INCLUDE_DIRS - where to find the headers gles2/gl2.h, etc.
#  GLES2_LIBRARIES    - List of libraries to link when using gles2.
#  GLES2_FOUND        - True when gles2 found.
#
# Usage Example:
# --------------------------------------------------------------------------------
# find_package(GLES2 REQUIRED)
# include_directories(SYSTEM ${GLES2_INCLUDE_DIRS})
#
# target_link_libraries(myapp ${GLES2_LIBRARIES})
# --------------------------------------------------------------------------------

FIND_PATH( GLES2_INCLUDE_DIRS GLES2/gl2.h PATHS /opt/vc/include)
FIND_LIBRARY( GLES2_LIBRARIES NAMES GLESv2 libGLESv2 PATHS /opt/vc/lib)

# handle the QUIET and REQUIRED arguments and set GLES2_FOUND to TRUE when
# all listed variables are TRUE
INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(GLES2 DEFAULT_MSG GLES2_INCLUDE_DIRS GLES2_LIBRARIES)

