#  Project: i-Navi
#  
#
# (c) Copyright 2014-2016
#
# All rights reserved.

###############################################################################
# Options and global variables                                                #
###############################################################################

set( ApiFiddler_MINVERSION "1.17.0")

option( APIFIDDLER_FORCE_REBUILD "Force recreating API fiddler targets." OFF)
option( APIFIDDLER_DEBUG_OUTPUT  "Show debug output for ApiFiddler."     OFF)

set( APIFIDDLER_HOME         "${PROJECT_SOURCE_DIR}/tools/ApiFiddler/bin" CACHE FILEPATH "Path ApiFiddler root directory (where apifiddler.jar is located)" )
set( APIFIDDLER_DEFAULT_ROOT "${PROJECT_SOURCE_DIR}")

###############################################################################
# External packages                                                           #
###############################################################################

# make sure that JAVA is searched in the host system, not the target sysroot
set( OLD_CMAKE_FIND_ROOT_PATH_MODE_PROGRAM "${CMAKE_FIND_ROOT_PATH_MODE_PROGRAM}")
  set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER )
  find_package(Java COMPONENTS Runtime REQUIRED)
  include(UseJava)
set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM "${OLD_CMAKE_FIND_ROOT_PATH_MODE_PROGRAM}")

if( Java_VERSION VERSION_LESS "1.8")
   message(FATAL_ERROR "ApiFiddler needs at least Java 1.8 to run")
endif()

###############################################################################
# Initialization                                                              #
###############################################################################

# make sure that ApiFiddler is searched in the host system, not the target sysroot
set( OLD_CMAKE_FIND_ROOT_PATH_MODE_INCLUDE "${CMAKE_FIND_ROOT_PATH_MODE_INCLUDE}")
  set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE NEVER )
  find_jar(ApiFiddler_JAR apifiddler PATHS ${APIFIDDLER_HOME})
  if(NOT ApiFiddler_JAR)
      message(FATAL_ERROR "Jar-File apifiddler.jar not found. Use APIFIDDLER_HOME to set location manually.")
  endif()
set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE "${OLD_CMAKE_FIND_ROOT_PATH_MODE_INCLUDE}")

set( ApiFiddler_COMMAND "${Java_JAVA_EXECUTABLE}" "-Dfile.encoding=UTF-8" "-jar" "${ApiFiddler_JAR}" "-q" CACHE INTERNAL "ApiFiddler command" FORCE)

if(NOT ApiFiddler_VERSION)
   # get version
   execute_process( COMMAND ${ApiFiddler_COMMAND} --version
                    RESULT_VARIABLE tmp_result OUTPUT_VARIABLE tmp_output ERROR_VARIABLE tmp_err)
   if( NOT(tmp_result EQUAL "0"))
      message(FATAL_ERROR "Failed to launch ApiFiddler (${ApiFiddler_JAR}), please check configuration!")
   endif()
   string(REGEX MATCH "[0-9]+\\.[0-9]+\\.[0-9]+(-[a-zA-Z0-9.]+)?" ApiFiddler_FULLVERSION ${tmp_output})
   string(REGEX MATCH "[0-9]+\\.[0-9]+\\.[0-9]+" ApiFiddler_VERSION ${ApiFiddler_FULLVERSION})

   if(NOT ApiFiddler_VERSION)
      message(FATAL_ERROR "Failed to get ApiFiddler version!")
   else()
      message(STATUS "Found ApiFiddler ${ApiFiddler_FULLVERSION}")
   endif()
endif()

if( ApiFiddler_VERSION VERSION_LESS ApiFiddler_MINVERSION)
   message(FATAL_ERROR "ApiFiddler ${ApiFiddler_VERSION} is not supported, please upgrade ApiFiddler to ${ApiFiddler_MINVERSION}")
endif()

###############################################################################
# Private functions and macros                                                #
###############################################################################

macro( _apifiddler_group_targets target)
   string(REPLACE "_" ";" TARGET_GROUP_STRUCTURE_LIST ${target})
   list(LENGTH TARGET_GROUP_STRUCTURE_LIST TARGET_GROUP_STRUCTURE_LIST_LEN)
   if (TARGET_GROUP_STRUCTURE_LIST_LEN GREATER 1)
     MATH(EXPR TARGET_GROUP_STRUCTURE_LIST_LEN "${TARGET_GROUP_STRUCTURE_LIST_LEN}-1")
     list(REMOVE_AT TARGET_GROUP_STRUCTURE_LIST ${TARGET_GROUP_STRUCTURE_LIST_LEN})
     while (TARGET_GROUP_STRUCTURE_LIST_LEN GREATER 2)
       MATH(EXPR TARGET_GROUP_STRUCTURE_LIST_LEN "${TARGET_GROUP_STRUCTURE_LIST_LEN}-1")
       list(REMOVE_AT TARGET_GROUP_STRUCTURE_LIST ${TARGET_GROUP_STRUCTURE_LIST_LEN})
     endwhile()
     if (TARGET_GROUP_STRUCTURE_LIST_LEN GREATER 0)
       string(REPLACE ";" "/" TARGET_GROUP_STRUCTURE_STRG "${TARGET_GROUP_STRUCTURE_LIST}")
       #message(STATUS "Group ${target} into FOLDER ${TARGET_GROUP_STRUCTURE_STRG}")
       set_target_properties(${target}
                             PROPERTIES FOLDER ${TARGET_GROUP_STRUCTURE_STRG})
     endif()
   endif()
endmacro()

function( _apifiddler_remove_rootdir dest rootDir path)
   string(LENGTH ${rootDir} rootLength)
   string(SUBSTRING ${path} 0 ${rootLength} pathPrefix)
   string(COMPARE EQUAL ${rootDir} ${pathPrefix} compareResult)

   if(compareResult)
      string(SUBSTRING ${path} ${rootLength} -1 tmp_dest)
      string(REGEX REPLACE "^\\/+" "" tmp_dest ${tmp_dest})
   else()
      set( tmp_dest ${path})
   endif()
   set( ${dest} ${tmp_dest} PARENT_SCOPE)
endfunction()

# Returns the source file of a FIDL target and of all of its "USES" dependencies.
function( _apifiddler_get_referenced_fidls)
   cmake_parse_arguments(PARAM "" "FIDL;VAR" "" ${ARGN})
   get_target_property(FIDL_FILE          ${PARAM_FIDL} "FIDL_FILE"      )
   get_target_property(ROOT               ${PARAM_FIDL} "ROOT"           )
   get_target_property(USES               ${PARAM_FIDL} "USES"           )

   if (APIFIDDLER_DEBUG_OUTPUT)
      message( STATUS "PARAM_FIDL: ${PARAM_FIDL}")
      message( STATUS "PARAM_VAR : ${PARAM_VAR}")
      message( STATUS "FIDL_FILE : ${FIDL_FILE}")
      message( STATUS "ROOT      : ${ROOT}")
      message( STATUS "USES      : ${USES}")
   endif()

   set( ABSOLUTE_FIDL_FILE "${ROOT}/${FIDL_FILE}")

   if ( NOT ";${${PARAM_VAR}};" MATCHES ";${ABSOLUTE_FIDL_FILE};")
      set( TMP_LIST ${${PARAM_VAR}};${ABSOLUTE_FIDL_FILE})
      foreach(USED ${USES})
         _apifiddler_get_referenced_fidls( FIDL ${USED} VAR TMP_LIST)
      endforeach()
      set(${PARAM_VAR} ${${PARAM_VAR}} ${TMP_LIST} PARENT_SCOPE)
   endif()
endfunction()

