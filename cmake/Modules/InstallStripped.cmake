#  Project: i-Navi
#  
#
# (c) Copyright 2013-2016
#
# All rights reserved.

# install_stripped(FILES ...) or install_stripped(PROGRAMS ...) will run strip on the installed files
# if make install/strip is run.
#
# The default implementation of cmake will strip only the binaries which are created by make when running
# "make install/strip", i.e. binaries which are added to the installation via install(<FILES|PROGRAMS> ...)
# are not stripped. Using install_stripped(<FILES|PROGRAMS> ...) instead will apply the strip command to
# the files after installation.
#
# Syntax: see install(<FILES|PROGRAMS> ...) in the cmake documentation (https://cmake.org/cmake/help/)

cmake_minimum_required(VERSION 2.8.10)

function (install_stripped)

   # call install(...) with all arguments
   install(${ARGN})

   # extract the parameters FILES, PROGRAMS and DESTINATION from the parameter list
   set(options)
   set(oneValueArgs DESTINATION)
   set(multiValueArgs FILES PROGRAMS)
   cmake_parse_arguments(INSTALLSTRIPPED "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

   if (INSTALLSTRIPPED_FILES)
      set(FILES ${INSTALLSTRIPPED_FILES})
   elseif(INSTALLSTRIPPED_PROGRAMS)
      set(FILES ${INSTALLSTRIPPED_PROGRAMS})
   else()
      message(FATAL_ERROR "install_stripped: will only handle FILES or PROGRAMS")
      return()
   endif()

   # add the call to strip to the install step
   foreach(FILE IN LISTS FILES)
      get_filename_component(filename ${FILE} NAME)
      install(CODE "if (CMAKE_INSTALL_DO_STRIP)
                       file(GLOB filelist \${CMAKE_INSTALL_PREFIX}/${INSTALLSTRIPPED_DESTINATION}/${filename})
                       execute_process(COMMAND ${CMAKE_STRIP} \${filelist})
                    endif()")
   endforeach(FILE)
endfunction(install_stripped)
