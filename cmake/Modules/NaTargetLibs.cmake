# Simplify linking of executables
#
# na_target_link_libraries is a wrapper around target_link_libraries
# The required standard libraries will automatic be added.
# Additional system libraries (e.g. OpenGL support) can be
# added following the SYSLIBS keyword
#
# Usage:
#    na_target_link_libraries(<target> LIBS lib1 lib2...[SYSLIBS lib...])
#
# Usage example:
# include(NaTargetLibs)
# add_library(testlib testlib1.cpp)
# na_target_link_libraries(SimpleExe LIBS testlib)
#

cmake_minimum_required(VERSION 2.8)

function(na_target_link_libraries targetname)
   set(LIBS "")
   set(SYSLIBS "")
   set(MODE 0)
   foreach(arg IN LISTS ARGN)
      if("x${arg}" STREQUAL "xLIBS")
         if (${MODE} LESS 1)
            set(MODE 1)
         else()
            message(FATAL_ERROR "Didn't expect LIBS!")
            return()
         endif()
      elseif("x${arg}" STREQUAL "xSYSLIBS")
         if (${MODE} LESS 2)
            set(MODE 2)
         else()
            message(FATAL_ERROR "Didn't expect SYSLIBS!")
            return()
         endif()
      elseif(${MODE} EQUAL 1)
         list(APPEND LIBS ${arg})
      elseif(${MODE} EQUAL 2)
         list(APPEND SYSLIBS ${arg})
      else()
         message(WARNING "na_target_link_libraries(${targetname}) skipped parameter ${arg}")
      endif()
   endforeach()

   # On shared libs disable transitive linking of dependent libs
   get_property(TARGET_TYPE TARGET ${targetname} PROPERTY TYPE)
   set(LINK_POLICY "")
   if (TARGET_TYPE)
      #message(STATUS "Target type for ${targetname} is ${TARGET_TYPE}")
      if (${TARGET_TYPE} STREQUAL "SHARED_LIBRARY" )
         set(LINK_POLICY "PRIVATE")
         #message(STATUS "LINK_POLICY on ${targetname} is ${LINK_POLICY}")
      endif()
   #else()
   #   message(STATUS "No target type for ${targetname}")
   endif()

   # append depending libraries to LIBS
   #message( STATUS "getting indirect dependencies for ${targetname}")

   set( libIndex 0)
   list( LENGTH LIBS libsLength)
   while( libIndex LESS libsLength)
      list( GET LIBS ${libIndex} linkLib)
      #message( STATUS " CHECKING ${linkLib}")
      if( TARGET ${linkLib})
         get_property(targetType TARGET ${linkLib} PROPERTY TYPE)
         if( targetType STREQUAL "STATIC_LIBRARY")
            #message( STATUS "  STATIC LIBRARY, RECURSE")
            get_property(targetLinkLibraries TARGET ${linkLib} PROPERTY LINK_LIBRARIES)
            if(targetLinkLibraries)
               #message( STATUS "  FOUND DEPENDENCIES FOR ${linkLib}: ${targetLinkLibraries}")
               foreach( indirectLib ${targetLinkLibraries})
                  # check if library is already contained in list
                  list( FIND LIBS ${indirectLib} index)
                  if( ${index} LESS 0)
                     #message( STATUS "  APPEND LIBRARY ${indirectLib} TO LINKER LIST FOR ${targetname}")
                     list( APPEND LIBS ${indirectLib})
                     math(EXPR libsLength "${libsLength}+1")
                  else()
                     #message( STATUS "  LIBRARY ${indirectLib} ALREADY REFERENCED")
                  endif()
               endforeach()
            else()
               #message( STATUS "  NO DEPENDENCIES FOUND FOR ${linkLib}")
            endif()
         else()
            #message( STATUS "  NO STATIC LIBRARY, DO NOT RECURSE")
         endif()
      else()
         #message( STATUS "  NO TARGET: ${linkLib}")
      endif()
      math(EXPR libIndex "${libIndex}+1")
   endwhile()

   if(NOT DEFINED NA_ADDITIONAL_SYSLIBS)
      set(NA_ADDITIONAL_SYSLIBS "")
   endif()

   if(ANDROID)

      target_link_libraries(${targetname}
         ${LINK_POLICY}
         -Wl,--no-undefined
         -Wl,--start-group
         ${LIBS}
         -Wl,--end-group
         ${SYSLIBS}
         ${NA_ADDITIONAL_SYSLIBS}
         dl
         android
      )

   elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")

      target_link_libraries(${targetname}
         ${LINK_POLICY}
         -Wl,--no-undefined
         -Wl,--start-group
         ${LIBS}
         -Wl,--end-group
         ${SYSLIBS}
         ${NA_ADDITIONAL_SYSLIBS}
         pthread
         dl
         rt
      )

   elseif(CMAKE_SYSTEM_NAME STREQUAL "QNX")
      if (NOT DEFINED QNX_ADDITIONAL_LIBS)
         set(QNX_ADDITIONAL_LIBS "")
      endif()
      target_link_libraries(${targetname}
         ${LINK_POLICY}
         -Wl,--no-undefined
         -Wl,--start-group
         ${LIBS}
         -Wl,--end-group
         ${SYSLIBS}
         ${NA_ADDITIONAL_SYSLIBS}
         ${QNX_ADDITIONAL_LIBS}
      )
   else()

      target_link_libraries(${targetname}
         ${LINK_POLICY}
         ${LIBS}
         ${SYSLIBS}
         ${NA_ADDITIONAL_SYSLIBS}
      )

   endif()

endfunction()
