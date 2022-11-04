# This module is shared by multiple languages; use include blocker.
if(na_libc_INCLUDED)
  return()
endif()
SET(na_libc_INCLUDED 1)

INCLUDE(CheckIncludeFiles)

cmake_minimum_required(VERSION 2.8.9)

# MESSAGE(STATUS "In ${CMAKE_CURRENT_LIST_FILE}")

macro(libc_default_settings var)
  if(CMAKE_CROSSCOMPILING)
    set(NA_GLIBC_WORKAROUND OFF)
  elseif(NOT DEFINED NA_GLIBC_WORKAROUND)
    CHECK_INCLUDE_FILES ("sys/sysmacros.h" HAVE_SYS_SYSMACROS_H)
    if(HAVE_SYS_SYSMACROS_H)
      try_compile(GLIBC_SYSMACRO_TEST_
        ${CMAKE_BINARY_DIR}
        SOURCES ${CMAKE_CURRENT_LIST_DIR}/tests/glibc.cpp
        CMAKE_FLAGS -DCOMPILE_DEFINITIONS:STRING=-Werror
        #OUTPUT_VARIABLE GLIBC_SYSMACRO_OUTPUT_
      )
      #message(STATUS "XXX GLIBC_SYSMACRO_OUTPUT_ ${GLIBC_SYSMACRO_OUTPUT_}")
      if (GLIBC_SYSMACRO_TEST_)
         set(NA_GLIBC_WORKAROUND OFF CACHE INTERNAL "GLIBC sys/types.h major/minor deprecated")
      else()
         set(NA_GLIBC_WORKAROUND ON  CACHE INTERNAL "GLIBC sys/types.h major/minor deprecated")
      endif()
    else()
       set(NA_GLIBC_WORKAROUND OFF CACHE INTERNAL "GLIBC sys/types.h major/minor deprecated")
    endif()
  endif()

  if (NA_GLIBC_WORKAROUND)
    SET(${var}  "${${var}} -include sys/sysmacros.h")
  endif()
endmacro(libc_default_settings lang)