# Prepares arguments for a nacl adaptor generator.
# It uses the following variables:
#  - PARAM_DEPENDS
#  - PARAM_NAMESPACE
#  - PARAM_IFACE_TARGETS
#  - PARAM_FIDL
#  - PARAM_IFACENAMESPACE
#  - PARAM_IFACEINCLUDEPATH
#  - PARAM_SRCPATH
#  - PARAM_INCLUDEPATH
# It provides new variables:
#  - INPUT_LIST
#  - DEPENDENCIES
#  - SRCPATH_REL
#  - INCLUDEPATH_REL
macro(_apifiddler_perpare_adaptor_arguments)
   set(INPUT_LIST)
   set(DEPENDENCIES ${PARAM_DEPENDS})

   if( NOT PARAM_NAMESPACE)
      message( FATAL_ERROR "parameter NAMESPACE not set!")
   endif()

   if( PARAM_IFACE_TARGETS)
      if( PARAM_FIDL)
         message( FATAL_ERROR "please provide either IFACE_TARGETS or FIDL; it is not possible to supply both at the same time")
      endif()

      # setup input list
      foreach(IFACE_TARGET ${PARAM_IFACE_TARGETS})
         get_target_property( INPUT_FIDLS ${IFACE_TARGET} "INPUT_FIDLS")
         get_target_property( OUTPUT_HDRS ${IFACE_TARGET} "OUTPUT_HDRS")
         get_target_property( NAMESPACE   ${IFACE_TARGET} "NAMESPACE")
         if( NOT INPUT_FIDLS)
            message( FATAL "target '${IFACE_TARGET}' is not a nacl interface target")
         endif()
         set(ix 0)
         foreach(FIDL ${INPUT_FIDLS})
            get_target_property(FIDL_FILE          ${FIDL} "FIDL_FILE")
            if(NOT FIDL_FILE)
               message( FATAL_ERROR "target ${FIDL} does not represent a FIDL file")
            endif()

            list(GET OUTPUT_HDRS ${ix} NACL_HDR)
            math(EXPR ix "${ix}+1")

            _apifiddler_remove_rootdir( NACL_HDR_REL "${CMAKE_BINARY_DIR}" "${NACL_HDR}")

            string(REGEX REPLACE "\\.fidl$" "" FIDL_BASENAME "${FIDL_FILE}")
            list(APPEND INPUT_LIST "${FIDL}\;${NACL_HDR_REL}\;${NAMESPACE}")
         endforeach()

         list(APPEND DEPENDENCIES ${IFACE_TARGET})
      endforeach()
   else()
      if( NOT PARAM_FIDL)
         message( FATAL_ERROR "please provide either IFACE_TARGETS or FIDL")
      endif()
      if( NOT PARAM_IFACENAMESPACE)
         message( FATAL_ERROR "parameter IFACENAMESPACE not set!")
      endif()
      if( NOT PARAM_IFACEINCLUDEPATH)
         message( FATAL_ERROR "parameter IFACEINCLUDEPATH not set!")
      endif()

      # setup input list
      foreach(FIDL ${PARAM_FIDL})
         get_target_property(FIDL_FILE          ${FIDL} "FIDL_FILE")
         if(NOT FIDL_FILE)
            message( FATAL_ERROR "target ${FIDL} does not represent a FIDL file")
         endif()

         string(REGEX REPLACE "\\.fidl$" "" FIDL_BASENAME "${FIDL_FILE}")
         list(APPEND INPUT_LIST "${FIDL}\;${PARAM_IFACEINCLUDEPATH}/${FIDL_BASENAME}.hpp\;${PARAM_IFACENAMESPACE}")
      endforeach()
   endif()

   # get relative SRC and INCLUDE paths
   get_filename_component(SRCPATH ${PARAM_SRCPATH} REALPATH)
   _apifiddler_remove_rootdir( SRCPATH_REL "${CMAKE_BINARY_DIR}" "${SRCPATH}")
   get_filename_component(INCLUDEPATH ${PARAM_INCLUDEPATH} REALPATH)
   _apifiddler_remove_rootdir( INCLUDEPATH_REL "${CMAKE_BINARY_DIR}" "${INCLUDEPATH}")
endmacro()

###############################################################################
# Functions for generation during normal build                                #
###############################################################################

#! fidl_declare_target : Declares a FIDL file and its properties for further reference by generator functions.
#
# In order to generate anything from a FIDL file using any of the fidl_gen_* functions, the FIDL file
# has to be declared firstly, along with some of its properties. The properties must be correct for
# some generators to work properly. For each FIDL file a separate CMake target is created and the
# properties are attached to it.
#
# \arg:target              the CMake target to associate with this FIDL file
# \param:FILE              input FIDL file
# \param:PACKAGE           the logical package this FIDL file is located in (this may differ from its actual location)
# \param:ROOT              the project root from FIDL perspective (paths within FIDL files are relative to this
#                          folder) [Optional, default=${CMAKE_CURRENT_SOURCE_DIR}]
# \group:USES              list of targets representing FIDL files that this one refers to
# \group:TYPECOLLECTIONS   list of named type collections declared in the FIDL file
# \group:INTERFACES        list of interfaces declared in the FIDL file
# \group:TYPES             list of types within the anonymous type collection declared in the FIDL file
function(fidl_declare target)
   cmake_parse_arguments(PARAM "" "FILE;PACKAGE;ROOT" "USES;TYPECOLLECTIONS;INTERFACES;TYPES" ${ARGN})

   if( "${PARAM_FILE}" STREQUAL "")
      message(FATAL_ERROR "no FIDL file supplied")
   else()
      if( "${PARAM_ROOT}" STREQUAL "")
         # TODO: correct me!
         set( PARAM_ROOT "${CMAKE_CURRENT_SOURCE_DIR}")
      endif()

      set(PARAM_FULLPATH "${PARAM_ROOT}/${PARAM_FILE}")
      if(NOT EXISTS "${PARAM_FULLPATH}")
         message(FATAL "file ${PARAM_FULLPATH} not found")
      else()
         add_custom_target( ${target} DEPENDS ${PARAM_FULLPATH})
         set_target_properties( ${target} PROPERTIES TYPECOLLECTIONS "${PARAM_TYPECOLLECTIONS}"
                                                     INTERFACES      "${PARAM_INTERFACES}"
                                                     TYPES           "${PARAM_TYPES}"
                                                     PACKAGE         "${PARAM_PACKAGE}"
                                                     ROOT            "${PARAM_ROOT}"
                                                     FIDL_FILE       "${PARAM_FILE}"
                                                     USES            "${PARAM_USES}")
         _apifiddler_group_targets(${target})
      endif()
   endif()
endfunction()

#! fidl_gen_nacl_iface: generates a nacl C++ interface for a set of FIDL files
#
# \param:TARGET            target to be associated with this generator step
# \param:VAR               if set, the names of the generated files are stored in VAR
# \param:INCLUDEPATH       root path for the generated HPP files
# \param:NAMESPACE         period separated namespace for the generated adaptors (e.g. "na.iface.adaptor.libdbus")
# \group:FIDL              list of FIDL files to generate adaptors for
# \group:DEPENDS           additional dependencies for the create library (only meaningful if LIB has been set)
function( fidl_gen_nacl_iface)
   cmake_parse_arguments(PARAM "" "TARGET;VAR;INCLUDEPATH;NAMESPACE" "FIDL;DEPENDS" ${ARGN})

   # TODO: improve input validation
   if( NOT PARAM_NAMESPACE)
      message( FATAL_ERROR "parameter NAMESPACE not set!")
   endif()

   # get relative INCLUDE paths
   get_filename_component(INCLUDEPATH ${PARAM_INCLUDEPATH} REALPATH)
   _apifiddler_remove_rootdir( INCLUDEPATH_REL "${CMAKE_BINARY_DIR}" "${INCLUDEPATH}")
   if(APIFIDDLER_DEBUG_OUTPUT)
      message( STATUS "[fidl_gen_nacl_iface] INCLUDEPATH_REL : ${INCLUDEPATH_REL}")
   endif()

   set(outFiles "")   # list of all generated files

   foreach(SRC ${PARAM_FIDL})
      get_target_property(PACKAGE            ${SRC} "PACKAGE"        )
      get_target_property(ROOT               ${SRC} "ROOT"           )
      get_target_property(FIDL_FILE          ${SRC} "FIDL_FILE"      )

      if(NOT FIDL_FILE)
         message( FATAL_ERROR "target ${SRC} does not represent a FIDL file")
      endif()

      set( DEP_FIDLS "")   # list of all FIDL source files the current one depends on
      _apifiddler_get_referenced_fidls( FIDL ${SRC} VAR DEP_FIDLS)

      # get the FIDL file base name
      string(REGEX REPLACE "\\.fidl$" "" FIDL_BASENAME "${FIDL_FILE}")

      if(APIFIDDLER_DEBUG_OUTPUT)
         message( STATUS "[fidl_gen_nacl_iface] ${SRC}.PACKAGE          : ${PACKAGE}")
         message( STATUS "[fidl_gen_nacl_iface] ${SRC}.ROOT             : ${ROOT}")
         message( STATUS "[fidl_gen_nacl_iface] ${SRC}.FIDL_FILE        : ${FIDL_FILE}")
      endif()

      set( curSourceFile "${ROOT}/${FIDL_FILE}")
      set( curOutFiles   "${PARAM_INCLUDEPATH}/${FIDL_BASENAME}.hpp")

      set( outParam "-o" "nacl-iface(root='${CMAKE_BINARY_DIR}',namespace=${PARAM_NAMESPACE},hpp='${INCLUDEPATH_REL}/${FIDL_BASENAME}.hpp')")

      add_custom_command( OUTPUT ${curOutFiles}
                          COMMAND
                              ${ApiFiddler_COMMAND}
                              ${outParam}
                              "${ROOT}/${FIDL_FILE}"
                          VERBATIM
                          DEPENDS ${curSourceFile}
                                  ${DEP_FIDLS}
                                  "${ApiFiddler_JAR}"
                                  ${PARAM_DEPENDS}
                        )

      list( APPEND outFiles ${curOutFiles})
   endforeach()

   if(APIFIDDLER_DEBUG_OUTPUT)
      message( STATUS "[fidl_gen_nacl_iface] outFiles     : ${outFiles}")
   endif()

   if(PARAM_VAR)
      set(${PARAM_VAR} ${${PARAM_VAR}} ${outFiles} PARENT_SCOPE)
   endif()
   if(PARAM_TARGET)
      add_custom_target( ${PARAM_TARGET} DEPENDS ${outFiles})
      set_target_properties( ${PARAM_TARGET} PROPERTIES INPUT_FIDLS "${PARAM_FIDL}")
      set_target_properties( ${PARAM_TARGET} PROPERTIES OUTPUT_HDRS "${outFiles}")
      set_target_properties( ${PARAM_TARGET} PROPERTIES NAMESPACE   "${PARAM_NAMESPACE}")
      _apifiddler_group_targets(${PARAM_TARGET})
   endif()
