# Nuance is a Text-To-Speech software designed for automotive and personal navigation devices.
# With the software and the corresponding voice package, you will be able to develop applications
# equipped with Nuance's state of the art automotive Text-To-Speech technology.
#
# http://www.nuance.com
#
# Usage Example:
#
# in your CMakeLists.txt, reference the 3rd party library like this:
#
#    find_package(Nuance)
#    if(NUANCE_FOUND)
#       include_directories(${NUANCE_INCLUDE_DIR})
#       add_definitions("-DUSE_NUANCE")
#    endif()
#
# In C++ source code, then write:
#
#    #ifdef USE_NUANCE
#       #include "ve_ttsapi.h"
#       #include "ve_platform.h"
#    #endif
#
# Again, in the CMakeLists.txt file, link the library like this:
#
#    if(NUANCE_FOUND)
#       target_link_libraries(nuance_test ${NUANCE_LIBRARY})
#    endif()

cmake_minimum_required(VERSION 2.8)

if(NUANCE_ROOT) # check cmake variable
   set(NUANCE_INCLUDE_SEARCH_PATHS ${NUANCE_ROOT}/inc)
   set(NUANCE_LIB_SEARCH_PATHS     ${NUANCE_ROOT}/lib/static)
elseif(DEFINED ENV{NUANCE_ROOT}) # check environment variable - note that there is no $ before ENV - http://www.cmake.org/pipermail/cmake/2011-October/046706.html
   set(NUANCE_INCLUDE_SEARCH_PATHS $ENV{NUANCE_ROOT}/inc)
   set(NUANCE_LIB_SEARCH_PATHS     $ENV{NUANCE_ROOT}/lib/static)
elseif(NOT WIN32) # fallback to system wide pathes
   set(NUANCE_INCLUDE_SEARCH_PATHS /usr/include
                                   /usr/local/include)
   set(NUANCE_LIB_SEARCH_PATHS     /usr/lib
                                   /usr/local/lib)
else()								   
   # nop
endif()

find_path(   NUANCE_INCLUDE_DIR
             NAMES ve_ttsapi.h ve_platform.h
		     PATHS ${NUANCE_INCLUDE_SEARCH_PATHS})

find_library(NUANCE_LIBRARY
             NAMES ve 
			 PATHS ${NUANCE_LIB_SEARCH_PATHS}
			 NO_DEFAULT_PATH)

find_library(NUANCE_CURL_LIBRARY
             NAMES curl_nuance
			 PATHS ${NUANCE_LIB_SEARCH_PATHS}
			 NO_DEFAULT_PATH)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_ARGS(Nuance DEFAULT_MSG NUANCE_CURL_LIBRARY NUANCE_LIBRARY NUANCE_INCLUDE_DIR)

if(NUANCE_FOUND)
   set(NUANCE_INCLUDE_DIRS ${NUANCE_INCLUDE_DIR})
   set(NUANCE_LIBRARIES    ${NUANCE_CURL_LIBRARY} ${NUANCE_LIBRARY})
endif()
