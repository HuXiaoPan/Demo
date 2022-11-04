# Simplify linking of executables
#
# na_module_link_libraries is a wrapper around target_link_libraries
# The required standard libraries will automatic be added.
# Additional system libraries (e.g. OpenGL support) can be
# added following the SYSLIBS keyword
#
# This is very similar to na_target_link_libraries but some
# extensions to support plugins defined by add_libray(myplugin MODULE ...)
#
# Usage:
#  na_module_link_libraries(<target> LIBS lib1 lib2...[SYSLIBS lib...])
#
# Usage example:
# include(NaModuleLibs)
# add_library(testplugin MODULE testlib1.cpp)
# na_module_link_libraries(testplugin LIBS ...)
#

cmake_minimum_required(VERSION 2.8)

function(na_module_link_libraries targetname)
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
      message(WARNING "na_module_link_libraries(${targetname})skipped parameter ${arg}")
    endif()
  endforeach()

  set(WL_no_undefined "-Wl,--no-undefined")
  if (WITH_SANITIZER)
    # sanitizer libs shouldn't be linked in
    # so some symbols remain undefined
    set(WL_no_undefined "")
  endif()

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

   if(NOT DEFINED NA_ADDITIONAL_SYSLIBS)
      set(NA_ADDITIONAL_SYSLIBS "")
   endif()
   
   if(ANDROID)
      target_link_libraries(${targetname}
        ${LINK_POLICY}
        ${WL_no_undefined}
        -Wl,-Bsymbolic,-Bsymbolic-functions
        -Wl,--start-group
        ${LIBS}
        -Wl,--end-group
        ${SYSLIBS}
        ${NA_ADDITIONAL_SYSLIBS}
        dl
      )
   elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
      target_link_libraries(${targetname}
        ${LINK_POLICY}
        ${WL_no_undefined}
        -Wl,-rpath=.
        -Wl,-Bsymbolic,-Bsymbolic-functions
        -Wl,--start-group
        ${LIBS}
        -Wl,--end-group
        ${SYSLIBS}
        ${NA_ADDITIONAL_SYSLIBS}
        pthread
        dl
        rt
      )
   else() # if(WIN32)
      target_link_libraries(${targetname}
        ${LINK_POLICY}
        ${LIBS}
        ${SYSLIBS}
        ${NA_ADDITIONAL_SYSLIBS}
      )
   endif()

endfunction()
