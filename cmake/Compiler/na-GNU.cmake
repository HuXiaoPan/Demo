# This module is shared by multiple languages; use include blocker.
if(na_GNU_INCLUDED)
  return()
endif()
SET(na_GNU_INCLUDED 1)

cmake_minimum_required(VERSION 2.8.9)

INCLUDE(${CMAKE_CURRENT_LIST_DIR}/na-libc.cmake)

# MESSAGE(STATUS "In ${CMAKE_CURRENT_LIST_FILE}")

macro(gcc_default_settings_4_base lang)
  if(NA_GNU_DEBUG_DEPTH)
    set(CMAKE_${lang}_FLAGS_DEBUG "-O0 -fno-omit-frame-pointer ${NA_GNU_DEBUG_DEPTH}")
  else()
    set(CMAKE_${lang}_FLAGS_DEBUG "-O0 -fno-omit-frame-pointer -g")
  endif()
  set(CMAKE_${lang}_FLAGS_RELEASE    "-Os")
  set(CMAKE_${lang}_FLAGS_MINSIZEREL "-Os")

  if(NOT DEFINED NA_GNU_HAVE_GOLD)
    # Check if can use GNU gold.
    set(linkver ${CMAKE_C_COMPILER};-fuse-ld=gold;-Wl,--version)
    execute_process(COMMAND ${linkver}
      RESULT_VARIABLE ld_result
      ERROR_QUIET
      OUTPUT_VARIABLE ld_out)
    set(have_gold FALSE)
    if (ld_result)
      # message("failed to get linker version, assuming ld.bfd (${ld_result})")
    elseif ("${ld_out}" MATCHES "GNU gold")
      set(have_gold TRUE)
    endif()
    set(NA_GNU_HAVE_GOLD ${have_gold} CACHE BOOL "GNU gold linker")
  endif()

  if (NA_GNU_HAVE_GOLD)
     SET(CMAKE_${lang}_FLAGS_RELEASE "${CMAKE_${lang}_FLAGS_RELEASE} -fuse-ld=gold")
     if(NOT DEFINED GNU__set_linker_icf)
        SET(GNU__set_linker_icf TRUE)
        SET(CMAKE_EXE_LINKER_FLAGS_RELEASE        "${CMAKE_EXE_LINKER_FLAGS_RELEASE_INIT} -Wl,--icf=safe"
            CACHE STRING "Initial flags used by the linker during release builds." FORCE)
        SET(CMAKE_EXE_LINKER_FLAGS_MINSIZEREL     "${CMAKE_EXE_LINKER_FLAGS_MINSIZEREL_INIT} -Wl,--icf=safe"
            CACHE STRING "Flags used by the linker during release minsize builds." FORCE)
        SET(CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO "${CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO_INIT} -Wl,--icf=safe"
            CACHE STRING "Initial flags used by the linker during Release with Debug Info builds." FORCE)
     endif()
  endif ()

  # Guard all stack frames in debug mode
  if(NOT CMAKE_SYSTEM_NAME STREQUAL "QNX")
    # On QNX libssp is missing
    SET(CMAKE_${lang}_FLAGS_DEBUG "${CMAKE_${lang}_FLAGS_DEBUG} -fstack-protector-all")
    # omit temporary files
    SET(NA_STD_CMAKE_${lang}_FLAGS "${NA_STD_CMAKE_${lang}_FLAGS} -pipe")
  endif()

  # copy default flags
  SET(NA_STD_CMAKE_${lang}_FLAGS "${CMAKE_${lang}_FLAGS}")

  # need position independent code for qt and nds lib
  #SET(NA_STD_CMAKE_${lang}_FLAGS "${NA_STD_CMAKE_${lang}_FLAGS} -fPIC")
  SET(CMAKE_POSITION_INDEPENDENT_CODE ON)

  # disable exception handling
  #SET(NA_STD_CMAKE_${lang}_FLAGS "${NA_STD_CMAKE_${lang}_FLAGS} -fno-exceptions")
  # make unqualified char signed
  SET(NA_STD_CMAKE_${lang}_FLAGS "${NA_STD_CMAKE_${lang}_FLAGS} -fsigned-char")
  # Write gcc switches to object file
  SET(NA_STD_CMAKE_${lang}_FLAGS "${NA_STD_CMAKE_${lang}_FLAGS} -frecord-gcc-switches")

  # Enable required POSIX functionality
  # TODO: right place here?
  SET(NA_STD_CMAKE_${lang}_FLAGS "${NA_STD_CMAKE_${lang}_FLAGS} -D_POSIX_C_SOURCE=200809L")

  if("${lang}" STREQUAL "C")
    if(DEFINED NA_GCC_C_STD)
      # Default C mode override from toolchain or command line
      SET(NA_STD_CMAKE_C_FLAGS "${NA_STD_CMAKE_C_FLAGS} ${NA_GCC_C_STD}")
    else()
      # Default C mode is ISO9899:1999
      SET(NA_STD_CMAKE_C_FLAGS "${NA_STD_CMAKE_C_FLAGS} -std=c99")
    endif()
  endif()

  if("${lang}" STREQUAL "CXX")
    if(DEFINED NA_GCC_CXX_STD)
      # Default C++ mode override from toolchain or command line
      SET(NA_STD_CMAKE_CXX_FLAGS "${NA_STD_CMAKE_CXX_FLAGS} ${NA_GCC_CXX_STD}")
    endif()
    # check-new is only for c++
    SET(NA_STD_CMAKE_CXX_FLAGS "${NA_STD_CMAKE_CXX_FLAGS} -fcheck-new")
  endif()

  # set standard warnings
  SET(NA_TARGET_${lang}_COMPILE_FLAGS "-Wall")

  # Check if we need special setting for the C library
  libc_default_settings(NA_TARGET_${lang}_COMPILE_FLAGS)

  if(NOT CMAKE_SYSTEM_NAME STREQUAL "QNX")
