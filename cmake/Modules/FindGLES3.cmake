# - Find GLES v3 (OpenGL Embedded Systems 3.0)
# Find the native GLES headers and libraries.
#
#  GLES3_INCLUDE_DIRS - where to find the headers gles3/gl3.h, etc.
#  GLES3_LIBRARIES    - List of libraries to link when using gles3.
#  GLES3_FOUND        - True when gles3 found.
#
# Usage Example:
# --------------------------------------------------------------------------------
# find_package(GLES3 REQUIRED)
# include_directories(SYSTEM ${GLES3_INCLUDE_DIRS})
#
# target_link_libraries(myapp ${GLES3_LIBRARIES})
# --------------------------------------------------------------------------------

FIND_PATH( GLES3_INCLUDE_DIRS GLES3/gl3.h PATHS /opt/vc/include)
# note according to the khronos spec, the GLES3/gl3.h implementation is packed to GLESv2 lib!
# see: https://www.khronos.org/registry/implementers_guide.html#libnames
FIND_LIBRARY( GLES3_LIBRARIES NAMES GLESv2 libGLESv2 PATHS /opt/vc/lib)

# handle the QUIET and REQUIRED arguments and set GLES3_FOUND to TRUE when
# all listed variables are TRUE
INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(GLES3 DEFAULT_MSG GLES3_INCLUDE_DIRS GLES3_LIBRARIES)