endfunction()

#! fidl_gen_adaptor_fcallcpp: generates a "nacl-less" C++ interface for a set of FIDL files
#
# This function generates a fcallcpp adaptor covering all interfaces and types declared in the given
# FIDL files and - optionally - stores them in a C++ library.
#
# The function supports two different modes. You can either manually supply targets defined by the fidl_declare
# function. In this case, you need to supply the following parameters: FIDL, IFACEINCLUDEPATH, IFACENAMESPACE.
#
# Alternatively, it is possible to supply a list of targets defined by the fidl_gen_nacl_iface function. In this
# case, this list has to be supplied using the IFACE_TARGETS parameter. The parameters FIDL, IFACEINCLUDEPATH, and
# IFACENAMESPACE do not apply in this case.
#
# \flag:REUSE_PUBLIC       if true, the public header will be referenced from the location in PUBLICPATH, but it will
#                          not be regenerated
# \param:LIB               if set, a C++ library of this name is created containing the adaptor code
# \param:VAR               if set, the names of the generated files are stored in VAR
# \param:VAR_PUBLIC        if set, the names of all public header files are stored in VAR_PUBLIC
# \param:INCLUDEPATH       root path for the generated HPP files
# \param:SRCPATH           root path for the generated CPP files
# \param:PUBLICPATH        root path for the generated public HPP files
# \param:PUBLICNAMESPACE   period separated namespace for the generated public files (e.g. "na.bcore")
# \param:NAMESPACE         period separated namespace for the generated adaptors (e.g. "na.iface.adaptor.fcallcpp")
# \param:IFACEINCLUDEPATH  root path for the nacl interface HPP files; use in conjunction with
#                          the FIDL parameter
# \param:IFACENAMESPACE    period separated namespace of the nacl interfaces (e.g. "na.iface.mgr"); use in conjunction with
#                          the FIDL parameter
# \group:IFACE_TARGETS     list of nacl iface targets defined via fidl_gen_nacl_iface to generate adaptors for
# \group:FIDL              list of FIDL targets  defined via fidl_declare to generate adaptors for
# \group:DEPENDS           additional dependencies for the create library (only meaningful if LIB has been set)

function( fidl_gen_adaptor_fcallcpp)
   cmake_parse_arguments(PARAM "REUSE_PUBLIC" "LIB;VAR;VAR_PUBLIC;PUBLICPATH;PUBLICNAMESPACE;INCLUDEPATH;SRCPATH;IFACEINCLUDEPATH;NAMESPACE;IFACENAMESPACE" "FIDL;IFACE_TARGETS;DEPENDS" ${ARGN})

   ## check/prepare input parameters
   _apifiddler_perpare_adaptor_arguments()

   # get relative PUBLIC paths
   get_filename_component(PUBLICPATH ${PARAM_PUBLICPATH} REALPATH)
   _apifiddler_remove_rootdir( PUBLICPATH_REL "${CMAKE_BINARY_DIR}" "${PUBLICPATH}")

   if(APIFIDDLER_DEBUG_OUTPUT)
      message( STATUS "[fidl_gen_adaptor_fcallcpp] SRCPATH_REL     : ${SRCPATH_REL}")
      message( STATUS "[fidl_gen_adaptor_fcallcpp] PUBLICPATH_REL  : ${PUBLICPATH_REL}")
      message( STATUS "[fidl_gen_adaptor_fcallcpp] INCLUDEPATH_REL : ${INCLUDEPATH_REL}")
   endif()

   set(outFiles "")
   set(publicOutFiles "")

   foreach(ENTRY ${INPUT_LIST})
      list(GET ENTRY 0 FIDL           )
      list(GET ENTRY 1 IFACE_HEADER   )
      list(GET ENTRY 2 IFACE_NAMESPACE)

      get_target_property(PACKAGE            ${FIDL} "PACKAGE"        )
      get_target_property(ROOT               ${FIDL} "ROOT"           )
      get_target_property(FIDL_FILE          ${FIDL} "FIDL_FILE"      )

      # get the FIDL file base name
      string(REGEX REPLACE "\\.fidl$" "" FIDL_BASENAME "${FIDL_FILE}")

      if(APIFIDDLER_DEBUG_OUTPUT)
         message( STATUS "[fidl_gen_adaptor_fcallcpp] ${FIDL}.PACKAGE         : ${PACKAGE}")
         message( STATUS "[fidl_gen_adaptor_fcallcpp] ${FIDL}.ROOT            : ${ROOT}")
         message( STATUS "[fidl_gen_adaptor_fcallcpp] ${FIDL}.FIDL_FILE       : ${FIDL_FILE}")
      endif()

      set( curSourceFile      "${ROOT}/${FIDL_FILE}")
      set( curPublicOutFiles  "${PARAM_PUBLICPATH}/${FIDL_BASENAME}.hpp")
      set( curOutFiles        "${PARAM_INCLUDEPATH}/${FIDL_BASENAME}.hpp"
                              "${PARAM_SRCPATH}/${FIDL_BASENAME}.cpp")
      if(NOT PARAM_REUSE_PUBLIC)
         list( APPEND curOutFiles ${curPublicOutFiles})
      endif()

      set(outParam "")
      if(NOT PARAM_REUSE_PUBLIC)
         list(APPEND outParam
                  "-o"
                  "fcallcpp-iface(root=${CMAKE_BINARY_DIR},namespace=${PARAM_PUBLICNAMESPACE},hpp=${PUBLICPATH_REL}/${FIDL_BASENAME}.hpp)")
      endif()

      list(APPEND outParam
               "-o"
               "nacl-fcallcpp-adaptor(root=${CMAKE_BINARY_DIR},namespace=${PARAM_NAMESPACE},type.namespace=${IFACE_NAMESPACE},type.hpp=${IFACE_HEADER},public.namespace=${PARAM_PUBLICNAMESPACE},public.hpp=${PUBLICPATH_REL}/${FIDL_BASENAME}.hpp,hpp=${INCLUDEPATH_REL}/${FIDL_BASENAME}.hpp,cpp=${SRCPATH_REL}/${FIDL_BASENAME}.cpp)")

      add_custom_command( OUTPUT ${curOutFiles}
                          COMMAND
                              ${ApiFiddler_COMMAND}
                              ${outParam}
                              "${ROOT}/${FIDL_FILE}"
                          VERBATIM
                          DEPENDS ${curSourceFile}
                                  "${ApiFiddler_JAR}"
                        )

      list( APPEND outFiles ${curOutFiles})
      list( APPEND publicOutFiles ${curPublicOutFiles})
   endforeach()

   if(APIFIDDLER_DEBUG_OUTPUT)
      message( STATUS "[fidl_gen_adaptor_fcallcpp] outFiles     : ${outFiles}")
   endif()

   if(PARAM_VAR)
      set(${PARAM_VAR} ${${PARAM_VAR}} ${outFiles} PARENT_SCOPE)
   endif()
   if(PARAM_VAR_PUBLIC)
      set(${PARAM_VAR_PUBLIC} ${${PARAM_VAR_PUBLIC}} ${publicOutFiles} PARENT_SCOPE)
   endif()
   if(PARAM_LIB)
      add_library(${PARAM_LIB} ${outFiles})
      add_dependencies(${PARAM_LIB} ${DEPENDENCIES})
      _apifiddler_group_targets(${PARAM_LIB})
   endif()