#    SET(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Werror")
    SET(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wtype-limits")
  endif()
  SET(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wformat=2 -Wno-error=format-nonliteral")
  SET(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wsign-compare")
  SET(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wvla")

  # Extended warnings for special components
  SET(NA_TARGET_STRICT_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS}")
  if(NOT CMAKE_SYSTEM_NAME STREQUAL "QNX")
    SET(NA_TARGET_STRICT_${lang}_COMPILE_FLAGS "${NA_TARGET_STRICT_${lang}_COMPILE_FLAGS} -Wconversion -Wno-error=conversion")
    SET(NA_TARGET_STRICT_${lang}_COMPILE_FLAGS "${NA_TARGET_STRICT_${lang}_COMPILE_FLAGS} -Wsign-conversion -Wno-error=sign-conversion")
  endif()

  # For test code special flags may be required
  SET(NA_TEST_${lang}_COMPILE_FLAGS "")
  if("${lang}" STREQUAL "CXX")
    # prevent narrowing
    #SET(NA_TEST_CXX_COMPILE_FLAGS "${NA_TEST_CXX_COMPILE_FLAGS} -fpermissive")
  endif()

  # For coverage testing some special flags are required
  if (NA_COVERAGE_BUILD)
    SET(NA_STD_CMAKE_${lang}_FLAGS "${NA_STD_CMAKE_${lang}_FLAGS} --coverage")
    if("${lang}" STREQUAL "CXX")
      SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} --coverage")
    endif()
  endif(NA_COVERAGE_BUILD)

  # Check if we need special setting for the C library
  libc_default_settings(NA_TEST_${lang}_COMPILE_FLAGS)

  # For external code less restrict flags are required
  SET(NA_EXTERNAL_${lang}_COMPILE_FLAGS "-Wno-deprecated-declarations")
  if("${lang}" STREQUAL "CXX")
    # prevent narrowing
    SET(NA_EXTERNAL_CXX_COMPILE_FLAGS "${NA_EXTERNAL_CXX_COMPILE_FLAGS} -fpermissive")
  endif()
endmacro(gcc_default_settings_4_base lang)

macro(gcc_default_settings_4_4 lang)
  gcc_default_settings_4_base(${lang})
  # Add gcc 4.4 specific switches here
  # #pragma GCC diagnostic push is not supported in GCC < 4.6
  SET(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wno-pragmas")
  if("${lang}" STREQUAL "CXX")
    # get rid of 'the mangling of 'va_list' has changed in GCC 4.4' messages
    SET(NA_STD_CMAKE_${lang}_FLAGS "${NA_STD_CMAKE_${lang}_FLAGS} -Wno-psabi")
    SET(NA_STD_CMAKE_${lang}_FLAGS "${NA_STD_CMAKE_${lang}_FLAGS} -Wno-invalid-offsetof")
  endif()
endmacro(gcc_default_settings_4_4 lang)

macro(gcc_default_settings_4_5 lang)
  gcc_default_settings_4_base(${lang})
  # Add gcc 4.5 specific switches here
  # #pragma GCC diagnostic push is not supported in GCC < 4.6
  SET(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wno-pragmas")
  # logical op warnings like '&&1 always true' doesn't work well on gcc 4.4
  SET(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wlogical-op")
  # In 3rd party code, do not warn about unused function return values
  SET(NA_EXTERNAL_${lang}_COMPILE_FLAGS "${NA_EXTERNAL_${lang}_COMPILE_FLAGS} -Wno-unused-result")
endmacro(gcc_default_settings_4_5 lang)

macro(gcc_default_settings_4_6 lang)
  gcc_default_settings_4_base(${lang})
  # Add gcc 4.6 specific switches here
  # logical op warnings like '&&1 always true' doesn't work well on gcc 4.4
  if(NOT CMAKE_SYSTEM_NAME STREQUAL "QNX")
     # QNX 6.6 with GCC 4.7 is very noisy on BOOST...
     SET(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wlogical-op")
  endif()
  # In 3rd party code, do not warn about unused function return values
  SET(NA_EXTERNAL_${lang}_COMPILE_FLAGS "${NA_EXTERNAL_${lang}_COMPILE_FLAGS} -Wno-unused-result")
  # In 3rd party code, do not display #warning messages
  SET(NA_EXTERNAL_${lang}_COMPILE_FLAGS "${NA_EXTERNAL_${lang}_COMPILE_FLAGS} -Wno-cpp")

  if("${lang}" STREQUAL "CXX" AND NOT DEFINED NA_GCC_CXX_STD)
     # Default C++ mode is 2003 version of standard
     SET(NA_STD_CMAKE_CXX_FLAGS "${NA_STD_CMAKE_CXX_FLAGS} -std=c++03")
     # deactivate const due to false warnings
     #SET(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wsuggest-attribute=const -Wno-error=suggest-attribute=const")
  endif()
endmacro(gcc_default_settings_4_6 ${lang})

macro(gcc_default_settings_4_7 lang)
  gcc_default_settings_4_6(${lang})
  # Add gcc 4.7 specific switches here
  if(NOT CMAKE_SYSTEM_NAME STREQUAL "QNX")
     # QNX 6.6 with GCC 4.7 is very noisy on BOOST...
     SET(NA_TARGET_STRICT_${lang}_COMPILE_FLAGS "${NA_TARGET_STRICT_${lang}_COMPILE_FLAGS} -Wunused-local-typedefs -Wno-error=unused-local-typedefs")
  endif()
endmacro(gcc_default_settings_4_7 lang)

macro(gcc_default_settings_4_8 lang)
  gcc_default_settings_4_7(${lang})
  # Add gcc 4.8 specific switches here
  #  Disable for now due to strange behaviour when debugging.
  #  SET(CMAKE_${lang}_FLAGS_DEBUG "-Og -g") # use new 'optimize for debugging'
endmacro(gcc_default_settings_4_8 lang)

macro(gcc_default_settings_4_9 lang)
  gcc_default_settings_4_8(${lang})
  # Add gcc 4.9 specific switches here
  if("${lang}" STREQUAL "CXX")
     # Use vtable verification
#    SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -fvtable-verify=std")   # vtv_start.o missing :-(
     SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -fdevirtualize")    # avoid vtable call if possible
#    SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -flive-range-shrinkage") # reduce register pressure
     SET(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wdelete-incomplete")    # Warn when deleting a pointer to incomplete type
     # For now disable warnings unused-result
     SET(NA_TARGET_STRICT_${lang}_COMPILE_FLAGS "${NA_TARGET_STRICT_${lang}_COMPILE_FLAGS} -Wno-unused-result")
     # For now disable warnings virtual-move-assign
     SET(NA_TARGET_STRICT_${lang}_COMPILE_FLAGS "${NA_TARGET_STRICT_${lang}_COMPILE_FLAGS} -Wno-error=virtual-move-assign")
     SET(NA_TARGET_STRICT_${lang}_COMPILE_FLAGS "${NA_TARGET_STRICT_${lang}_COMPILE_FLAGS} -Wno-virtual-move-assign")
  endif()
  # For now disable warnings on conversions that reduce the precision of a float value
  SET(NA_TARGET_STRICT_${lang}_COMPILE_FLAGS "${NA_TARGET_STRICT_${lang}_COMPILE_FLAGS} -Wno-float-conversion")
endmacro(gcc_default_settings_4_9 lang)

macro(gcc_default_settings_4_x lang VERSION)
  if(${VERSION} VERSION_LESS "4.4.0")
    MESSAGE(SEND_ERROR "gcc ${VERSION} lang:${lang} not supported")
  elseif(${VERSION} VERSION_LESS "4.5.0")
    gcc_default_settings_4_4(${lang})
  elseif(${VERSION} VERSION_LESS "4.6.0")
    gcc_default_settings_4_5(${lang})
  elseif(${VERSION} VERSION_LESS "4.7.0")
    gcc_default_settings_4_6(${lang})
  elseif(${VERSION} VERSION_LESS "4.8.0")
    gcc_default_settings_4_7(${lang})
  elseif(${VERSION} VERSION_LESS "4.9.0")
    gcc_default_settings_4_8(${lang})
  elseif(${VERSION} VERSION_LESS "4.10.0")
    gcc_default_settings_4_9(${lang})
  else()
    MESSAGE(SEND_ERROR "gcc ${VERSION} lang:${lang} not supported")
  endif()
endmacro(gcc_default_settings_4_x lang)

macro(gcc_default_settings_5_x lang)
  # GCC 5.x is successor of 4.9.x
  gcc_default_settings_4_9(${lang})
  # Add gcc 5.x specific switches here
  SET(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wswitch-bool" ) # warn whenever a switch statement has an index of boolean type.
  SET(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wlogical-not-parentheses") # warn about "logical not" used on the left hand side operand of a comparison.
  SET(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wsizeof-array-argument") # warn when the sizeof operator is applied to a parameter that has been declared as an array in a function definition.
  SET(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wbool-compare") # warn about boolean expressions compared with an integer value different from true/false.
  if("${lang}" STREQUAL "CXX")
     SET(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wodr") # detects mismatches in type definitions and virtual table contents during link-time optimization.

     # gcc 4.8 and 4.9 warn on protobuf generated headers
     SET(NA_TARGET_STRICT_${lang}_COMPILE_FLAGS "${NA_TARGET_STRICT_${lang}_COMPILE_FLAGS} -Wshadow -Wno-error=shadow")
  endif()
endmacro(gcc_default_settings_5_x)

macro(gcc_default_settings_6_x lang)
  # GCC 6.x is successor of 5.x
  gcc_default_settings_5_x(${lang})
  # Add gcc 6.x specific switches here
  SET(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wshift-negative-value") # warns about left shifting a negative value.
  SET(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wshift-overflow")       # warns about left shift overflows. This warning is enabled by default. -Wshift-overflow=2 also warns about left-shifting 1 into the sign bit.
  SET(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wnull-dereference")     # warns if the compiler detects paths that trigger erroneous or undefined behavior due to dereferencing a null pointer. This option is only active when -fdelete-null-pointer-checks is active, which is enabled by optimizations in most targets. The precision of the warnings depends on the optimization options used.
  SET(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wduplicated-cond")      # warns about duplicated conditions in an if-else-if chain.

  if("${lang}" STREQUAL "CXX")
    # ArchLinux workaround
    SET(NA_STD_CMAKE_CXX_FLAGS "${NA_STD_CMAKE_CXX_FLAGS} -Wno-error=narrowing")
    SET(NA_STD_CMAKE_CXX_FLAGS "${NA_STD_CMAKE_CXX_FLAGS} -Wno-error=terminate")
    SET(NA_STD_CMAKE_CXX_FLAGS "${NA_STD_CMAKE_CXX_FLAGS} -Wno-deprecated-declarations")
    SET(NA_STD_CMAKE_CXX_FLAGS "${NA_STD_CMAKE_CXX_FLAGS} -Wno-error=virtual-move-assign")
    SET(NA_STD_CMAKE_CXX_FLAGS "${NA_STD_CMAKE_CXX_FLAGS} -Wno-error=null-dereference")
  endif()
endmacro(gcc_default_settings_6_x)

macro(gcc_default_settings_7_x lang)
  # Workaround for ArchLinux with GCC 7.x
  # QT requires a C++11 compiler, so enforce it
  if(    "${lang}" STREQUAL "CXX"
     AND NOT DEFINED NA_GCC_CXX_STD)
    set(NA_GCC_CXX_STD "-std=c++11")
  endif()

  # GCC 7.x is successor of 6.x
  gcc_default_settings_6_x(${lang})
  # Add gcc 7.x specific switches here
  SET(NA_TARGET_STRICT_${lang}_COMPILE_FLAGS "${NA_TARGET_STRICT_${lang}_COMPILE_FLAGS} -Wimplicit-fallthrough")     # warns when a switch case falls through
  SET(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wpointer-compare")          # warns when a pointer is compared with a zero character constant.
# SET(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wduplicated-branches")      # warns when an if-else has identical branches.
  SET(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wrestrict")                 # warns when an argument passed to a restrict-qualified parameter aliases with another argument.
  SET(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wmemset-elt-size")          # warns for memset calls, when the first argument references an array, and the third argument is a number equal to the number of elements of the array, but not the size of the array.
  SET(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wint-in-bool-context")      # warns about suspicious uses of integer values where boolean values are expected.
  SET(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wswitch-unreachable")       # warns when a switch statement has statements between the controlling expression and the first case label which will never be executed.
  SET(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wexpansion-to-defined")     # warns when defined is used outside #if.
# SET(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wvla-larger-than=100")      # warns about unbounded uses of variable-length arrays, and about bounded uses of variable-length arrays whose bound can be larger than N bytes.
  SET(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wdangling-else")

  if("${lang}" STREQUAL "CXX")
    SET(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wregister")                 # warns about uses of the register storage specifier.
    SET(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Waligned-new")              # warns about new of type with extended alignment without -faligned-new.
  endif()
  if("${lang}" STREQUAL "C")
    SET(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wduplicate-decl-specifier") # warns when a declaration has duplicate const, volatile, restrict or _Atomic specifier.
  endif()
endmacro(gcc_default_settings_7_x)

macro(gcc_default_settings_8_x lang)
	gcc_default_settings_7_x(${lang})
  if("${lang}" STREQUAL "CXX")
    SET(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -fpermissive")
  endif()
endmacro(gcc_default_settings_8_x)

macro(gcc_default_settings_9_x lang)
	gcc_default_settings_8_x(${lang})
  if("${lang}" STREQUAL "CXX")
    SET(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -fpermissive")
  endif()
endmacro(gcc_default_settings_9_x)

macro(na_print_compiler_version)
   execute_process(COMMAND         ${CMAKE_CXX_COMPILER} -dumpversion
                   OUTPUT_VARIABLE CXX_COMPILER_VERSION)
   execute_process(COMMAND         ${CMAKE_C_COMPILER} -dumpversion
                   OUTPUT_VARIABLE C_COMPILER_VERSION)
   STRING(REGEX REPLACE "(\r?\n)+$" "" CXX_COMPILER_VERSION "${CXX_COMPILER_VERSION}")
   STRING(REGEX REPLACE "(\r?\n)+$" "" C_COMPILER_VERSION   "${C_COMPILER_VERSION}"  )
   message(STATUS "C++ compiler executable: ${CMAKE_CXX_COMPILER}")
   message(STATUS "C++ compiler version:    ${CXX_COMPILER_VERSION}  (${CMAKE_CXX_COMPILER_VERSION})")
   message(STATUS "C   compiler executable: ${CMAKE_C_COMPILER}")
   message(STATUS "C   compiler version:    ${C_COMPILER_VERSION}  (${CMAKE_C_COMPILER_VERSION})")
endmacro(na_print_compiler_version)

macro(gcc_default lang VERSION)
# MESSAGE(STATUS "gcc for ${lang} is '${VERSION}'")
  if(${VERSION} VERSION_LESS "4.0.0")
    MESSAGE(SEND_ERROR "gcc ${VERSION} lang:${lang} not supported")
  elseif(${VERSION} VERSION_LESS "5.0.0")
    gcc_default_settings_4_x(${lang} ${VERSION})
  elseif(${VERSION} VERSION_LESS "6.0.0")
    gcc_default_settings_5_x(${lang})
  elseif(${VERSION} VERSION_LESS "7.0.0")
    gcc_default_settings_6_x(${lang})
  elseif(${VERSION} VERSION_LESS "8.0.0")
    gcc_default_settings_7_x(${lang})
  elseif(${VERSION} VERSION_LESS "9.0.0")
    gcc_default_settings_8_x(${lang})
  elseif(${VERSION} VERSION_LESS "10.0.0")
    gcc_default_settings_9_x(${lang})  
  else()
    MESSAGE(SEND_ERROR "gcc ${VERSION} lang:${lang} not supported")
  endif()

  # Extended warnings for special components
  SET(NA_TARGET_STRICT_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} ${NA_TARGET_STRICT_${lang}_COMPILE_FLAGS}")

  SET(CMAKE_${lang}_FLAGS_RELWITHDEBINFO "${CMAKE_${lang}_FLAGS_RELEASE} -g")
endmacro(gcc_default)
