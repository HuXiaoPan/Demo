# from https://github.com/onyx-intl/cmake_modules
#
# - Try to find Iconv 
# Once done this will define 
# 
#  Iconv_FOUND - system has Iconv 
#  Iconv_INCLUDE_DIRS - the Iconv include directory 
#  Iconv_LIBRARIES - Link these to use Iconv 
#  Iconv_SECOND_ARGUMENT_IS_CONST - the second argument for iconv() is const
# 
include(CheckCXXSourceCompiles)

IF (Iconv_INCLUDE_DIRS AND Iconv_LIBRARIES)
  # Already in cache, be silent
  SET(ICONV_FIND_QUIETLY TRUE)
ENDIF (Iconv_INCLUDE_DIRS AND Iconv_LIBRARIES)

if(ANDROID)
   message( STATUS "Iconv is currently not supported by Android")
   set(Iconv_FOUND FALSE)
else()
   FIND_PATH(Iconv_INCLUDE_DIRS iconv.h)

   FIND_LIBRARY(Iconv_LIBRARIES NAMES iconv libiconv libiconv-2 c)

   IF(Iconv_INCLUDE_DIRS AND Iconv_LIBRARIES)
      SET(Iconv_FOUND TRUE)
   ENDIF(Iconv_INCLUDE_DIRS AND Iconv_LIBRARIES)

   set(CMAKE_REQUIRED_INCLUDES ${Iconv_INCLUDE_DIRS})
   set(CMAKE_REQUIRED_LIBRARIES ${Iconv_LIBRARIES})
   IF(Iconv_FOUND)
     check_cxx_source_compiles("
     #include <iconv.h>
     int main(){
       iconv_t conv = 0;
       const char* in = 0;
       size_t ilen = 0;
       char* out = 0;
       size_t olen = 0;
       iconv(conv, &in, &ilen, &out, &olen);
       return 0;
     }
   " Iconv_SECOND_ARGUMENT_IS_CONST )
   ENDIF(Iconv_FOUND)
   set(CMAKE_REQUIRED_INCLUDES)
   set(CMAKE_REQUIRED_LIBRARIES)
endif()

IF(Iconv_FOUND) 
  IF(NOT ICONV_FIND_QUIETLY) 
    MESSAGE(STATUS "Found Iconv: ${Iconv_LIBRARIES}") 
  ENDIF(NOT ICONV_FIND_QUIETLY) 
ELSE(Iconv_FOUND) 
  IF(Iconv_FIND_REQUIRED) 
    MESSAGE(FATAL_ERROR "Could not find Iconv") 
  ENDIF(Iconv_FIND_REQUIRED) 
ENDIF(Iconv_FOUND)

MARK_AS_ADVANCED(
  Iconv_INCLUDE_DIRS
  Iconv_LIBRARIES
  Iconv_SECOND_ARGUMENT_IS_CONST
)