endfunction()


#! fidl_gen_adaptor_libdbus: generates a libdbus adaptor for a set of FIDL files
#
# This function generates a libdbus adaptor covering all interfaces and types declared in the given
# FIDL files and - optionally - stores them in a C++ library.
#
# The function supports two different modes. You can either manually supply targets defined by the fidl_declare
# function. In this case, you need to supply the following parameters: FIDL, IFACEINCLUDEPATH, IFACENAMESPACE.
#
# Alternatively, it is possible to supply a list of targets defined by the fidl_gen_nacl_iface function. In this
# case, this list has to be supplied using the IFACE_TARGETS parameter. The parameters FIDL, IFACEINCLUDEPATH, and
# IFACENAMESPACE do not apply in this case.
#
# \flag:ENUMS_AS_UINT16          if true, enums are mapped to unsigned 16-bit integers (otherwise to unsigned 32-bit integers)
# \flag:GENERATE_INTROSPECTION   if true, an introspection file is generated
# \flag:COMMONAPI                if true, CommonAPI compatible code is generated; this overrides the ENUMS_AS_UINT16 flag
# \param:LIB                     if set, a C++ library of this name is created containing the adaptor code
# \param:VAR                     if set, the names of the generated files are stored in VAR
# \param:VAR_INTROSPECTION       if set, the names of the generated introspection files are stored in VAR_INTROSPECTION
# \param:INCLUDEPATH             root path for the generated HPP files
# \param:SRCPATH                 root path for the generated CPP files
# \param:NAMESPACE               period separated namespace for the generated adaptors (e.g. "na.iface.adaptor.libdbus")
# \param:IFACEINCLUDEPATH  root path for the nacl interface HPP files; use in conjunction with
#                          the FIDL parameter
# \param:IFACENAMESPACE    period separated namespace of the nacl interfaces (e.g. "na.iface.mgr"); use in conjunction with
#                          the FIDL parameter
# \group:IFACE_TARGETS     list of nacl iface targets defined via fidl_gen_nacl_iface to generate adaptors for
# \group:FIDL              list of FIDL targets  defined via fidl_declare to generate adaptors for
# \group:DEPENDS                 additional dependencies for the create library (only meaningful if LIB has been set)
function( fidl_gen_adaptor_libdbus)
   cmake_parse_arguments(PARAM "ENUMS_AS_UINT16;GENERATE_INTROSPECTION;COMMONAPI" "LIB;VAR;VAR_INTROSPECTION;INCLUDEPATH;SRCPATH;IFACEINCLUDEPATH;NAMESPACE;IFACENAMESPACE" "FIDL;IFACE_TARGETS;DEPENDS" ${ARGN})

   ## check/prepare input parameters
   _apifiddler_perpare_adaptor_arguments()

   # TODO: improve input validation

   # get relative SRC and INCLUDE paths
   if(APIFIDDLER_DEBUG_OUTPUT)
      message( STATUS "[fidl_gen_adaptor_libdbus] SRCPATH_REL     : ${SRCPATH_REL}")
      message( STATUS "[fidl_gen_adaptor_libdbus] INCLUDEPATH_REL : ${INCLUDEPATH_REL}")
   endif()

   set(outFiles "")
   set(outFilesIntrospection "")

   foreach(ENTRY ${INPUT_LIST})
      list(GET ENTRY 0 FIDL           )
      list(GET ENTRY 1 IFACE_HEADER   )
      list(GET ENTRY 2 IFACE_NAMESPACE)

      get_target_property(PACKAGE            ${FIDL} "PACKAGE"        )
      get_target_property(ROOT               ${FIDL} "ROOT"           )
      get_target_property(FIDL_FILE          ${FIDL} "FIDL_FILE"      )

      # this is only necessary because the generated D-Bus adaptor file contains information (signatures)
      # from externally defined types
      set( DEP_FIDLS "")   # list of all FIDL source files the current one depends on
      _apifiddler_get_referenced_fidls( FIDL ${FIDL} VAR DEP_FIDLS)

      # get the FIDL file base name
      string(REGEX REPLACE "\\.fidl$" "" FIDL_BASENAME "${FIDL_FILE}")

      if(APIFIDDLER_DEBUG_OUTPUT)
         message( STATUS "[fidl_gen_adaptor_libdbus] ${FIDL}.PACKAGE          : ${PACKAGE}")
         message( STATUS "[fidl_gen_adaptor_libdbus] ${FIDL}.ROOT             : ${ROOT}")
         message( STATUS "[fidl_gen_adaptor_libdbus] ${FIDL}.FIDL_FILE        : ${FIDL_FILE}")
      endif()

      set( curSourceFile  "${ROOT}/${FIDL_FILE}")
      set( curOutFileCpp  "${SRCPATH}/${FIDL_BASENAME}.cpp")
      set( curOutFileHpp  "${PARAM_INCLUDEPATH}/${FIDL_BASENAME}.hpp")
      set( curOutFileXml  "${CMAKE_BINARY_DIR}/${INCLUDEPATH_REL}/${FIDL_BASENAME}.xml")

      set( curOutFiles ${curOutFileHpp} ${curOutFileCpp})

      set( outParam "-o" "nacl-dbus-adaptor(root=${CMAKE_BINARY_DIR},namespace=${PARAM_NAMESPACE},type.namespace=${IFACE_NAMESPACE},type.hpp=${IFACE_HEADER},hpp=${INCLUDEPATH_REL}/${FIDL_BASENAME}.hpp,cpp=${SRCPATH_REL}/${FIDL_BASENAME}.cpp")
      if (PARAM_COMMONAPI)
         if(ApiFiddler_VERSION VERSION_LESS "1.18.0")
            message( FATAL_ERROR "For CommonAPI support you need at least ApiFiddler 1.18.0")
         else()
            set( outParam "${outParam},dbus.enumBaseType=Int32,dbus.commonApiVariants=true")
         endif()
      else()
         if(ApiFiddler_VERSION VERSION_LESS "1.18.0")
            if (PARAM_ENUMS_AS_UINT16)
               set( outParam "${outParam},enumAs16Bit=true")
            else()
               set( outParam "${outParam},enumAs16Bit=false")
            endif()
         else()
            set( outParam "${outParam},commonApiVariants=false")
            if (PARAM_ENUMS_AS_UINT16)
               set( outParam "${outParam},dbus.enumBaseType=UInt16")
            else()
               set( outParam "${outParam},dbus.enumBaseType=UInt32")
            endif()
         endif()
      endif()
      set( outParam "${outParam})")

      if(PARAM_GENERATE_INTROSPECTION)
         list( APPEND outParam "-o" "dbus(file=${curOutFileXml}")
         if (PARAM_COMMONAPI)
            set( outParam "${outParam},dbus.enumBaseType=Int32,dbus.commonApiVariants=true")
         else()
            if(ApiFiddler_VERSION VERSION_LESS "1.18.0")
               if (PARAM_ENUMS_AS_UINT16)
                  set( outParam "${outParam},enumAs16Bit=true")
               else()
                  set( outParam "${outParam},enumAs16Bit=false")
               endif()
            else()
               set( outParam "${outParam},commonApiVariants=false")
               if (PARAM_ENUMS_AS_UINT16)
                  set( outParam "${outParam},dbus.enumBaseType=UInt16")
               else()
                  set( outParam "${outParam},dbus.enumBaseType=UInt32")
               endif()
            endif()
         endif()
         set( outParam "${outParam})")
         list(APPEND curOutFiles ${curOutFileXml})
         list(APPEND outFilesIntrospection ${curOutFileXml})
      endif()

      add_custom_command( OUTPUT ${curOutFiles}
                          COMMAND
                              ${ApiFiddler_COMMAND}
                              ${outParam}
                              "${ROOT}/${FIDL_FILE}"
                          VERBATIM
                          DEPENDS ${curSourceFile}
                                  ${DEP_FIDLS}
                                  "${ApiFiddler_JAR}"
                        )

      list( APPEND outFiles ${curOutFileHpp} ${curOutFileCpp})
   endforeach()

   if(APIFIDDLER_DEBUG_OUTPUT)
      message( STATUS "[fidl_gen_adaptor_libdbus] outFiles             : ${outFiles}")
      message( STATUS "[fidl_gen_adaptor_libdbus] outFilesIntrospection: ${outFilesIntrospection}")
   endif()

   if(DEFINED PARAM_VAR)
      if(DEFINED ${PARAM_VAR})
         set(${PARAM_VAR} ${${PARAM_VAR}} ${outFiles} PARENT_SCOPE)
      else()
         set(${PARAM_VAR} ${outFiles} PARENT_SCOPE)
      endif()
   endif()
   if(DEFINED PARAM_LIB)
      add_library(${PARAM_LIB} ${outFiles})
      add_dependencies(${PARAM_LIB} ${DEPENDENCIES})
      _apifiddler_group_targets(${PARAM_LIB})
   endif()
   if(DEFINED PARAM_VAR_INTROSPECTION)
      if(DEFINED ${PARAM_VAR_INTROSPECTION})
         set(${PARAM_VAR_INTROSPECTION} ${${PARAM_VAR_INTROSPECTION}} ${outFilesIntrospection} PARENT_SCOPE)
      else()
         set(${PARAM_VAR_INTROSPECTION} ${outFilesIntrospection} PARENT_SCOPE)
      endif()
   endif()
