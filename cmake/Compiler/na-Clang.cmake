# This module is shared by multiple languages; use include blocker.
if(na_Clang_INCLUDED)
  return()
endif()
set(na_Clang_INCLUDED 1)

cmake_minimum_required(VERSION 2.8.9)

option(WITH_SANITIZER "Enable runtime sanitizer during compilation" OFF)

INCLUDE(${CMAKE_CURRENT_LIST_DIR}/na-libc.cmake)

# MESSAGE(STATUS "In ${CMAKE_CURRENT_LIST_FILE}")

macro(clang_default_settings_3x lang)
  SET(CMAKE_${lang}_FLAGS_DEBUG "-O0 -g")
  SET(CMAKE_${lang}_FLAGS_RELEASE "-Os")

  # omit temporary files
  SET(NA_STD_CMAKE_${lang}_FLAGS "${CMAKE_${lang}_FLAGS} -pipe")

  # make unqualified char signed
  SET(NA_STD_CMAKE_${lang}_FLAGS "${NA_STD_CMAKE_${lang}_FLAGS} -fsigned-char")

  # need position independent code for qt
  #SET(NA_STD_CMAKE_${lang}_FLAGS "${NA_STD_CMAKE_${lang}_FLAGS} -fPIC")
  SET(CMAKE_POSITION_INDEPENDENT_CODE ON)

  if (WITH_SANITIZER)
    # Turn on additional runtime checks
    # - memory error detector
    # -- Causes lots of link problems, disabled
    #set(SANITIZER_${lang}_FLAGS "-fsanitize=address")

    # - undefined or suspicious integer behavior.
    #set(SANITIZER_${lang}_FLAGS "${SANITIZER_${lang}_FLAGS} -fsanitize=integer")
    #set(SANITIZER_${lang}_FLAGS "${SANITIZER_${lang}_FLAGS} -fsanitize=undefined")

    set(SANITIZER_${lang}_FLAGS "${SANITIZER_${lang}_FLAGS} -fsanitize=alignment") # Use of a misaligned pointer or creation of a misaligned reference.
    set(SANITIZER_${lang}_FLAGS "${SANITIZER_${lang}_FLAGS} -fsanitize=bool")      # Load of a bool value which is neither true nor false.
    set(SANITIZER_${lang}_FLAGS "${SANITIZER_${lang}_FLAGS} -fsanitize=bounds")    # Out of bounds array indexing, in cases where the array bound can be statically determined.
    set(SANITIZER_${lang}_FLAGS "${SANITIZER_${lang}_FLAGS} -fsanitize=enum")      # Load of a value of an enumerated type which is not in the range of representable values for that enumerated type.
  # set(SANITIZER_${lang}_FLAGS "${SANITIZER_${lang}_FLAGS} -fsanitize=float-cast-overflow")  # Conversion to, from, or between floating-point types which would overflow the destination.
    set(SANITIZER_${lang}_FLAGS "${SANITIZER_${lang}_FLAGS} -fsanitize=float-divide-by-zero") # Floating point division by zero.
    set(SANITIZER_${lang}_FLAGS "${SANITIZER_${lang}_FLAGS} -fsanitize=integer-divide-by-zero") # Integer division by zero.
    set(SANITIZER_${lang}_FLAGS "${SANITIZER_${lang}_FLAGS} -fsanitize=null")         # Use of a null pointer or creation of a null reference.
    set(SANITIZER_${lang}_FLAGS "${SANITIZER_${lang}_FLAGS} -fsanitize=object-size")  # An attempt to use bytes which the optimizer can determine are not part of the object being accessed. The sizes of objects are determined using __builtin_object_size, and consequently may be able to detect more problems at higher optimization levels.
    set(SANITIZER_${lang}_FLAGS "${SANITIZER_${lang}_FLAGS} -fsanitize=return")       # In C++, reaching the end of a value-returning function without returning a value.
    set(SANITIZER_${lang}_FLAGS "${SANITIZER_${lang}_FLAGS} -fsanitize=shift")        # Shift operators where the amount shifted is greater or equal to the promoted bit-width of the left hand side or less than zero, or where the left hand side is negative. For a signed left shift, also checks for signed overflow in C, and for unsigned overflow in C++.
  # set(SANITIZER_${lang}_FLAGS "${SANITIZER_${lang}_FLAGS} -fsanitize=signed-integer-overflow") # Signed integer overflow, including all the checks added by -ftrapv, and checking for overflow in signed division (INT_MIN / -1).
    set(SANITIZER_${lang}_FLAGS "${SANITIZER_${lang}_FLAGS} -fsanitize=unreachable")  # If control flow reaches __builtin_unreachable.
  # set(SANITIZER_${lang}_FLAGS "${SANITIZER_${lang}_FLAGS} -fsanitize=unsigned-integer-overflow") # Unsigned integer overflows.
    set(SANITIZER_${lang}_FLAGS "${SANITIZER_${lang}_FLAGS} -fsanitize=vla-bound")    # A variable-length array whose bound does not evaluate to a positive value.
    set(SANITIZER_${lang}_FLAGS "${SANITIZER_${lang}_FLAGS} -fsanitize=vptr")         # Use of an object whose vptr indicates that it is of the wrong dynamic type, or that its lifetime has not begun or has ended. Incompatible with -fno-rtti.
  endif(WITH_SANITIZER)

  # set standard warnings
  set(NA_TARGET_${lang}_COMPILE_FLAGS "-Wall -Wformat -Wformat=2 -Wshadow -Wunused-variable -Werror")

  # Check if we need special setting for the C library
  libc_default_settings(NA_TARGET_${lang}_COMPILE_FLAGS)

  # Enable required POSIX functionality
  # TODO: right place here?
  set(NA_STD_CMAKE_${lang}_FLAGS "${NA_STD_CMAKE_${lang}_FLAGS} -D _POSIX_C_SOURCE=200809L")

  if("${lang}" STREQUAL "C")
    if(DEFINED NA_CLANG_C_STD)
      # Default C mode override from tool chain or command line
      SET(NA_STD_CMAKE_C_FLAGS "${NA_STD_CMAKE_C_FLAGS} ${NA_CLANG_C_STD}")
    else()
      # Default C mode is ISO9899:1999
      set(NA_STD_CMAKE_C_FLAGS "${NA_STD_CMAKE_C_FLAGS} -std=c99")
    endif()
  endif()
  if("${lang}" STREQUAL "CXX")
    if(DEFINED NA_CLANG_CXX_STD)
      # Default C++ mode override from toolchain or command line
      SET(NA_STD_CMAKE_CXX_FLAGS "${NA_STD_CMAKE_CXX_FLAGS} ${NA_CLANG_CXX_STD}")
    else()
      # Default C++ mode is 2003 version of standard
      SET(NA_STD_CMAKE_CXX_FLAGS "${NA_STD_CMAKE_CXX_FLAGS} -std=c++03")
      # we need this libc++ here
      set(NA_STD_CMAKE_${lang}_FLAGS "${NA_STD_CMAKE_${lang}_FLAGS} -stdlib=libstdc++")
    endif()
  endif()

  # Extended warnings for special components
  SET(NA_TARGET_STRICT_${lang}_COMPILE_FLAGS)

  # For test code special flags are required
  SET(NA_TEST_${lang}_COMPILE_FLAGS "")

  # Check if we need special setting for the C library
  libc_default_settings(NA_TEST_${lang}_COMPILE_FLAGS)

  # For external code less restrict flags are required
  # just disable all warnings
  SET(NA_EXTERNAL_${lang}_COMPILE_FLAGS "-w")

  #MESSAGE(STATUS "NA_STD_CMAKE_${lang}_FLAGS ${NA_STD_CMAKE_${lang}_FLAGS}")
