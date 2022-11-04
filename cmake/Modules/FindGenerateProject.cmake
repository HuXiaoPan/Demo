# - GenerateProject
# Enhance generated IDE (e.g. Visual Studio) projects by organizing the files according to their
# filesystem folder sructure (instead of the default flat view).
# This is only cosmetic.
# This module defines
#   GenerateProject, macro to organize files in IDE projects
#
# Usage Example:
# --------------------------------------------------------------------------------
# set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules/")
# find_package(GenerateProject)
#
# set( FILES
#      about.txt
#      foo.cpp
#      foo.hpp
#      bar/bar.cpp
#      bar/bar.hpp
#      foo.proto
# )
# GenerateProject( ${FILES) )
# add_library( foobar ${FILES} )
# --------------------------------------------------------------------------------
# Of cause GenerateProject() can also be used together with add_executable().
# Simply replace add_library() with add_executable() in the example above.
#
# ATTENTION! It is important to give all files to both commands.
# * Files that are only given to GenerateProject() aren't shown in the workspace.
# * Files that are only given to add_library() won't be sorted into the folders,
#   but into the CMake default folders 'Header Files' and 'Source Files'.
#
#=============================================================================
# Based on code from: http://www.cmake.org/Wiki/CMakeMacroGenerateProject
#=============================================================================

cmake_minimum_required(VERSION 2.8)

SET( GenerateProject_VERSION 1.1.0 )

# Using FIND_PACKAGE_HANDLE_STANDARD_ARGS only to do version check
INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS( GenerateProject
    REQUIRED_VARS GenerateProject_VERSION # We don't have any really required vars, so we use the version var instead
    VERSION_VAR GenerateProject_VERSION )


MACRO( GenerateProject )
   SET( DirSources ${ARGN} )

#   message( STATUS "GenProj: RootDir='${CMAKE_SOURCE_DIR}'" ) # for debugging
#   message( STATUS "GenProj: ProjectDir='${CMAKE_CURRENT_SOURCE_DIR}'" ) # for debugging
#   message( STATUS "GenProj: DirSources='${DirSources}'" ) # for debugging
   FOREACH( Source ${DirSources} )
#      message( STATUS "GenProj: Source='${Source}'" ) # for debugging
      STRING( REPLACE "${CMAKE_CURRENT_SOURCE_DIR}" "" RelativePath "${Source}" )
      STRING( REPLACE "${CMAKE_SOURCE_DIR}" "_root" RelativePath "${RelativePath}" )
      STRING( REPLACE "${CMAKE_BINARY_DIR}" "_buildt" RelativePath "${RelativePath}" )
      STRING( FIND "${RelativePath}" "/" found)
      IF( NOT found EQUAL -1 )
         STRING( REGEX REPLACE "[\\\\/][^\\\\/]*$" "" RelativePath "${RelativePath}" )
         STRING( REGEX REPLACE "^[\\\\/]" "" RelativePath "${RelativePath}" )
         STRING( REGEX REPLACE "/" "\\\\\\\\" RelativePath "${RelativePath}" )
      ELSE()
        SET( RelativePath "" )
      ENDIF()
#      message( STATUS "GenProj: SOURCE_GROUP(${RelativePath} FILES ${Source} )" ) # for debugging
      SOURCE_GROUP( "${RelativePath}" FILES ${Source} )
   ENDFOREACH()
ENDMACRO( GenerateProject )