endfunction()

#! fidl_gen_adaptor_jni: generates a JNI adaptor for a set of FIDL files
#
# This function generates a JNI adaptor covering all interfaces and types declared in the given
# FIDL files and - optionally - stores them in a C++ library.
#
# The function supports two different modes. You can either manually supply targets defined by the fidl_declare
# function. In this case, you need to supply the following parameters: FIDL, IFACEINCLUDEPATH, IFACENAMESPACE.
#
# Alternatively, it is possible to supply a list of targets defined by the fidl_gen_nacl_iface function. In this
# case, this list has to be supplied using the IFACE_TARGETS parameter. The parameters FIDL, IFACEINCLUDEPATH, and
# IFACENAMESPACE do not apply in this case.
#
# \flag:ANDROID            if set, Android specific files are generated (parcelable classes and proxies)
# \param:LIB               if set, a C++ library of this name is created containing the adaptor code
# \param:VAR               if set, the names of the generated files are stored in VAR
# \param:JAVA_VAR          the names of the generated JAVA files are appended to this variable
# \param:CLASSPATH         root path in which the JAVA files should be generated
# \param:INCLUDEPATH       root path for the generated HPP files
# \param:SRCPATH           root path for the generated CPP files
# \param:NAMESPACE         period separated namespace for the generated adaptors (e.g. "na.iface.adaptor.jni")
# \param:IFACEINCLUDEPATH  root path for the nacl interface HPP files; use in conjunction with
#                          the FIDL parameter
# \param:IFACENAMESPACE    period separated namespace of the nacl interfaces (e.g. "na.iface.mgr"); use in conjunction with
#                          the FIDL parameter
# \group:IFACE_TARGETS     list of nacl iface targets defined via fidl_gen_nacl_iface to generate adaptors for
# \group:FIDL              list of FIDL targets  defined via fidl_declare to generate adaptors for
# \group:DEPENDS           additional dependencies for the create library (only meaningful if LIB has been set)
function( fidl_gen_adaptor_jni)
   cmake_parse_arguments(PARAM "ANDROID" "LIB;VAR;JAVA_VAR;CLASSPATH;INCLUDEPATH;SRCPATH;IFACEINCLUDEPATH;NAMESPACE;IFACENAMESPACE" "FIDL;IFACE_TARGETS;DEPENDS" ${ARGN})

   ## check/prepare input parameters
   _apifiddler_perpare_adaptor_arguments()

   # TODO: improve input validation

   # get relative SRC and INCLUDE paths
   if(APIFIDDLER_DEBUG_OUTPUT)
      message( STATUS "[fidl_gen_adaptor_jni] SRCPATH_REL     : ${SRCPATH_REL}")
      message( STATUS "[fidl_gen_adaptor_jni] INCLUDEPATH_REL : ${INCLUDEPATH_REL}")
   endif()

   set(javaOutFiles "")
   set(outFiles "")

   foreach(ENTRY ${INPUT_LIST})
      list(GET ENTRY 0 FIDL           )
      list(GET ENTRY 1 IFACE_HEADER   )
      list(GET ENTRY 2 IFACE_NAMESPACE)

      get_target_property(PACKAGE            ${FIDL} "PACKAGE"        )
      get_target_property(ROOT               ${FIDL} "ROOT"           )
      get_target_property(FIDL_FILE          ${FIDL} "FIDL_FILE"      )
      get_target_property(TYPECOLLECTIONS    ${FIDL} "TYPECOLLECTIONS")
      get_target_property(INTERFACES         ${FIDL} "INTERFACES"     )
      get_target_property(TYPES              ${FIDL} "TYPES"          )

      # In CMake 3.x, targets cannot have empty properties. Querying such properties will result in
      # a NOTFOUND return value. As we attempt to access these values as a list, we don't get an empty
      # list as expected an as is the case with CMake 2.8, we get a list with one value: "NOTFOUND".
      if( NOT TYPECOLLECTIONS)
         set( TYPECOLLECTIONS "")
      endif()
      if( NOT INTERFACES)
         set( INTERFACES "")
      endif()
      if( NOT TYPES)
         set( TYPES "")
      endif()

      # get the path of the package
      string(REPLACE "." "/" PACKAGE_PATH "${PACKAGE}")

      # get the FIDL file base name
      string(REGEX REPLACE "\\.fidl$" "" FIDL_BASENAME "${FIDL_FILE}")

      if(APIFIDDLER_DEBUG_OUTPUT)
         message( STATUS "[fidl_gen_adaptor_jni] ${FIDL}.PACKAGE          : ${PACKAGE}")
         message( STATUS "[fidl_gen_adaptor_jni] ${FIDL}.ROOT             : ${ROOT}")
         message( STATUS "[fidl_gen_adaptor_jni] ${FIDL}.FIDL_FILE        : ${FIDL_FILE}")
         message( STATUS "[fidl_gen_adaptor_jni] ${FIDL}.TYPECOLLECTIONS  : ${TYPECOLLECTIONS}")
         message( STATUS "[fidl_gen_adaptor_jni] ${FIDL}.INTERFACES       : ${INTERFACES}")
         message( STATUS "[fidl_gen_adaptor_jni] ${FIDL}.TYPES            : ${TYPES}")
      endif()

      set( curSourceFile "${ROOT}/${FIDL_FILE}")
      set( curOutFiles   "${PARAM_INCLUDEPATH}/${FIDL_BASENAME}.hpp"
                         "${SRCPATH}/${FIDL_BASENAME}.cpp")
      unset( curJavaOutFiles)
      
      foreach( elem ${TYPECOLLECTIONS} ${INTERFACES} ${TYPES})
         list( APPEND curJavaOutFiles "${PARAM_CLASSPATH}/${PACKAGE_PATH}/${elem}.java")
      endforeach()

      if(PARAM_ANDROID)
         foreach( elem ${INTERFACES})
            list( APPEND curJavaOutFiles "${PARAM_CLASSPATH}/${PACKAGE_PATH}/${elem}Proxy.java")
         endforeach()
      endif()

      set(outParam
                "-o"
                "nacl-jni-adaptor(root=${CMAKE_BINARY_DIR},namespace=${PARAM_NAMESPACE},type.namespace=${IFACE_NAMESPACE},type.hpp=${IFACE_HEADER},hpp=${INCLUDEPATH_REL}/${FIDL_BASENAME}.hpp,cpp=${SRCPATH_REL}/${FIDL_BASENAME}.cpp)")

      if(PARAM_ANDROID)
         list(APPEND outParam
            "-o"
            "bcore-java(classpath=${PARAM_CLASSPATH},parcelable=true)"
            "-o"
            "android-proxy(classpath=${PARAM_CLASSPATH})")
      else()
         list(APPEND outParam
            "-o"
            "bcore-java(classpath=${PARAM_CLASSPATH},parcelable=false)")
      endif()

      add_custom_command( OUTPUT ${curOutFiles}
                                 ${curJavaOutFiles}
                          COMMAND ${ApiFiddler_COMMAND}
                                  ${outParam}
                                  "${ROOT}/${FIDL_FILE}"
                          VERBATIM
                          DEPENDS ${curSourceFile}
                                  "${ApiFiddler_JAR}"
                        )

      list( APPEND outFiles ${curOutFiles})
      list( APPEND javaOutFiles ${curJavaOutFiles})
   endforeach()

   if(APIFIDDLER_DEBUG_OUTPUT)
      message( STATUS "[fidl_gen_adaptor_jni] javaOutFiles : ${javaOutFiles}")
      message( STATUS "[fidl_gen_adaptor_jni] outFiles     : ${outFiles}")
   endif()

   if(PARAM_VAR)
      set(${PARAM_VAR} ${${PARAM_VAR}} ${outFiles} PARENT_SCOPE)
   endif()
   if(PARAM_LIB)
      add_library(${PARAM_LIB} ${outFiles})
      add_dependencies(${PARAM_LIB} ${DEPENDENCIES})
      _apifiddler_group_targets(${PARAM_LIB})
   endif()
   if(PARAM_JAVA_VAR)
      set(${PARAM_JAVA_VAR} ${${PARAM_JAVA_VAR}} ${javaOutFiles} PARENT_SCOPE)
   endif()
