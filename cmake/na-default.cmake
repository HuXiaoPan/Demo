# EasyDrive default build configuration, e.g.
# compiler warning levels, flags etc.
#
# Usage:
# --------
# project(xyz)
# include(cmake/na-default.cmake)
# --------

if((NOT CMAKE_C_COMPILER_ID) OR (NOT CMAKE_CXX_COMPILER_ID))
   message(FATAL_ERROR "na-default.cmake must be included *after* project()")
   # The reason for this is that project() initializes the build environment,
   # e.g. CMAKE_C_COMPILER_ID, CMAKE_CXX_COMPILER_ID, and this file then modifies them.
endif()

##################################################################################################################

# Prevent a cmake in-source build. We want all build artefacts to be created *outside* of the source folder.
# The build process must not modify our source code at all.
# Solution 1:
# http://stackoverflow.com/questions/1208681/with-cmake-how-would-you-disable-in-source-builds
# set(CMAKE_DISABLE_SOURCE_CHANGES  ON)
# set(CMAKE_DISABLE_IN_SOURCE_BUILD ON)
# However, this will fail with a cryptic error message. The better approach is:
# Solution 2:
get_filename_component(srcdir "${CMAKE_SOURCE_DIR}" REALPATH) # resolve symlinks
get_filename_component(bindir "${CMAKE_BINARY_DIR}" REALPATH) # resolve symlinks
if("${srcdir}" STREQUAL "${bindir}")
   message(FATAL_ERROR "You are doing an in-source build, which means that the build products are put INTO the source code tree instead of OUTSIDE. That is against our build process evangelism. Please choose a different output folder.")
endif()

if(NOT CMAKE_INSTALL_PREFIX)
   string(REGEX REPLACE "(.*)-build(.*)" "\\1-install\\2" CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}")
   if("${CMAKE_INSTALL_PREFIX}" STREQUAL "${CMAKE_BINARY_DIR}")
      set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}-install")
   endif()
   message(STATUS "Variable CMAKE_INSTALL_PREFIX was not set from outside. Setting it to ${CMAKE_INSTALL_PREFIX}")
endif()

##################################################################################################################

# If you get this error message, your cmake is outdated: Please upgrade it.
# You can find an installer as usual on \\naisftp.easydrivetech.com\NAIS_FTP\Tools
cmake_minimum_required(VERSION 2.8) # in near future, we want to make 3.x mandatory everywhere, not only on Win32
if(WIN32)
   cmake_minimum_required(VERSION 3.7.1)
endif()

##################################################################################################################

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Debug")
endif()
message(STATUS "Build Type: ${CMAKE_BUILD_TYPE}")
if(NOT (CMAKE_BUILD_TYPE STREQUAL "Debug"))
   add_definitions(-DNDEBUG)
endif()

##################################################################################################################

# Declare parent target for generating all documentation.
# If you declare a documentation portion subtarget, e.g. doc_doxygen, let this one depend on that, e.g.
# add_dependencies(doc doc_doxygen)
add_custom_target(doc)
set_target_properties(doc PROPERTIES FOLDER "Documentation")

##################################################################################################################

# enable folders in IDE
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

# helper to set FOLDER on external projects
function(na_auto_folder_property cmake_file target)
   get_property(imported TARGET ${target} PROPERTY IMPORTED)
   if (imported)
      #message(STATUS "Target ${target} is imported")
      return()
   endif()
   get_property(folder TARGET ${target} PROPERTY FOLDER)
   if (folder)
      #message(STATUS "Target ${target} has folder property")
      return()
   endif()
   set(pattern "[\\/]external[\\/](.*)")
   STRING(REGEX MATCH ${pattern} match ${cmake_file})
   if (match)
      # found an external target, allow one additional subfolder level
      string(REGEX REPLACE "[\\/].*" "" subfolder ${CMAKE_MATCH_1})
      if (subfolder)
         set(folder "external/${subfolder}")
      else()
         set(folder "external")
      endif()
      #message(STATUS "Target ${target} SET FOLDER ${folder}")
      set_target_properties(${target}
                            PROPERTIES FOLDER "${folder}")
   endif()