endmacro(clang_default_settings_3x)

macro(clang_default_settings_3_0 lang)
  clang_default_settings_3x(${lang})
  # Add clang 3.0 specific switches here
  # - undefined behavior checker (old new argument version)
  set(NA_STD_CMAKE_${lang}_FLAGS "${NA_STD_CMAKE_${lang}_FLAGS} -fcatch-undefined-behavior ")
  # enable bounds checking
  set(NA_STD_CMAKE_${lang}_FLAGS "${NA_STD_CMAKE_${lang}_FLAGS} -fbounds-checking")
endmacro(clang_default_settings_3_0 lang)

macro(clang_default_settings_3_1 lang)
  clang_default_settings_3_0(${lang})
  # Add clang 3.1 specific switches here
endmacro(clang_default_settings_3_1 lang)

macro(clang_default_settings_3_2 lang)
  clang_default_settings_3_1(${lang})
  # Add clang 3.2 specific switches here
endmacro(clang_default_settings_3_2 lang)

macro(clang_default_settings_3_3 lang)
  clang_default_settings_3x(${lang})
  # Add clang 3.3 specific switches here

  if (WITH_SANITIZER)
    # add new switches - undefined behaviour checker
    #set(SANITIZER_${lang}_FLAGS "${SANITIZER_${lang}_FLAGS} -fsanitize=undefined-trap ")
  endif()
  if("${lang}" STREQUAL "CXX")
    set(NA_TARGET_${lang}_COMPILE_FLAGS    "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wheader-hygiene")
  endif()
