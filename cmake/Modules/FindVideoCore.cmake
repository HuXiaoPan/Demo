# Find the native Broadcom VideoCore host headers and libraries.
#
#  VIDEOCORE_INCLUDE_DIRS - where to find the headers bcm_host.h, etc.
#  VIDEOCORE_LIBRARIES    - List of libraries to link when using VideoCore libs.
#  VIDEOCORE_FOUND        - True when VideoCore libs were found.
#
# Usage Example:
# --------------------------------------------------------------------------------
# find_package(VIDEOCORE REQUIRED)
# include_directories(SYSTEM ${VIDEOCORE_INCLUDE_DIRS})
#
# target_link_libraries(myapp ${VIDEOCORE_LIBRARIES})
# --------------------------------------------------------------------------------

FIND_PATH( VIDEOCORE_INCLUDE_DIRS bcm_host.h PATHS /usr/include /opt/vc/include)
FIND_LIBRARY( VIDEOCORE_LIBRARIES bcm_host PATHS /usr/include /opt/vc/lib)

# handle the QUIET and REQUIRED arguments and set VIDEOCORE_FOUND to TRUE when
# all listed variables are TRUE
INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(VIDEOCORE DEFAULT_MSG VIDEOCORE_INCLUDE_DIRS VIDEOCORE_LIBRARIES)