endfunction()

# redirect add_library and add_executable
macro( add_library target )
    _add_library( ${target} ${ARGN} )
    na_auto_folder_property(${CMAKE_CURRENT_LIST_FILE} ${target})
endmacro()
macro( add_executable target )
    _add_executable( ${target} ${ARGN} )
    na_auto_folder_property(${CMAKE_CURRENT_LIST_FILE} ${target})
endmacro()

##################################################################################################################

# make temp directory available as cmake variable
if(WIN32)
   set(TMPDIR "$ENV{TEMP}")
elseif(ANDROID)
   set(TMPDIR "/tmp")
else()
   set(TMPDIR "/tmp")
endif()

##################################################################################################################

# Use ccache
option(USE_CCACHE "Use ccache to speed up build" OFF)
if(USE_CCACHE)
   set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE ccache)
   set_property(GLOBAL PROPERTY RULE_LAUNCH_LINK ccache)
endif()

##################################################################################################################

if(EXISTS ${CMAKE_CURRENT_LIST_DIR}/Modules)
# message(STATUS "Adding ${CMAKE_CURRENT_LIST_DIR}/Modules to module path")
  list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/Modules/")
endif()

if(CMAKE_CXX_COMPILER_ID)
# message(STATUS "Trying ${CMAKE_CURRENT_LIST_DIR}/Compiler/na-${CMAKE_CXX_COMPILER_ID}-cxx.cmake")
  include(${CMAKE_CURRENT_LIST_DIR}/Compiler/na-${CMAKE_CXX_COMPILER_ID}-cxx.cmake OPTIONAL)
endif()

IF(CMAKE_C_COMPILER_ID)
# message(STATUS "Trying ${CMAKE_CURRENT_LIST_DIR}/Compiler/na-${CMAKE_C_COMPILER_ID}-c.cmake")
  include(${CMAKE_CURRENT_LIST_DIR}/Compiler/na-${CMAKE_C_COMPILER_ID}-c.cmake OPTIONAL)
endif()

##################################################################################################################

# http://stackoverflow.com/a/9328525
macro(DumpAllCMakeVariables)
   message(STATUS "--- now dumping all cmake variables -----------------------------------------------------")
   get_cmake_property(_variableNames VARIABLES)
   foreach(_variableName ${_variableNames})
      message(STATUS "${_variableName}=${${_variableName}}")
   endforeach()
   message(STATUS "--- end of cmake variable dump ----------------------------------------------------------")
endmacro()

##################################################################################################################

# set CMAKE_C_FLAGS and CMAKE_CXX_FLAGS from Compiler/na-<...>.cmake definitions
# depending on given code target:
#   TARGET    NA code for final platform
#   EXTERNAL  Other code for final platform
#   TEST      Code for tests not active in final product
#
# Used:
#  NA_STD_CMAKE_C_FLAGS            Base definition of C compile flags independent of given target
#  NA_STD_CMAKE_CXX_FLAGS          Base definition of C++ compile flags independent of given target
#  NA_<target>_C_COMPILE_FLAGS     Additional C compile flags for given target
#  NA_<target>_CXX_COMPILE_FLAGS   Additional C++ compile flags for given target
#
macro(DefaultCompileFlags target)
  if(NA_STD_CMAKE_C_FLAGS)
    set(CMAKE_C_FLAGS "${NA_STD_CMAKE_C_FLAGS}")
    if (NA_${target}_C_COMPILE_FLAGS)
      set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${NA_${target}_C_COMPILE_FLAGS}")
    endif()
  endif()
  if(NA_STD_CMAKE_CXX_FLAGS)
    set(CMAKE_CXX_FLAGS "${NA_STD_CMAKE_CXX_FLAGS}")
    if (NA_${target}_CXX_COMPILE_FLAGS)
      set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${NA_${target}_CXX_COMPILE_FLAGS}")
    endif()
  endif()

  #MESSAGE(STATUS "${CMAKE_CURRENT_LIST_FILE}")
  #MESSAGE(STATUS "CMAKE_C_FLAGS   ${CMAKE_C_FLAGS}")
  #MESSAGE(STATUS "CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS}")
  #set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-return-stack-address -Wno-overloaded-virtual -Wno-shadow -Wno-unused-private-field -Wno-delete-non-virtual-dtor -Wno-tautological-constant-compare -Wno-tautological-unsigned-enum-zero-compare -Wno-enum-compare-switch -Wno-enum-compare")
  if(WIN32)
  #set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-return-stack-address -Wno-overloaded-virtual -Wno-shadow -Wno-unused-private-field -Wno-delete-non-virtual-dtor -Wno-tautological-pointer-compare -Wno-tautological-undefined-compare -Wno-enum-compare -Wno-format-nonliteral")
  else()
