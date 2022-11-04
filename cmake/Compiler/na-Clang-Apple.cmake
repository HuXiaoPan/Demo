# This module is shared by multiple languages; use include blocker.
if(na_Clang_Apple_INCLUDED)
  return()
endif()
set(na_Clang_Apple_INCLUDED 1)

MESSAGE(STATUS "In ${CMAKE_CURRENT_LIST_FILE}")

macro(clang_apple_default_settings_5x lang)
  if (IOS)
	# SET(CMAKE_${lang}_FLAGS_DEBUG "-O0 -g -mno-thumb")
   # not used for 64 bit build
	SET(CMAKE_${lang}_FLAGS_DEBUG "-O0 -g")
  else()
	SET(CMAKE_${lang}_FLAGS_DEBUG "-O0 -g")
  endif()
  SET(CMAKE_${lang}_FLAGS_RELEASE "-Os")

  # omit temporary files
  SET(CMAKE_${lang}_FLAGS "${CMAKE_${lang}_FLAGS} -pipe")

  # make unqualified char signed
  SET(CMAKE_${lang}_FLAGS "${CMAKE_${lang}_FLAGS} -fsigned-char")

  # Turn on additional runtime checks
  # - memory error detector (old and new argument version)
  set(CMAKE_${lang}_FLAGS "${CMAKE_${lang}_FLAGS} -fsanitize=address -faddress-sanitizer")
  # - undefined or suspicious integer behaviour.
  set(CMAKE_${lang}_FLAGS "${CMAKE_${lang}_FLAGS} -fsanitize=integer")
  # add new switches - bounds-checking
  set(CMAKE_${lang}_FLAGS "${CMAKE_${lang}_FLAGS} -fsanitize=bounds")

  set(CMAKE_${lang}_FLAGS "${CMAKE_${lang}_FLAGS} -fsanitize=undefined-trap")
  set(CMAKE_${lang}_FLAGS "${CMAKE_${lang}_FLAGS} -fsanitize-undefined-trap-on-error")

  # set standard warnings
  SET(CMAKE_${lang}_FLAGS "${CMAKE_${lang}_FLAGS} -Wall") # Currently -Werror is omitted
  SET(CMAKE_${lang}_FLAGS "${CMAKE_${lang}_FLAGS} -Wformat -Wformat=2 -Wno-error=format-nonliteral")
  SET(CMAKE_${lang}_FLAGS "${CMAKE_${lang}_FLAGS} -Wshadow -Wunused-variable")

  set(CMAKE_${lang}_FLAGS "-Wno-header-guard")

  if("${lang}" STREQUAL "CXX")
    # Default C++ mode is 2003 version of standard
    # Note: this may cause a warning when clang linker is called, Qt 5.7 needs c++11 support
    set(CMAKE_${lang}_FLAGS "${CMAKE_${lang}_FLAGS} -std=c++11")
    # check-new is only for c++
    set(CMAKE_${lang}_FLAGS "${CMAKE_${lang}_FLAGS} -fcheck-new")
    # prevent narrowing
    set(CMAKE_${lang}_FLAGS "${CMAKE_${lang}_FLAGS} -fpermissive")
    # we need this libc++ here
    set(CMAKE_${lang}_FLAGS "${CMAKE_${lang}_FLAGS} -stdlib=libc++")
  endif()

  # For test code special flags are required
  SET(NA_TEST_COMPILE_FLAGS "-Wno-shadow -Wno-format-nonliteral")
endmacro(clang_apple_default_settings_5x)

macro(clang_apple_default_settings_5_1 lang)
  clang_apple_default_settings_5x(${lang})

  # Add 5.1 specific switches here
endmacro(clang_apple_default_settings_5_1 lang)

macro(clang_apple_default_settings_7_3 lang)
  clang_apple_default_settings_5x(${lang})
endmacro(clang_apple_default_settings_7_3 lang)

macro(clang_apple_default_settings_8_0 lang)
  clang_apple_default_settings_5x(${lang})
endmacro(clang_apple_default_settings_8_0 lang)

macro(clang_apple_default lang VERSION)
  if(${VERSION} VERSION_LESS "5.1.0")
    MESSAGE(WARNING "clang-apple ${VERSION} lang:${lang} not supported")
  elseif(${VERSION} VERSION_LESS "5.2.0")
    clang_apple_default_settings_5_1(${lang})
  elseif(${VERSION} VERSION_LESS "7.4.0")
    clang_apple_default_settings_7_3(${lang})
  elseif(${VERSION} VERSION_LESS "9.0.0")
    clang_apple_default_settings_8_0(${lang})
  else()
    MESSAGE(WARNING "clang-apple ${VERSION} lang:${lang} not supported")
  endif()

  STRING(REGEX REPLACE "([0-9]+[.][0-9]+).*" "\\1" CLANG_APPLE_VERSION "${VERSION}" )
  MESSAGE(STATUS "CLANG_APPLE_VERSION ${CLANG_APPLE_VERSION}")
  if(CLANG_APPLE_VERSION)
#   MESSAGE(STATUS "Loading ${CMAKE_CURRENT_LIST_DIR}/na-clang-apple-${CLANG_APPLE_VERSION}-${lang}.cmake")
    INCLUDE(${CMAKE_CURRENT_LIST_DIR}/na-clang-apple-${CLANG_APPLE_VERSION}-${lang}.cmake OPTIONAL)
  endif()
endmacro(clang_apple_default)
