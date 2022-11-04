# A simple wrapper around standard function 'install'
# which additionally provides the arguments
#    ARCHIVE DESTINATION lib
#    LIBRARY DESTINATION lib
#    RUNTIME DESTINATION bin
# to make sure that
# - on Windows, DLLs get into the /bin folder, their stub libs into /lib
# - on unixoid systems, SOs get into the /lib folder, together with their stub libs.
# usage: na_install_dll(<LIST OF TARGETS>)
# It is strange that that behaviour is not cmake's built-in default.
# See also https://cmake.org/cmake/help/v3.0/command/install.html
function(na_install_dll)
   install(TARGETS             ${ARGV}
           ARCHIVE DESTINATION lib
           LIBRARY DESTINATION lib
           RUNTIME DESTINATION bin
          )
endfunction()

# Extends CMake's builtin "add_library" command by additional arguments:
#
#  - LD_VERSION_SCRIPT <versionscript>
#    Applies the ld version script on shared libraries. This option is
#    ignored for toolchains not supporting such linker files (like MSVC).
function(na_add_library name)
   unset(_new_args)
   unset(_ld_version_script)
   unset(_is_shared ${BUILD_SHARED_LIBS})
   unset(_cur_opt)

   #message( "[na_add_library] ARGN: ${ARGN}")

   foreach( _arg ${ARGN})
      #message( "[na_add_library] _arg: ${_arg}")
      if( _arg STREQUAL "LD_VERSION_SCRIPT")
         #message( "[na_add_library] _cur_opt <= ${_arg}")
         set( _cur_opt "${_arg}")
      else()
         #message( "[na_add_library] non-custom key")
         if ( _cur_opt)
            if ( _cur_opt STREQUAL "LD_VERSION_SCRIPT")
               get_filename_component( _ld_version_script "${_arg}" ABSOLUTE)
            else()
               message( FATAL_ERROR "unexpected argument: ${_cur_opt}")
            endif()
            unset( _cur_opt)
         else()
            if( _arg MATCHES "SHARED|MODULE")
               #message( "[na_add_library] shared lib")
               set( _is_shared TRUE)
            elseif( _arg STREQUAL "STATIC")
               #message( "[na_add_library] static lib")
               unset( _is_shared)
            endif()
            list(APPEND _new_args ${_arg})
         endif()
      endif()
   endforeach()

   #message( "[na_add_library] name: ${name}")
   #message( "[na_add_library] _is_shared: ${_is_shared}")
   #message( "[na_add_library] _ld_version_script: ${_ld_version_script}")
   #message( "[na_add_library] _new_args: ${_new_args}")

   add_library( ${name} ${_new_args})

   if ( _ld_version_script)
      if ( _is_shared)
         if( (CMAKE_CXX_COMPILER_ID STREQUAL "GNU") OR (CMAKE_CXX_COMPILER_ID STREQUAL "Clang") )
            set_target_properties( ${name} PROPERTIES LINK_FLAGS   -Wl,--version-script=${_ld_version_script}
                                                      LINK_DEPENDS ${_ld_version_script})
         endif()
     else()
         message( WARNING "ignore supplied LD_VERSION_SCRIPT for non-shared library")
      endif()
   endif()
endfunction()

# Extends CMake's builtin "add_executable" command by additional arguments:
#
#  - LD_VERSION_SCRIPT <versionscript>
#    Applies the ld version script on shared libraries. This option is
#    ignored for toolchains not supporting such linker files (like MSVC).
function(na_add_executable name)
   unset(_new_args)
   unset(_ld_version_script)
   unset(_cur_opt)

   #message( "[na_add_executable] ARGN: ${ARGN}")

   foreach( _arg ${ARGN})
      #message( "[na_add_executable] _arg: ${_arg}")
      if( _arg STREQUAL "LD_VERSION_SCRIPT")
         #message( "[na_add_executable] _cur_opt <= ${_arg}")
         set( _cur_opt "${_arg}")
      else()
         #message( "[na_add_executable] non-custom key")
         if ( _cur_opt)
            if ( _cur_opt STREQUAL "LD_VERSION_SCRIPT")
               get_filename_component( _ld_version_script "${_arg}" ABSOLUTE)
            else()
               message( FATAL_ERROR "unexpected argument: ${_cur_opt}")
            endif()
            unset( _cur_opt)
         else()
            list(APPEND _new_args ${_arg})
         endif()
      endif()
   endforeach()

   #message( "[na_add_executable] name: ${name}")
   #message( "[na_add_executable] _ld_version_script: ${_ld_version_script}")
   #message( "[na_add_executable] _new_args: ${_new_args}")

   add_executable( ${name} ${_new_args})

   if ( _ld_version_script)
      if(     ((CMAKE_CXX_COMPILER_ID STREQUAL "GNU") OR (CMAKE_CXX_COMPILER_ID STREQUAL "Clang"))
          AND NOT (CMAKE_SYSTEM_NAME STREQUAL "QNX"))
         # TODO: for unknown reasons this is disabled on QNX for now -> ask F.Radtke why
         set_target_properties( ${name} PROPERTIES LINK_FLAGS   -Wl,--version-script=${_ld_version_script}
                                                   LINK_DEPENDS ${_ld_version_script})
      endif()
   endif()
endfunction()

# na_include_directories() is a replacement for include_directories() command.
# na_include_directories() will skip the default system include path
# and avoid duplicate entries
if(NOT NA_STDIO_INCLUDE_PATH_)
  find_path(NA_STDIO_INCLUDE_PATH_ stdio.h)
endif()
function(na_include_directories)
   set(_argn "${ARGN}")
   unset(_new_inc_list)
   set(_inc_opt_AFTER FALSE)
   set(_inc_opt_BEFORE FALSE)
   set(_inc_opt_SYSTEM FALSE)
   get_property(_inc_before DIRECTORY PROPERTY INCLUDE_DIRECTORIES)
   foreach(_inc ${_argn})
      if (   _inc STREQUAL "AFTER"
          OR _inc STREQUAL "BEFORE"
          OR _inc STREQUAL "SYSTEM")
         # command option
         set(_inc_opt_${_inc} TRUE)
      else()
         list(FIND _inc_before ${_inc} _inc_present)
         if (_inc_present GREATER -1)
            message(STATUS "Skipping duplicate include path ${_inc}")
         elseif(NA_STDIO_INCLUDE_PATH_ AND _inc STREQUAL NA_STDIO_INCLUDE_PATH_)
            message(STATUS "Skipping system include path ${_inc}")
         else()
            list(APPEND _new_inc_list ${_inc})
         endif()
      endif()
   endforeach()
   if (_new_inc_list)
      #message(STATUS "before: ${_inc_before}")
      unset(_inc_SYSTEM)
      if (_inc_opt_SYSTEM)
         set(_inc_SYSTEM SYSTEM)
      endif()
      unset(_inc_ORDER)
      if (_inc_opt_BEFORE)
         set(_inc_ORDER BEFORE)
      elseif (_inc_opt_AFTER)
         set(_inc_ORDER AFTER)
      endif()
      include_directories(${_inc_ORDER} ${_inc_SYSTEM} ${_new_inc_list})
      #get_property(_inc_after DIRECTORY PROPERTY INCLUDE_DIRECTORIES)
      #message(STATUS "after: ${_inc_after}")
   endif()
endfunction(na_include_directories)
