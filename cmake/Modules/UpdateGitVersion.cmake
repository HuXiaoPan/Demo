
cmake_minimum_required(VERSION 2.8.2)

#
# Usage:
# add_executable(SomeTarget ...)
#   or
# add_library(SomeTarget ...)
#
# UpdateGitVersion(${CMAKE_CURRENT_SOURCE_DIR}/configure.hpp.in
#                  ${CMAKE_CURRENT_BINARY_DIR}/configure.hpp
#                  SomeTarget)
#
# This function calls internally configure_file() and will update variables with
# version details obtained from git for the current repository.
#
# Note: If the current directory where the CMakeLists.txt is located that calls this function
#       is a git submodule the version is obtained from the submodule and not from the parent
#       repository.
#
# See configure_file() how to replace variables with cmake.
#
# This function replaces the following variables:
#   GIT_REVISION
#         the git revision HEAD points to (e.g. 4a6bf35)
#   GIT_TAG
#         the latest annotated tag on the current branch (e.g. own/release/0.7.1-23-g4a6bf35-dirty)
#         where - own/release/0.7.1 is the tag
#               - 23 means 23 commits are between HEAD and that commit
#               - 4a6bf35 is the HEAD commit
#               - dirty means that local changes have been made
#

function(UpdateGitVersion CONFIGURE_HEADER_IN CONFIGURE_HEADER_OUT DEPENDENCY)
   UpdateGitVersionWithMatchStr(${CONFIGURE_HEADER_IN} ${CONFIGURE_HEADER_OUT} "" ${DEPENDENCY} ${ARGN})
endfunction(UpdateGitVersion)

function(UpdateGitVersionWithMatchStr CONFIGURE_HEADER_IN CONFIGURE_HEADER_OUT OPTIONAL_MATCH_STR DEPENDENCY)
   if(DUMMY_GIT_VERSION)
      ConfigureFileWithDummyVersion(${CONFIGURE_HEADER_IN} ${CONFIGURE_HEADER_OUT} ${DEPENDENCY} ${ARGN})
   else()
      ConfigureFileWithGitVersion(${CONFIGURE_HEADER_IN} ${CONFIGURE_HEADER_OUT} "${OPTIONAL_MATCH_STR}" ${DEPENDENCY} ${ARGN})
   endif()
endfunction(UpdateGitVersionWithMatchStr)