endfunction()

#! fidl_gen_adaptor_jsonws: generates a jsonws adaptor for a set of FIDL files
#
# This function generates a jsonws adaptor covering all interfaces and types declared in the given
# FIDL files and - optionally - stores them in a C++ library.
#
# The function supports two different modes. You can either manually supply targets defined by the fidl_declare
# function. In this case, you need to supply the following parameters: FIDL, IFACEINCLUDEPATH, IFACENAMESPACE.
#
# Alternatively, it is possible to supply a list of targets defined by the fidl_gen_nacl_iface function. In this
# case, this list has to be supplied using the IFACE_TARGETS parameter. The parameters FIDL, IFACEINCLUDEPATH, and
# IFACENAMESPACE do not apply in this case.
#
# \param:LIB               if set, a C++ library of this name is created containing the adaptor code
# \param:VAR               if set, the names of the generated files are stored in VAR
# \param:INCLUDEPATH       root path for the generated HPP files
# \param:SRCPATH           root path for the generated CPP files
# \param:NAMESPACE         period separated namespace for the generated adaptors (e.g. "na.iface.adaptor.jsonws")
# \param:IFACEINCLUDEPATH  root path for the nacl interface HPP files; use in conjunction with
#                          the FIDL parameter
# \param:IFACENAMESPACE    period separated namespace of the nacl interfaces (e.g. "na.iface.mgr"); use in conjunction with
#                          the FIDL parameter
# \group:IFACE_TARGETS     list of nacl iface targets defined via fidl_gen_nacl_iface to generate adaptors for
# \group:FIDL              list of FIDL targets  defined via fidl_declare to generate adaptors for
# \group:DEPENDS           additional dependencies for the create library (only meaningful if LIB has been set)
function( fidl_gen_adaptor_jsonws)
   cmake_parse_arguments(PARAM "" "LIB;VAR;INCLUDEPATH;SRCPATH;IFACEINCLUDEPATH;NAMESPACE;IFACENAMESPACE" "FIDL;IFACE_TARGETS;DEPENDS" ${ARGN})

   ## check/prepare input parameters
   _apifiddler_perpare_adaptor_arguments()

   # TODO: improve input validation

   # get relative SRC and INCLUDE paths
   if(APIFIDDLER_DEBUG_OUTPUT)
      message( STATUS "[fidl_gen_adaptor_jsonws] SRCPATH_REL     : ${SRCPATH_REL}")
      message( STATUS "[fidl_gen_adaptor_jsonws] INCLUDEPATH_REL : ${INCLUDEPATH_REL}")
   endif()

   set(outFiles "")

   foreach(ENTRY ${INPUT_LIST})
      list(GET ENTRY 0 FIDL           )
      list(GET ENTRY 1 IFACE_HEADER   )
      list(GET ENTRY 2 IFACE_NAMESPACE)

      get_target_property(PACKAGE            ${FIDL} "PACKAGE"        )
      get_target_property(ROOT               ${FIDL} "ROOT"           )
      get_target_property(FIDL_FILE          ${FIDL} "FIDL_FILE"      )

      # get the FIDL file base name
      string(REGEX REPLACE "\\.fidl$" "" FIDL_BASENAME "${FIDL_FILE}")

      if(APIFIDDLER_DEBUG_OUTPUT)
         message( STATUS "[fidl_gen_adaptor_jsonws] ${FIDL}.PACKAGE          : ${PACKAGE}")
         message( STATUS "[fidl_gen_adaptor_jsonws] ${FIDL}.ROOT             : ${ROOT}")
         message( STATUS "[fidl_gen_adaptor_jsonws] ${FIDL}.FIDL_FILE        : ${FIDL_FILE}")
      endif()

      set( curSourceFile "${ROOT}/${FIDL_FILE}")
      set( curOutFiles   "${PARAM_INCLUDEPATH}/${FIDL_BASENAME}.hpp"
                         "${SRCPATH}/${FIDL_BASENAME}.cpp")

      set( outParam "-o"
         "nacl-jsonws-adaptor(root=${CMAKE_BINARY_DIR},namespace=${PARAM_NAMESPACE},type.namespace=${IFACE_NAMESPACE},type.hpp=${IFACE_HEADER},hpp=${INCLUDEPATH_REL}/${FIDL_BASENAME}.hpp,cpp=${SRCPATH_REL}/${FIDL_BASENAME}.cpp)")

      add_custom_command( OUTPUT ${curOutFiles}
                          COMMAND
                              ${ApiFiddler_COMMAND}
                              ${outParam}
                              "${ROOT}/${FIDL_FILE}"
                          VERBATIM
                          DEPENDS ${curSourceFile}
                                  "${ApiFiddler_JAR}"
                        )

      list( APPEND outFiles ${curOutFiles})
   endforeach()

   if(APIFIDDLER_DEBUG_OUTPUT)
      message( STATUS "[fidl_gen_adaptor_jsonws] outFiles     : ${outFiles}")
   endif()

   if(PARAM_VAR)
      set(${PARAM_VAR} ${${PARAM_VAR}} ${outFiles} PARENT_SCOPE)
   endif()
   if(PARAM_LIB)
      add_library(${PARAM_LIB} ${outFiles})
      add_dependencies(${PARAM_LIB} ${DEPENDENCIES})
      _apifiddler_group_targets(${PARAM_LIB})
   endif()
endfunction()

#! fidl_gen_adaptor_vmost: generates a vmost adaptor for a set of FIDL files
#
# This function generates a vmost adaptor covering all interfaces and types declared in the given
# FIDL files and - optionally - stores them in a C++ library.
#
# The function supports two different modes. You can either manually supply targets defined by the fidl_declare
# function. In this case, you need to supply the following parameters: FIDL, IFACEINCLUDEPATH, IFACENAMESPACE.
#
# Alternatively, it is possible to supply a list of targets defined by the fidl_gen_nacl_iface function. In this
# case, this list has to be supplied using the IFACE_TARGETS parameter. The parameters FIDL, IFACEINCLUDEPATH, and
# IFACENAMESPACE do not apply in this case.
#
# \param:LIB               if set, a C++ library of this name is created containing the adaptor code
# \param:VAR               if set, the names of the generated files are stored in VAR
# \param:INCLUDEPATH       root path for the generated HPP files
# \param:SRCPATH           root path for the generated CPP files
# \param:NAMESPACE         period separated namespace for the generated adaptors (e.g. "na.iface.adaptor.vmost")
# \param:IFACEINCLUDEPATH  root path for the nacl interface HPP files; use in conjunction with
#                          the FIDL parameter
# \param:IFACENAMESPACE    period separated namespace of the nacl interfaces (e.g. "na.iface.mgr"); use in conjunction with
#                          the FIDL parameter
# \group:IFACE_TARGETS     list of nacl iface targets defined via fidl_gen_nacl_iface to generate adaptors for
# \group:FIDL              list of FIDL targets  defined via fidl_declare to generate adaptors for
# \group:DEPENDS           additional dependencies for the create library (only meaningful if LIB has been set)
function( fidl_gen_adaptor_vmost)
   cmake_parse_arguments(PARAM "" "LIB;VAR;INCLUDEPATH;SRCPATH;IFACEINCLUDEPATH;NAMESPACE;IFACENAMESPACE" "FIDL;IFACE_TARGETS;DEPENDS" ${ARGN})

   ## check/prepare input parameters
   _apifiddler_perpare_adaptor_arguments()

   if(APIFIDDLER_DEBUG_OUTPUT)
      message( STATUS "[fidl_gen_adaptor_vmost] SRCPATH_REL     : ${SRCPATH_REL}")
      message( STATUS "[fidl_gen_adaptor_vmost] INCLUDEPATH_REL : ${INCLUDEPATH_REL}")
   endif()

   set(outFiles "")

   foreach(ENTRY ${INPUT_LIST})
      list(GET ENTRY 0 FIDL           )
      list(GET ENTRY 1 IFACE_HEADER   )
      list(GET ENTRY 2 IFACE_NAMESPACE)

      get_target_property(PACKAGE            ${FIDL} "PACKAGE"        )
      get_target_property(ROOT               ${FIDL} "ROOT"           )
      get_target_property(FIDL_FILE          ${FIDL} "FIDL_FILE"      )

      # get the FIDL file base name
      string(REGEX REPLACE "\\.fidl$" "" FIDL_BASENAME "${FIDL_FILE}")

      if(APIFIDDLER_DEBUG_OUTPUT)
         message( STATUS "[fidl_gen_adaptor_vmost] ${FIDL}.PACKAGE          : ${PACKAGE}")
         message( STATUS "[fidl_gen_adaptor_vmost] ${FIDL}.ROOT             : ${ROOT}")
         message( STATUS "[fidl_gen_adaptor_vmost] ${FIDL}.FIDL_FILE        : ${FIDL_FILE}")
      endif()

      set( curSourceFile "${ROOT}/${FIDL_FILE}")
      set( curOutFiles   "${PARAM_INCLUDEPATH}/${FIDL_BASENAME}.hpp"
                         "${SRCPATH}/${FIDL_BASENAME}.cpp")

      add_custom_command( OUTPUT ${curOutFiles}
                          COMMAND
                              ${ApiFiddler_COMMAND}
                              "-o"
                              "nacl-vmost-adaptor(root=${CMAKE_BINARY_DIR},namespace=${PARAM_NAMESPACE},type.namespace=${IFACE_NAMESPACE},type.hpp=${IFACE_HEADER},hpp=${INCLUDEPATH_REL}/${FIDL_BASENAME}.hpp,cpp=${SRCPATH_REL}/${FIDL_BASENAME}.cpp)"
                              "${ROOT}/${FIDL_FILE}"
                          VERBATIM
                          DEPENDS ${curSourceFile}
                                  "${ApiFiddler_JAR}"
                        )

      list( APPEND outFiles ${curOutFiles})
   endforeach()

   if(APIFIDDLER_DEBUG_OUTPUT)
      message( STATUS "[fidl_gen_adaptor_vmost] outFiles     : ${outFiles}")
   endif()

   if(PARAM_VAR)
      set(${PARAM_VAR} ${${PARAM_VAR}} ${outFiles} PARENT_SCOPE)
   endif()
   if(PARAM_LIB)
      add_library(${PARAM_LIB} ${outFiles})
      add_dependencies(${PARAM_LIB} ${DEPENDENCIES})
      _apifiddler_group_targets(${PARAM_LIB})
   endif()
