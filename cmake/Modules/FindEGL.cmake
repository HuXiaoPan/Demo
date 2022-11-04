# - Find EGL
# Find the native EGL headers and libraries.
#
#  EGL_INCLUDE_DIRS - where to find the header EGL/egl.h
#  EGL_LIBRARIES    - List of libraries to link when using EGL.
#  EGL_FOUND        - True when EGL found.
#
# Usage Example:
# --------------------------------------------------------------------------------
# find_package(EGL REQUIRED)
# include_directories(SYSTEM ${EGL_INCLUDE_DIRS})
#
# target_link_libraries(myapp ${EGL_LIBRARIES})
# --------------------------------------------------------------------------------

FIND_PATH( EGL_INCLUDE_DIRS EGL/egl.h PATHS /opt/vc/include)
FIND_LIBRARY( EGL_LIBRARIES NAMES EGL libEGL PATHS /opt/vc/lib)

if(EGL_INCLUDE_DIRS MATCHES "^.+\\/opt\\/vc\\/include$")
   # not great, but RPi/VideoCore needs additional include paths
   list(APPEND EGL_INCLUDE_DIRS
               "${EGL_INCLUDE_DIRS}/interface/vcos/pthreads"
               "${EGL_INCLUDE_DIRS}/interface/vmcs_host/linux")
endif()

# handle the QUIET and REQUIRED arguments and set EGL_FOUND to TRUE when
# all listed variables are TRUE
INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(EGL DEFAULT_MSG EGL_INCLUDE_DIRS EGL_LIBRARIES)