#  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-return-stack-address -Wno-overloaded-virtual -Wno-shadow -Wno-unused-private-field -Wno-delete-non-virtual-dtor -Wno-tautological-pointer-compare -Wno-tautological-undefined-compare -Wno-enum-compare -Wno-format-nonliteral")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-overloaded-virtual -Wno-shadow -Wno-delete-non-virtual-dtor -Wno-enum-compare -Wno-format-nonliteral")
    if(WITH_ASAN)
      set(CMAKE_CXX_FLAGS "-fsanitize=address -fno-omit-frame-pointer ${CMAKE_CXX_FLAGS}")
    endif()
  endif()
endmacro(DefaultCompileFlags target)

##################################################################################################################

DefaultCompileFlags(TARGET)
if(COMMAND na_print_compiler_version)
   na_print_compiler_version()
endif()
add_definitions("-D__STDC_LIMIT_MACROS")

##################################################################################################################

# GLOBAL_OPTION wraps option() command
# Default behaviour sets given option to given default value
# To override the default value use
#  set(<option_var>_DEFAULT ON)
# or
#  set(<option_var>_DEFAULT OFF)
# before initializing the option for the very first time.
# The override priority is (from high to low):
#  1. value in CMakeCache.txt (e.g. via cmake command like option -D...)
#  2. value set to the non-cached variable of same name as option_var with "_DEFAULT" postfix before defining
#     the option
#  3. value of option_default
#
# For compatibility reasons, it will still be possible to use a non-cached variable without postfix to initialize
# the cache variable, but it will issue warnings. The feature itself is not safe because of variable scope issues.
#
# Example:
#  # new way using the "_DEFAULT" postfix
#  set(MY_OPTION_DEFAULT OFF)
#  GLOBAL_OPTION( MY_OPTION ON "Just a test option")
#
#  # old way, will now cause a warning
#  set(MY_OPTION OFF)
#  GLOBAL_OPTION( MY_OPTION ON "Just a test option")
#
macro(GLOBAL_OPTION option_var option_default option_text)
  if(DEFINED ${option_var})
    # variable is already defined; try to figure out if it has been defined in cache or locally
    set( _local_value "${${option_var}}")
    unset( ${option_var})
    set( _cache_value "${${option_var}}")
    if(NOT "${_cache_value}" STREQUAL "")
      # there is a value in cache already!
      if(     (    _local_value AND NOT _cache_value)
          OR  (NOT _local_value AND     _cache_value))
        # there definitely is a non-cached variable defined!
        message( FATAL_ERROR "cache variable '${option_var}' contains a local override (value=${_cache_value}, local=${_local_value})")
      endif()
    else()
      # there is no entry in cache yet, but a local override exists
      message( WARNING "using local variable '${option_var}' to initialize cache value; this is unsafe, please use '${option_var}_DEFAULT' instead.")
      option(${option_var} ${option_text} ${${option_var}})
    endif()
  elseif(DEFINED ${option_var}_DEFAULT)
    option(${option_var} ${option_text} ${${option_var}_DEFAULT})
  else()
    option(${option_var} ${option_text} ${option_default})
  endif()
  set(${option_var}__TEXT ${option_text})
endmacro()

