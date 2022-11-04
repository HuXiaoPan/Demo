# - Find espeak
# Find the native ESPEAK headers and libraries.
#
#  ESPEAK_INCLUDE_DIRS - where to find espeak/speak_lib.h, etc.
#  ESPEAK_LIBRARIES    - List of libraries to link when using espeak.
#  ESPEAK_FOUND        - True if espeak found.
#
# Deprecated but still available for backward compatibility:
#  ESPEAK_INCLUDE_DIR - where to find espeak/speak_lib.h, etc.
#  ESPEAK_LIBRARY     - List of libraries to link when using espeak.
# Why are these deprecated? Because they violate the module variables naming
# convention of cmake 2.x: See Modules/readme.txt in your CMake installation.
#
# Usage Example:
# --------------------------------------------------------------------------------
# find_package(ESPEAK REQUIRED)
# include_directories(SYSTEM ${ESPEAK_INCLUDE_DIRS})
#
# target_link_libraries(myapp ${ESPEAK_LIBRARIES})
# --------------------------------------------------------------------------------

# Look for the header file.
FIND_PATH(ESPEAK_INCLUDE_DIRS NAMES espeak/speak_lib.h)

# Look for the library.
FIND_LIBRARY(ESPEAK_LIBRARIES NAMES espeak)

# handle the QUIET and REQUIRED arguments and set ESPEAK_FOUND to TRUE if
# all listed variables are TRUE
INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(ESPEAK DEFAULT_MSG ESPEAK_INCLUDE_DIRS ESPEAK_LIBRARIES)

if(ESPEAK_FOUND)
  # backward compatibility. Remove when all users changed to standard conform variables
  SET(ESPEAK_INCLUDE_DIR ${ESPEAK_INCLUDE_DIRS})
  SET(ESPEAK_LIBRARY ${ESPEAK_LIBRARIES})
endif()
