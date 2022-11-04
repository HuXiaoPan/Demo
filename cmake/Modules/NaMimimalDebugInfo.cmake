# Helper to reduce amount on debug information during compilation of source files
#
# Usage Example:
# --------------------------------------------------------------------------------
#   include(NaMimimalDebugInfo)
#
#   set(SOURCES ComplexSource.cpp
#               StandardSource.cpp
#               BigSource.cpp)
#
#   add_executable(aprogram ${SOURCES})
#   NaMimimalDebugInfo(ComplexSource.cpp BigSource.cpp)
# --------------------------------------------------------------------------------

if(na_NaMimimalDebugInfo_INCLUDED)
  return()
endif()
SET(na_NaMimimalDebugInfo_INCLUDED 1)

MACRO(NaMimimalDebugInfo)
   if(NOT DISABLE_NAMIMIMALDEBUGINFO)
      if(   CMAKE_BUILD_TYPE MATCHES Debug
         OR CMAKE_BUILD_TYPE MATCHES DebInfo)
         if (   CMAKE_COMPILER_IS_GNUCXX
             OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
            message(STATUS "NaMimimalDebugInfo: Set -g1 on ${ARGN}")
            # -g1 provides enough debug information for backtraces
            SET_SOURCE_FILES_PROPERTIES(${ARGN} PROPERTIES COMPILE_FLAGS -g1)
         endif()
         # TODO: Visual Studio
      endif()
   endif()
ENDMACRO(NaMimimalDebugInfo)