endmacro(clang_default_settings_3_3 lang)

macro(clang_default_settings_3_4 lang)
  clang_default_settings_3_3(${lang})
  # Add clang 3.4 specific switches here
  set(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wheader-guard")
  set(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wlogical-not-parentheses")
  set(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wdeprecated-increment-bool")
  set(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wloop-analysis")
  set(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wuninitialized")
endmacro(clang_default_settings_3_4 lang)

macro(clang_default_settings_3_5 lang)
  clang_default_settings_3_4(${lang})
  # Add clang 3.5 specific switches here
  set(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wabsolute-value")
  set(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wtautological-pointer-compare")
  set(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wtautological-undefined-compare")
endmacro(clang_default_settings_3_5 lang)

macro(clang_default_settings_3_6 lang)
  clang_default_settings_3_5(${lang})
  # Add clang 3.6 specific switches here
endmacro(clang_default_settings_3_6 lang)

macro(clang_default_settings_3_7 lang)
  clang_default_settings_3_6(${lang})
  # Add clang 3.7 specific switches here
  set(NA_TARGET_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wrange-loop-analysis")

  #if (WITH_SANITIZER AND NA_GNU_HAVE_GOLD)
  #  lots of link problems, disabled
  #  set(SANITIZER_${lang}_FLAGS "${SANITIZER_${lang}_FLAGS} -fsanitize=cfi -fuse-ld=gold -flto")
  #endif()
endmacro(clang_default_settings_3_7 lang)

macro(clang_default_settings_3_8 lang)
  clang_default_settings_3_7(${lang})
  # Add clang 3.8 specific switches here
  if("${lang}" STREQUAL "CXX")
    # Ubuntu 16.04 workaround
    # see https://reviews.llvm.org/D18035 and https://llvm.org/bugs/show_bug.cgi?id=23529
    set(NA_STD_CMAKE_${lang}_FLAGS "${NA_STD_CMAKE_${lang}_FLAGS} -D_GLIBCXX_USE_CXX11_ABI=0")
    # Prevent error messages from boost
    set(NA_TARGET_${lang}_COMPILE_FLAGS    "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wno-unused-local-typedef")
  endif()
endmacro(clang_default_settings_3_8 lang)

macro(clang_default_settings_3_9 lang)
  clang_default_settings_3_7(${lang})
  # Add clang 3.8 specific switches here
  if("${lang}" STREQUAL "CXX")
    # Prevent error messages from boost
#   set(NA_TARGET_${lang}_COMPILE_FLAGS    "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wabstract-vbase-init -Wno-error=abstract-vbase-init")
    set(NA_TARGET_${lang}_COMPILE_FLAGS    "${NA_TARGET_${lang}_COMPILE_FLAGS} -Warray-bounds-pointer-arithmetic")
    set(NA_TARGET_${lang}_COMPILE_FLAGS    "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wassign-enum")
    set(NA_TARGET_${lang}_COMPILE_FLAGS    "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wbad-function-cast")
    set(NA_TARGET_${lang}_COMPILE_FLAGS    "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wc++14-compat-pedantic")
    set(NA_TARGET_${lang}_COMPILE_FLAGS    "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wcomma")
    set(NA_TARGET_${lang}_COMPILE_FLAGS    "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wconditional-uninitialized")
    set(NA_TARGET_${lang}_COMPILE_FLAGS    "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wextended-offsetof")
    set(NA_TARGET_${lang}_COMPILE_FLAGS    "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wflexible-array-extensions")
    set(NA_TARGET_${lang}_COMPILE_FLAGS    "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wfor-loop-analysis")
    set(NA_TARGET_${lang}_COMPILE_FLAGS    "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wgcc-compat")
    set(NA_TARGET_${lang}_COMPILE_FLAGS    "${NA_TARGET_${lang}_COMPILE_FLAGS} -Widiomatic-parentheses")
    set(NA_TARGET_${lang}_COMPILE_FLAGS    "${NA_TARGET_${lang}_COMPILE_FLAGS} -Winfinite-recursion")
    set(NA_TARGET_${lang}_COMPILE_FLAGS    "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wkeyword-macro")
    set(NA_TARGET_${lang}_COMPILE_FLAGS    "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wmethod-signatures")
    set(NA_TARGET_${lang}_COMPILE_FLAGS    "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wmismatched-tags")
    set(NA_TARGET_${lang}_COMPILE_FLAGS    "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wmissing-braces")
    set(NA_TARGET_${lang}_COMPILE_FLAGS    "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wmove")
    set(NA_TARGET_${lang}_COMPILE_FLAGS    "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wover-aligned")
    set(NA_TARGET_${lang}_COMPILE_FLAGS    "${NA_TARGET_${lang}_COMPILE_FLAGS} -Woverloaded-virtual")
    set(NA_TARGET_${lang}_COMPILE_FLAGS    "${NA_TARGET_${lang}_COMPILE_FLAGS} -Woverriding-method-mismatch")
    set(NA_TARGET_${lang}_COMPILE_FLAGS    "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wreorder")
    set(NA_TARGET_${lang}_COMPILE_FLAGS    "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wsemicolon-before-method-body")
    set(NA_TARGET_${lang}_COMPILE_FLAGS    "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wsometimes-uninitialized")
    set(NA_TARGET_${lang}_COMPILE_FLAGS    "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wthread-safety")
    set(NA_TARGET_${lang}_COMPILE_FLAGS    "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wweak-template-vtables")

#    set(NA_TARGET_${lang}_COMPILE_FLAGS    "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wweak-vtables -Wno-error=weak-vtables")
#    set(NA_TARGET_${lang}_COMPILE_FLAGS    "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wglobal-constructors -Wno-error=global-constructors")
#    set(NA_TARGET_${lang}_COMPILE_FLAGS    "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wexit-time-destructors -Wno-error=exit-time-destructors")
#    set(NA_TARGET_${lang}_COMPILE_FLAGS    "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wold-style-cast -Wno-error=old-style-cast")
#    set(NA_TARGET_${lang}_COMPILE_FLAGS    "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wnon-virtual-dtor -Wno-error=non-virtual-dtor")
#    set(NA_TARGET_${lang}_COMPILE_FLAGS    "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wstring-conversion -Wno-error=string-conversion")
#    set(NA_TARGET_${lang}_COMPILE_FLAGS    "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wnewline-eof -Wno-error=newline-eof")
#    set(NA_TARGET_${lang}_COMPILE_FLAGS    "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wshorten-64-to-32 -Wno-error=shorten-64-to-32")
#    set(NA_TARGET_${lang}_COMPILE_FLAGS    "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wswitch-enum -Wno-error=switch-enum")
  endif()
endmacro(clang_default_settings_3_9 lang)

macro(clang_default_settings_4_0 lang)
  clang_default_settings_3_9(${lang})
  set(NA_TARGET_${lang}_COMPILE_FLAGS    "${NA_TARGET_${lang}_COMPILE_FLAGS} -Wno-error=address-of-packed-member")
endmacro(clang_default_settings_4_0 lang)

macro(clang_default lang VERSION)
  if(${VERSION} VERSION_LESS "3.0.0")
    MESSAGE(WARNING "clang ${VERSION} lang:${lang} not supported")
  elseif(${VERSION} VERSION_LESS "3.1.0")
    clang_default_settings_3_0(${lang})
  elseif(${VERSION} VERSION_LESS "3.2.0")
    clang_default_settings_3_1(${lang})
  elseif(${VERSION} VERSION_LESS "3.3.0")
    clang_default_settings_3_2(${lang})
  elseif(${VERSION} VERSION_LESS "3.4.0")
    clang_default_settings_3_3(${lang})
  elseif(${VERSION} VERSION_LESS "3.5.0")
    clang_default_settings_3_4(${lang})
  elseif(${VERSION} VERSION_LESS "3.6.0")
    clang_default_settings_3_5(${lang})
  elseif(${VERSION} VERSION_LESS "3.7.0")
    clang_default_settings_3_6(${lang})
  elseif(${VERSION} VERSION_LESS "3.8.0")
    clang_default_settings_3_7(${lang})
  elseif(${VERSION} VERSION_LESS "3.9.0")
    clang_default_settings_3_8(${lang})
  elseif(${VERSION} VERSION_LESS "3.10.0")
    clang_default_settings_3_9(${lang})
  elseif(${VERSION} VERSION_LESS "4.0.0")
    MESSAGE(WARNING "clang ${VERSION} lang:${lang} not supported")
  elseif(${VERSION} VERSION_LESS "5.0.0")
    clang_default_settings_4_0(${lang})
  else()
    MESSAGE(WARNING "clang ${VERSION} lang:${lang} not supported")
  endif()

  if (WITH_SANITIZER AND SANITIZER_${lang}_FLAGS)
     set(NA_STD_CMAKE_${lang}_FLAGS "${NA_STD_CMAKE_${lang}_FLAGS} ${SANITIZER_${lang}_FLAGS} -DWITH_SANITIZER")
     if("${lang}" STREQUAL "CXX")
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${SANITIZER_${lang}_FLAGS}")
     endif()
  endif()

  # Extended warnings for special components
  SET(NA_TARGET_STRICT_${lang}_COMPILE_FLAGS "${NA_TARGET_${lang}_COMPILE_FLAGS} ${NA_TARGET_STRICT_${lang}_COMPILE_FLAGS}")

# MESSAGE(STATUS "clang for ${lang} is '${VERSION}'")
  STRING(REGEX REPLACE "([0-9]+[.][0-9]+).*" "\\1" CLANG_VERSION "${VERSION}" )
# MESSAGE(STATUS "CLANG_VERSION ${CLANG_VERSION}")
  if(CLANG_VERSION)
#   MESSAGE(STATUS "Loading ${CMAKE_CURRENT_LIST_DIR}/na-clang-${CLANG_VERSION}-${lang}.cmake")
    INCLUDE(${CMAKE_CURRENT_LIST_DIR}/na-clang-${CLANG_VERSION}-${lang}.cmake OPTIONAL)
  endif()
  SET(CMAKE_${lang}_FLAGS_RELWITHDEBINFO "${CMAKE_${lang}_FLAGS_RELEASE} -g")
endmacro(clang_default)