function(ConfigureFileWithDummyVersion CONFIGURE_HEADER_IN CONFIGURE_HEADER_OUT DEPENDENCY)
  file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/git_version.cmake
  "# setup dummy revision

  set(GIT_REVISION \"0000000\")
  set(GIT_TAG \"dummy\")

  # configure file (generate configure.hpp)
  message(STATUS \"Generating ${CONFIGURE_HEADER_OUT}.\")
  configure_file(${CONFIGURE_HEADER_IN}
                 ${CONFIGURE_HEADER_OUT}
                 @ONLY NEWLINE_STYLE UNIX)
  ")

  # define command
  add_custom_command(OUTPUT UpdateGitRevision_${DEPENDENCY}
                     DEPENDS ${CONFIGURE_HEADER_OUT})

  # define target, that calls indirectly configure_file
  add_custom_target(UpdateGitRevision_${DEPENDENCY}
                    COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/git_version.cmake
                    SOURCES ${CONFIGURE_HEADER_IN})

  set_target_properties(UpdateGitRevision_${DEPENDENCY}
                        PROPERTIES FOLDER "Generated/UpdateGitRevision")

  # set property for generated file
  set_source_files_properties(${CONFIGURE_HEADER_OUT}
                              PROPERTIES GENERATED TRUE
                              HEADER_FILE_ONLY TRUE)

  add_dependencies(${DEPENDENCY} UpdateGitRevision_${DEPENDENCY})

  foreach(arg IN LISTS ARGN)
    add_dependencies(${arg} UpdateGitRevision_${DEPENDENCY})
  endforeach()
endfunction(ConfigureFileWithDummyVersion)

function(ConfigureFileWithGitVersion CONFIGURE_HEADER_IN CONFIGURE_HEADER_OUT OPTIONAL_MATCH_STR DEPENDENCY)
  if(OPTIONAL_MATCH_STR)
    set(MATCH_STR "--match \"${OPTIONAL_MATCH_STR}\"")
  else()
    set(MATCH_STR "")
  endif()

  file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/git_version.cmake
  "# get current revision
  
  find_package(Git)
  if(NOT GIT_FOUND)
     message(WARNING \"Git not found. No version information available.\")
  else()
     execute_process(COMMAND \${GIT_EXECUTABLE} rev-parse --short=7 --verify --sq HEAD
                     WORKING_DIRECTORY \"${CMAKE_CURRENT_SOURCE_DIR}\"
                     OUTPUT_VARIABLE GIT_REVISION
                     ERROR_VARIABLE GIT_ERROR
                     OUTPUT_STRIP_TRAILING_WHITESPACE
                     ERROR_QUIET)

     if(NOT GIT_REVISION)
       message(WARNING \"Failed getting current commit (HEAD).\")
       set(GIT_REVISION \"0000000\")
     else()
       # sanitize output
       string(REPLACE \"'\" \"\" GIT_REVISION \"\${GIT_REVISION}\")
       message(STATUS \"Current Commit (HEAD): \${GIT_REVISION}\")
     endif()

     # get tag for current revision if any
     execute_process(COMMAND \${GIT_EXECUTABLE} describe --dirty ${MATCH_STR}
                     WORKING_DIRECTORY \"${CMAKE_CURRENT_SOURCE_DIR}\"
                     OUTPUT_VARIABLE GIT_TAG
                     ERROR_VARIABLE GIT_ERROR
                     OUTPUT_STRIP_TRAILING_WHITESPACE
                     ERROR_QUIET)

     # fallback if nothing has been found
     if(NOT GIT_TAG)
       # get details for current revision
       execute_process(COMMAND \${GIT_EXECUTABLE} describe --dirty --all
                       WORKING_DIRECTORY \"${CMAKE_CURRENT_SOURCE_DIR}\"
                       OUTPUT_VARIABLE GIT_TAG
                       ERROR_VARIABLE GIT_ERROR
                       OUTPUT_STRIP_TRAILING_WHITESPACE
                       ERROR_QUIET)
     endif()

     if(NOT GIT_TAG)
       #message(WARNING \"Failed getting tag information.\")
       set(GIT_TAG \"unknown-dirty\")
     endif()

     # sanitize output 'git describe' output
     string(REPLACE \"'\" \"\" GIT_TAG \"\${GIT_TAG}\")
     message(STATUS \"Recent tag on branch: \${GIT_TAG}\")

     # configure file (generate configure.hpp)
     message(STATUS \"Generating ${CONFIGURE_HEADER_OUT}.\")
     configure_file(${CONFIGURE_HEADER_IN}
                    ${CONFIGURE_HEADER_OUT}
                    @ONLY NEWLINE_STYLE UNIX)
  endif()
  ")

  # define command
  add_custom_command(OUTPUT UpdateGitRevision_${DEPENDENCY}
                     DEPENDS ${CONFIGURE_HEADER_OUT})

  # define target, that calls indirectly configure_file
  add_custom_target(UpdateGitRevision_${DEPENDENCY}
                    COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/git_version.cmake
                    SOURCES ${CONFIGURE_HEADER_IN})

  set_target_properties(UpdateGitRevision_${DEPENDENCY}
                        PROPERTIES FOLDER "Generated/UpdateGitRevision")

  # set property for generated file
  set_source_files_properties(${CONFIGURE_HEADER_OUT}
                              PROPERTIES GENERATED TRUE
                              HEADER_FILE_ONLY TRUE)

  add_dependencies(${DEPENDENCY} UpdateGitRevision_${DEPENDENCY})

  foreach(arg IN LISTS ARGN)
    add_dependencies(${arg} UpdateGitRevision_${DEPENDENCY})
  endforeach()
endfunction(ConfigureFileWithGitVersion)

function(GetVersionGit)
   if(DUMMY_GIT_VERSION)
      set(GITVERSIONSTRING "dummy")
   else()      
      set(VERSION_REGEX_STRING "own/release/*")

      find_program(GIT_EXECUTABLE NAMES git git.cmd CMAKE_FIND_ROOT_PATH_BOTH)
      if(${GIT_EXECUTABLE} MATCHES "GIT_EXECUTABLE-NOTFOUND")
         message(STATUS "Git not found. Cannot compute VERSION_GIT_FULL")
         set(GITVERSIONSTRING "unknown")
      else()
         exec_program("${GIT_EXECUTABLE}"
                      ${CMAKE_CURRENT_SOURCE_DIR}
                      ARGS "describe --dirty --long --abbrev=7 --match ${VERSION_REGEX_STRING}"
                      OUTPUT_VARIABLE GITVERSIONSTRING)

         #message("GetVersionGit 1: ${GITVERSIONSTRING}")
                    
         if(${GITVERSIONSTRING} MATCHES ${VERSION_REGEX_STRING})
            string(REPLACE "own/release/" "" GITVERSIONSTRING "${GITVERSIONSTRING}")
            #message("GetVersionGit 2: ${GITVERSIONSTRING}")
         else()
            exec_program("${GIT_EXECUTABLE}"
                         ${CMAKE_CURRENT_SOURCE_DIR}
                         ARGS "rev-list --count HEAD"
                         OUTPUT_VARIABLE GITREFLIST)

            exec_program("${GIT_EXECUTABLE}"
                         ${CMAKE_CURRENT_SOURCE_DIR}
                         ARGS "rev-parse --short=7 HEAD"
                         OUTPUT_VARIABLE GITREFPARSE)

            set(GITVERSIONSTRING "r${GITREFLIST}.${GITREFPARSE}")
            #message("GetVersionGit 3: ${GITVERSIONSTRING}")
         endif()

         set(VERSION_GIT_FULL "${GITVERSIONSTRING}" PARENT_SCOPE)
         #message("GetVersionGit 4: ${VERSION_GIT_FULL}")
      endif()
   endif()      
endfunction(GetVersionGit)

function(GetCommitDateGit)
  find_program(GIT_EXECUTABLE NAMES git git.cmd CMAKE_FIND_ROOT_PATH_BOTH)
  if(${GIT_EXECUTABLE} MATCHES "GIT_EXECUTABLE-NOTFOUND")
    message(STATUS "Git not found! Cannot get commit date")
  else()
    exec_program(
                 "${GIT_EXECUTABLE}"
                 ${CMAKE_CURRENT_SOURCE_DIR}
                 ARGS "show -s --format=%ci HEAD"
                 OUTPUT_VARIABLE GITCOMMITDATE)

    set(COMMIT_DATE_GIT_REV "${GITCOMMITDATE}" PARENT_SCOPE)

  endif()
endfunction(GetCommitDateGit)

