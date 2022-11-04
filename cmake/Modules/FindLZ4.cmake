# Find LZ4 - find the lz4 includes and libraries
#
# The following variables are provided:
#    LZ4_INCLUDE_DIR   - where to find the lz4.h header
#    LZ4_LIBRARY       - lz4 library to link
#    LZ4_FOUND         - true when lz4 was found.

find_path(LZ4_INCLUDE_DIR lz4.h PATHS /usr/include /usr/local/include /opt/include)
find_library(LZ4_LIBRARY NAMES liblz4.so PATHS /usr/lib /usr/local/lib /usr/lib/x86_64-linux-gnu)

# handle the QUIET and REQUIRED arguments and set LZ4_FOUND to TRUE when
# all listed variables are TRUE
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LZ4 DEFAULT_MSG LZ4_INCLUDE_DIR LZ4_LIBRARY)
