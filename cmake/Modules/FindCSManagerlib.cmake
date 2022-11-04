# Find CSMANAGERLIB - find the CSMANAGERLIB includes and libraries
#
# The following variables are provided:
#    CSMANAGERLIB_INCLUDE_DIR - where to find the headers csmanager/CSManager.h.
#    CSMANAGERLIB_LIBRARIES   - folder with libraries to link when using csmanagerlib.
#    CSMANAGERLIB_FOUND       - True when csmanagerlib was found.
#
# Usage Example:
#    include_directories(SYSTEM ${CSMANAGERLIB_INCLUDE_DIR})
#    target_link_libraries(myapp ${CSMANAGERLIB_LIBRARIES})

find_path(CSMANAGERLIB_INCLUDE_DIR CSManager.h PATHS /components/lxc_networking/CSManager/gdbus/src)
find_library(CSMANAGERLIB_LIBRARIES NAMES libcsmanagergdbus_so.so PATHS /components/lxc_networking/CSManager)

# handle the QUIET and REQUIRED arguments and set CSMANAGERLIB_FOUND to TRUE when
# all listed variables are TRUE
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(CSMANAGERLIB DEFAULT_MSG CSMANAGERLIB_INCLUDE_DIR CSMANAGERLIB_LIBRARIES)

if(CSMANAGERLIB_FOUND)
   message(STATUS "CSMANAGERLIB: ${CSMANAGERLIB_INCLUDE_DIR}")
   message(STATUS "CSMANAGERLIB: ${CSMANAGERLIB_LIBRARIES}")
endif()