endfunction()

#! fidl_gen_adaptor_qtdbus: generates a qtdbus adaptor for a set of FIDL files
#
# This function generates a qtdbus adaptor covering all interfaces and types declared in the given
# FIDL files
#
# \param:OUTPATH                 root path for the generated files
# \param:TYPEDEFFOLDER           name of the folder for type definitions (default: typedefs)
# \param:REGISTRYFOLDER          name of the folder for the registy files (default: registry)
# \param:PROXYFOLDER             name of the folder for the proxy files (default: proxies)
# \param:SURFIX                  surfix for generated files
# \group:FIDL                    list of FIDL files to generate adaptors for
# \param:SOURCEFILES             if set, the names of the generated source files are stored in VAR
# \param:HEADERFILES             if set, the names of the generated header files are stored in VAR
# \param:REGISTRYHEADERFILES     if set, the names of the generated header files for the Qt metatype registation are stored in VAR
# \param:TARGET                  target to be associated with this generator step
function( fidl_gen_adaptor_qtdbus )
   cmake_parse_arguments( PARAM "" "OUTPATH;TYPEDEFFOLDER;REGISTRYFOLDER;PROXYFOLDER;SURFIX;SOURCEFILES;HEADERFILES;REGISTRYHEADERFILES;TARGET" "FIDL" ${ARGN})

   if( NOT PARAM_OUTPATH )
      message( FATAL_ERROR "parameter OUTPATH not set!" )
   endif()
   if( NOT PARAM_TYPEDEFFOLDER )
      set( PARAM_TYPEFFOLDER typedefs )
   endif()
   if( NOT PARAM_REGISTRYFOLDER )
      set( PARAM_REGISTRYFOLDER registry )
   endif()
   if( NOT PARAM_PROXYFOLDER )
      set( PARAM_PROXYFOLDER proxies )
   endif()
   if( NOT PARAM_SURFIX )
      message( FATAL_ERROR "parameter SURFIX not set!" )
   endif()

   get_filename_component( OUTPATH ${PARAM_OUTPATH} REALPATH )

   if( APIFIDDLER_DEBUG_OUTPUT )
      message( STATUS "[fidl_gen_adaptor_qtdbus] OUTPATH             : ${OUTPATH}" )
      message( STATUS "[fidl_gen_adaptor_qtdbus] TYPEDEFFOLDER       : ${PARAM_TYPEDEFFOLDER}" )
      message( STATUS "[fidl_gen_adaptor_qtdbus] REGISTRYFOLDER      : ${PARAM_REGISTRYFOLDER}" )
      message( STATUS "[fidl_gen_adaptor_qtdbus] PROXYFOLDER         : ${PARAM_PROXYFOLDER}" )
      message( STATUS "[fidl_gen_adaptor_qtdbus] SURFIX              : ${PARAM_SURFIX}" )
   endif()

   set( outSourceFiles "" )
   set( outHeaderFiles "" )
   set( outRegistryHeaderFiles "" )
   set( outFilesIntrospection "" )

   # some flags, because the ApiFiddler needs to know if he is working on the first or last fidl file in the list
   set( FIRSTFIDL true )

   foreach( SRC ${PARAM_FIDL} )

      get_target_property( PACKAGE            ${SRC} "PACKAGE"        )
      get_target_property( ROOT               ${SRC} "ROOT"           )
      get_target_property( FIDL_FILE          ${SRC} "FIDL_FILE"      )
      get_target_property( INTERFACES         ${SRC} "INTERFACES"     )

      if( NOT FIDL_FILE )
         message( FATAL_ERROR "target ${SRC} does not represent a FIDL file" )
      endif()

      # this is only necessary because the generated D-Bus adaptor file contains information (signatures)
      # from externally defined types
      set( DEP_FIDLS "" )   # list of all FIDL source files the current one depends on
      _apifiddler_get_referenced_fidls( FIDL ${SRC} VAR DEP_FIDLS )

      # get the path of the package
      string( REPLACE "." "/" PACKAGE_PATH "${PACKAGE}" )

      # get the FIDL file base name
      get_filename_component( FIDL_BASENAME ${FIDL_FILE} NAME )
      string( REGEX REPLACE "\\.fidl$" "" FIDL_BASENAME "${FIDL_BASENAME}" )

      if( APIFIDDLER_DEBUG_OUTPUT )
         message( STATUS "[fidl_gen_adaptor_qtdbus] ${SRC}.PACKAGE          : ${PACKAGE}" )
         message( STATUS "[fidl_gen_adaptor_qtdbus] ${SRC}.ROOT             : ${ROOT}" )
         message( STATUS "[fidl_gen_adaptor_qtdbus] ${SRC}.FIDL_FILE        : ${FIDL_FILE}" )
         message( STATUS "[fidl_gen_adaptor_qtdbus] ${SRC}.INTERFACES       : ${INTERFACES}" )
      endif()

      set( curSourceFile  "${ROOT}/${FIDL_FILE}" )
      set( curOutFileXml  "${OUTPATH}/introspection/${FIDL_BASENAME}.xml" )

      # generate registry
      set( curOutFileCpp  "${OUTPATH}/${PARAM_REGISTRYFOLDER}/src/${FIDL_BASENAME}${PARAM_SURFIX}.cpp" )
      set( curOutFileHpp  "${OUTPATH}/${PARAM_REGISTRYFOLDER}/include/${FIDL_BASENAME}${PARAM_SURFIX}.hpp" )
      set( curOutFiles ${curOutFileHpp} ${curOutFileCpp} )

      set( outParam "-o" "qt-dbus-registry(root=${OUTPATH}/${PARAM_REGISTRYFOLDER},typeDefRoot=${PARAM_TYPEDEFFOLDER},include=${FIDL_BASENAME}${PARAM_SURFIX}.hpp,hpp=${FIDL_BASENAME}${PARAM_SURFIX}.hpp,cpp=${FIDL_BASENAME}${PARAM_SURFIX}.cpp,fileSurfix=${PARAM_SURFIX},firstFidl=true,lastFidl=true" )
      set( outParam "${outParam})" )

      list( APPEND outRegistryHeaderFiles ${curOutFileHpp} )
      list( APPEND outSourceFiles ${curOutFileCpp} )

      # ApiFiddler has a bug, it will not create a new file even though firstFidl=true, it will append the output to the existing file. Therefore we have to remove the file
      # before running the ApiFiddler
      add_custom_command( OUTPUT ${curOutFiles}
                          COMMAND ${CMAKE_COMMAND} -E remove ${curOutFiles}
                          COMMAND
                              ${ApiFiddler_COMMAND}
                              ${outParam}
                              "${ROOT}/${FIDL_FILE}"
                          VERBATIM
                          DEPENDS ${curSourceFile}
                                  ${DEP_FIDLS}
                                  "${ApiFiddler_JAR}"
                                  ${PARAM_DEPENDS}
                        )

      # generate typeDef
      if ( NOT INTERFACES )
         # not an interface - api fiddler will generate the files for a type definition (different folder)
         set( curOutFileCpp  "" )
         set( curOutFileHpp  "${OUTPATH}/${PARAM_TYPEDEFFOLDER}/include/${PACKAGE_PATH}/${FIDL_BASENAME}/${FIDL_BASENAME}${PARAM_SURFIX}.hpp" )
      else()
         set( curOutFileHpp  "${OUTPATH}/${PARAM_TYPEDEFFOLDER}/include/${PACKAGE_PATH}/${FIDL_BASENAME}${PARAM_SURFIX}.hpp" )
      endif()
      set( curOutFiles ${curOutFileHpp} ${curOutFileCpp} )

      set( outParam "-o" "qt-dbus-typeDef(root=${OUTPATH}/${PARAM_TYPEDEFFOLDER},hpp=${FIDL_BASENAME}.hpp,fileSurfix=${PARAM_SURFIX},single=${FIRSTFIDL}" )
      set( FIRSTFIDL false )
      set( outParam "${outParam})" )

      add_custom_command( OUTPUT ${curOutFiles}
                          COMMAND
                              ${ApiFiddler_COMMAND}
                              ${outParam}
                              "${ROOT}/${FIDL_FILE}"
                          VERBATIM
                          DEPENDS ${curSourceFile}
                                  ${DEP_FIDLS}
                                  "${ApiFiddler_JAR}"
                                  ${PARAM_DEPENDS}
                        )

      list( APPEND outHeaderFiles ${curOutFileHpp} )
      list( APPEND outSourceFiles ${curOutFileCpp} )

      # generate proxies
      if ( INTERFACES )
         set( curOutFileHpp  "${OUTPATH}/${PARAM_PROXYFOLDER}/include/${PACKAGE_PATH}/${FIDL_BASENAME}${PARAM_SURFIX}.hpp" )
         set( curOutFileCpp  "${OUTPATH}/${PARAM_PROXYFOLDER}/src/${PACKAGE_PATH}/${FIDL_BASENAME}${PARAM_SURFIX}.cpp" )
         set( curOutFiles ${curOutFileHpp} ${curOutFileCpp} )

         set( outParam "-v" "-o" "qt-dbus-proxy(root=${OUTPATH}/${PARAM_PROXYFOLDER},typeDefRoot=${PARAM_TYPEDEFFOLDER},typeDef=${FIDL_BASENAME}${PARAM_SURFIX}.hpp,hpp=${FIDL_BASENAME}.hpp,cpp=${FIDL_BASENAME}.cpp,fileSurfix=${PARAM_SURFIX}" )
         set( outParam "${outParam})" )

         add_custom_command( OUTPUT ${curOutFiles}
                             COMMAND
                                 ${ApiFiddler_COMMAND}
                                 ${outParam}
                                 "${ROOT}/${FIDL_FILE}"
                             VERBATIM
                             DEPENDS ${curSourceFile}
                                     ${DEP_FIDLS}
                                     "${ApiFiddler_JAR}"
                                     ${PARAM_DEPENDS}
                           )

         list( APPEND outHeaderFiles ${curOutFileHpp} )
         list( APPEND outSourceFiles ${curOutFileCpp} )
      endif()

   endforeach()

   if( PARAM_SOURCEFILES )
      set( ${PARAM_SOURCEFILES} ${${PARAM_SOURCEFILES}} ${outSourceFiles} PARENT_SCOPE )
   endif()
   if( PARAM_HEADERFILES )
      set( ${PARAM_HEADERFILES} ${${PARAM_HEADERFILES}} ${outHeaderFiles} PARENT_SCOPE )
   endif()
   if( PARAM_REGISTRYHEADERFILES )
      set( ${PARAM_REGISTRYHEADERFILES} ${${PARAM_REGISTRYHEADERFILES}} ${outRegistryHeaderFiles} PARENT_SCOPE )
   endif()
   if(PARAM_TARGET)
      add_custom_target( ${PARAM_TARGET} DEPENDS ${outSourceFiles} ${outHeaderFiles} ${outRegistryHeaderFiles} )
      _apifiddler_group_targets(${PARAM_TARGET})
   endif()
