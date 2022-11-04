# - Try to find Boost include dirs and libraries
#
# This is a wrapper around find_package( Boost )
#
# Currently tries
# - ${PROJECT_SOURCE_DIR}/external/boost
#
# before checking for system installed Boost
#
# Usage of this module as follows:
#
#   find_package( LocalBoost )
#   if(Boost_FOUND)
#      # see FindBoost.cmake for details
#   endif()

# First try to find a local BOOST installation

#if(NOT DEFINED Boost_DEBUG)
#   set(Boost_DEBUG TRUE)
#endif()
if(NOT DEFINED Boost_USE_MULTITHREADED)
    set(Boost_USE_MULTITHREADED TRUE)
endif()
if(NOT DEFINED Boost_USE_STATIC_LIBS)
#    set(Boost_USE_STATIC_LIBS    ON)
endif()

# Check if use of boost from external/boost is allowed
if ( NOT DEFINED DISABLE_EXTERNAL_BOOST )
   if( NOT DEFINED DISABLE_EXTERNAL_LIBS )
      set(DISABLE_EXTERNAL_BOOST OFF)
   else()
      set(DISABLE_EXTERNAL_BOOST ${DISABLE_EXTERNAL_LIBS})
   endif()
endif()

if ( NOT Boost_INCLUDE_DIRS AND NOT DISABLE_EXTERNAL_BOOST)
   # NO_CMAKE_FIND_ROOT_PATH is necessary to _avoid_ prepending the
   # ROOT_PATH if cross-compiling.

   find_path(Boost_INCLUDE_DIRS
      NAMES  boost/config.hpp
      PATHS  ${CMAKE_SOURCE_DIR}/external/boost
      NO_DEFAULT_PATH
      NO_CMAKE_FIND_ROOT_PATH
   )

   set(Boost_FOUND TRUE)
endif()

if(NOT Boost_FOUND)
  # Make sure the variables are set to our values.

   set( Boost_FOUND TRUE
        CACHE BOOL "Boost found flag."
        FORCE
   )
   set( Boost_INCLUDE_DIRS "external/boost"
        CACHE PATH "Boost include directory."
        FORCE
   )
   set( Boost_LIBRARIES ""
        CACHE STRING "Boost libraries."
        FORCE
   )

   # this is a workaround unless everybody links against ${Boost_LIBRARIES}
   set( BOOST_LIBRARIES "${Boost_LIBRARIES}")
endif()

if (Boost_LIBRARY_DIRS)
  link_directories(${Boost_LIBRARY_DIRS})
endif()

if (LocalBoost_FIND_REQUIRED AND NOT Boost_FOUND)
   message(SEND_ERROR "BOOST not found!")
endif()
