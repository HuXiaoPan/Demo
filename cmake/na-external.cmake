# EasyDrive configuration off external lib use
# compiler warning levels, flags etc.

IF(NOT DEFINED DISABLE_EXTERNAL_LIBS)
   MESSAGE(FATAL_ERROR "na-external.cmake must be included *after* na-default.cmake")
   # The reason for this is that project() initializes the build environment,
   # e.g. CMAKE_C_COMPILER_ID, CMAKE_CXX_COMPILER_ID, and this file then modifies them.
ENDIF()

##################################################################################################################

# EXTERNAL_LIB_OPTION wraps option command
# Allows to disable/enable use of specify lib from external directory
# Generates a new option  DISABLE_EXTERNAL_<lib>
# If a variable DISABLE_EXTERNAL_<module> exists this value is used as default
# If a global option/variable DISABLE_EXTERNAL_LIBS exists this value is used as default
# Otherwise the default is OFF
macro(EXTERNAL_LIB_OPTION lib)
  if (DEFINED DISABLE_EXTERNAL_${lib})
    option(DISABLE_EXTERNAL_${lib} "Disable use of external ${lib}" ${DISABLE_EXTERNAL_${lib}})
  elseif (DEFINED DISABLE_EXTERNAL_LIBS)
    option(DISABLE_EXTERNAL_${lib} "Disable use of external ${lib}" ${DISABLE_EXTERNAL_LIBS})
  else()
    option(DISABLE_EXTERNAL_${lib} "Disable use of external ${lib}" OFF)
  endif()
endmacro()

EXTERNAL_LIB_OPTION(BOOST)
EXTERNAL_LIB_OPTION(CURL)
EXTERNAL_LIB_OPTION(LIBJPEG)
EXTERNAL_LIB_OPTION(LIBPNG)
EXTERNAL_LIB_OPTION(OPENSSL)
EXTERNAL_LIB_OPTION(PROTOBUF)
EXTERNAL_LIB_OPTION(ZLIB)