endfunction()

##############################################
#! fidl_gen_doc_html: generates HTML documentation for the specified FIDL files
#
# \param:TARGET            target to be associated with this generator step
# \param:VAR               if set, the names of the generated files are stored in VAR
# \param:OUTPATH           root path the generated documentation
# \group:FIDL              list of FIDL files to generate adaptors for
# \group:DEPENDS           additional dependencies
function( fidl_gen_doc_html)
   cmake_parse_arguments(PARAM "" "TARGET;VAR;OUTPATH" "FIDL;DEPENDS" ${ARGN})

   # TODO: improve input validation
   if( NOT PARAM_OUTPATH)
      set(PARAM_OUTPATH "${CMAKE_CURRENT_BINARY_DIR}/html")
   endif()

   set(outFiles "")

   foreach(SRC ${PARAM_FIDL})
      get_target_property(PACKAGE            ${SRC} "PACKAGE"        )
      get_target_property(ROOT               ${SRC} "ROOT"           )
      get_target_property(FIDL_FILE          ${SRC} "FIDL_FILE"      )
      get_target_property(TYPECOLLECTIONS    ${SRC} "TYPECOLLECTIONS")
      get_target_property(INTERFACES         ${SRC} "INTERFACES"     )
      get_target_property(TYPES              ${SRC} "TYPES"          )

      if(NOT FIDL_FILE)
         message( FATAL_ERROR "target ${SRC} does not represent a FIDL file")
      endif()

      # get the FIDL file base name
      string(REGEX REPLACE "\\.fidl$" "" FIDL_BASENAME "${FIDL_FILE}")
      get_filename_component(FIDL_BASENAME_NO_PATH "${FIDL_BASENAME}" NAME)
      get_filename_component(FIDL_PATH "${FIDL_BASENAME}" DIRECTORY)

      string(REPLACE "." "/" PACKAGE_AS_PATH "${PACKAGE}")

      if(APIFIDDLER_DEBUG_OUTPUT)
         message( STATUS "[fidl_gen_doc_html] ${SRC}.PACKAGE          : ${PACKAGE}")
         message( STATUS "[fidl_gen_doc_html] ${SRC}.ROOT             : ${ROOT}")
         message( STATUS "[fidl_gen_doc_html] ${SRC}.FIDL_FILE        : ${FIDL_FILE}")
         message( STATUS "[fidl_gen_doc_html] ${SRC}.TYPECOLLECTIONS  : ${TYPECOLLECTIONS}")
         message( STATUS "[fidl_gen_doc_html] ${SRC}.INTERFACES       : ${INTERFACES}")
         message( STATUS "[fidl_gen_doc_html] ${SRC}.TYPES            : ${TYPES}")
      endif()

      set( curSourceFile "${ROOT}/${FIDL_FILE}")
      set( curOutFiles   "${PARAM_OUTPATH}/${PACKAGE_AS_PATH}/${FIDL_BASENAME_NO_PATH}.html")

      add_custom_command( OUTPUT ${curOutFiles}
                          COMMAND
                              ${ApiFiddler_COMMAND}
                              "-o"
                              "html(path=${PARAM_OUTPATH})"
                              "${ROOT}/${FIDL_FILE}"
                          VERBATIM
                          DEPENDS ${curSourceFile}
                                  "${ApiFiddler_JAR}"
                                  ${PARAM_DEPENDS}
                          WORKING_DIRECTORY "${ROOT}/${FIDL_PATH}"
                        )

      list( APPEND outFiles ${curOutFiles})
   endforeach()

   if(APIFIDDLER_DEBUG_OUTPUT)
      message( STATUS "[fidl_gen_doc_html] outFiles     : ${outFiles}")
   endif()

   if(DEFINED PARAM_VAR)
      if(DEFINED ${PARAM_VAR})
         set(${PARAM_VAR} ${${PARAM_VAR}} ${outFiles} PARENT_SCOPE)
      else()
         set(${PARAM_VAR} ${outFiles} PARENT_SCOPE)
      endif()
   endif()
   if(PARAM_TARGET)
      add_custom_target( ${PARAM_TARGET} DEPENDS ${outFiles} )
      _apifiddler_group_targets(${PARAM_TARGET})
   endif()
endfunction()