GLOBAL_OPTION(DISABLE_EXTERNAL_LIBS OFF "Disable use of external subdir")
if(CMAKE_CROSSCOMPILING)
   GLOBAL_OPTION(WITH_TESTS         OFF "Enable test subdirs")
else()
   GLOBAL_OPTION(WITH_TESTS         ON  "Enable test subdirs")
endif()
GLOBAL_OPTION(WITH_DOCS             OFF "Enable documentation subdirs")

# MODULE_OPTION wraps option command
# Allows to specify module specific values of global options defined above
# Generates a new option  <option_var>_<module>
# If a variable <option_var>_<module>_DEFAULT exists this value is used as default
# If a global option/variable <option_var> exists this value is used as default
# Otherwise the default is OFF
macro(MODULE_OPTION option_var module)
  set(_option_text " Option")
  if(DEFINED ${option_var}__TEXT)
    set(_option_text ${${option_var}__TEXT})
  endif()
  if(DEFINED ${option_var}_${module})
    # variable is already defined; try to figure out if it has been defined in cache or locally
    set( _local_value "${${option_var}_${module}}")
    unset( ${option_var}_${module})
    set( _cache_value "${${option_var}_${module}}")
    if(NOT "${_cache_value}" STREQUAL "")
      # there is a value in cache already!
      if(     (    _local_value AND NOT _cache_value)
          OR  (NOT _local_value AND     _cache_value))
        # there definitely is a non-cached variable defined!
        message( FATAL_ERROR "cache variable '${option_var}_${module}' contains a local override (value=${_cache_value}, local=${_local_value})")
      endif()
    else()
      # there is no entry in cache yet, but a local override exists
      message( WARNING "using local variable '${option_var}_${module}' to initialize cache value; this is unsafe, please use '${option_var}_${module}_DEFAULT' instead.")
      option(${option_var}_${module} "${_option_text} for ${module}" ${${option_var}_${module}})
    endif()
  elseif(DEFINED ${option_var}_${module}_DEFAULT)
    option(${option_var}_${module} "${_option_text} for ${module}" ${${option_var}_${module}_DEFAULT})
  elseif(DEFINED ${option_var})
    option(${option_var}_${module} "${_option_text} for ${module}" ${${option_var}})
  else()
    option(${option_var}_${module} "${_option_text} for ${module}" OFF)
  endif()
endmacro()

##################################################################################################################

include(${CMAKE_CURRENT_LIST_DIR}/na-external.cmake)

##################################################################################################################

message(STATUS "CMAKE_TOOLCHAIN_FILE = ${CMAKE_TOOLCHAIN_FILE}")
message(STATUS "CMAKE_CROSSCOMPILING = ${CMAKE_CROSSCOMPILING}")
message(STATUS "CMAKE_FIND_ROOT_PATH = ${CMAKE_FIND_ROOT_PATH}")
if(CMAKE_FIND_ROOT_PATH AND NOT CMAKE_CROSSCOMPILING)
   message(FATAL_ERROR "Your specified cmake toolchain is incomplete. It sets CMAKE_FIND_ROOT_PATH but does not set CMAKE_CROSSCOMPILING to TRUE which it must do.")
endif()

if(NOT CMAKE_CROSSCOMPILING)
   # Allow declaration of unittests via add_test(), for example, if your funit "xyz" declares
   # a test executable "test_funit_xyz_test123" (which has to return 0 on success and !=0 on error),
   # you can make the global build target "test" depend on it by:
   #    add_test(NAME run_test_funit_xyz_test123 COMMAND test_funit_xyz_test123)
   enable_testing()
   # Default: Database tests enabled
   if (NOT DEFINED NA_DATABASE_TESTS)
      set(NA_DATABASE_TESTS ON)
   endif()
else()
   cmake_policy(PUSH)
   cmake_policy(SET CMP0037 OLD) # suppress warning about declaring a build target using the reserved name "test". this is intentional here.
   add_custom_target(test)       # dummy placeholder target so that a make target "test" always exists, this makes buildbot setup easier
   cmake_policy(POP)
endif()
