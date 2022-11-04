# This module is shared by multiple languages; use include blocker.
if(NA-MSVC_INCLUDED)
  return()
endif()
set(NA-MSVC_INCLUDED 1)

#message(STATUS "In ${CMAKE_CURRENT_LIST_FILE}")

if(MSVC14)
   cmake_minimum_required(VERSION 3.4.3)
endif()

#if(NOT CMAKE_SYSTEM_PROCESSOR) # does not work sadly :( is always set to "AMD64" regardless if you specify "-D CMAKE_SYSTEM_PROCESSOR=x86" on the commandline >:(
   set(CMAKE_SYSTEM_PROCESSOR x86)
#endif()

# available in cmake >= 3.7.1 - todo check if that's the proper variable to use here
# corresponds to cmake's "-A" command line option
# https://cmake.org/cmake/help/v3.7/variable/CMAKE_GENERATOR_PLATFORM.html
# https://cmake.org/cmake/help/v3.7/generator/Visual%20Studio%2015%202017.html
if(NOT CMAKE_GENERATOR_PLATFORM)
   set(CMAKE_GENERATOR_PLATFORM "x86")
endif()

# disabled warnings
set(DISABLED_WARNINGS                      "/wd4996") # warning C4996: 'sprintf': This function or variable may be unsafe. Consider using sprintf_s instead. To disable deprecation, use _CRT_SECURE_NO_WARNINGS. See online help for details.
set(DISABLED_WARNINGS "${DISABLED_WARNINGS} /wd4348") # warning C4358: 'type' : redefinition of default parameter : parameter number
set(DISABLED_WARNINGS "${DISABLED_WARNINGS} /wd4351") # warning C4351: new behavior: elements of array 'xyz' will be default initialized
set(DISABLED_WARNINGS "${DISABLED_WARNINGS} /wd4345") # warning C4345: behavior change: an object of POD type constructed with an initializer of the form () will be default-initialized
set(DISABLED_WARNINGS "${DISABLED_WARNINGS} /wd4348") # warning C4348: redefinition of default parameter
set(DISABLED_WARNINGS "${DISABLED_WARNINGS} /wd4355") # warning C4355: 'this' : used in base member initializer list
set(DISABLED_WARNINGS "${DISABLED_WARNINGS} /wd4819") # warning C4819: The file contains a character that cannot be represented in the current code page (936). Save the file in Unicode format to prevent data loss
set(DISABLED_WARNINGS "${DISABLED_WARNINGS} /wd4800") # warning C4800: 'int': forcing value to bool 'true' or 'false' (performance warning)
set(DISABLED_WARNINGS "${DISABLED_WARNINGS} /wd4267") # warning C4267: '=': conversion from 'size_t' to 'uint8_t', possible loss of data
set(DISABLED_WARNINGS "${DISABLED_WARNINGS} /wd4244") # warning C4244: '=': conversion from 'float' to 'int32_t', possible loss of data

if(MSVC14) # Visual Studio 2015
   # C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\include\hash_map:
   #   <hash_map> is deprecated and will be REMOVED. Please use <unordered_map>
   #   <hash_set> is deprecated and will be REMOVED. Please use <unordered_set>
   set(DISABLED_WARNINGS "${DISABLED_WARNINGS} /D_SILENCE_STDEXT_HASH_DEPRECATION_WARNINGS")
endif()   

# set standard warnings
set(NA_TARGET_C_COMPILE_FLAGS   "/WX ${DISABLED_WARNINGS}")
set(NA_TARGET_C_COMPILE_FLAGS   "${NA_TARGET_C_COMPILE_FLAGS} /DNOAPISET")        # prevent Windows headers from creating #define GetTimeFormat
set(NA_TARGET_CXX_COMPILE_FLAGS "${NA_TARGET_C_COMPILE_FLAGS}")

# Extended warnings for special components
set(NA_TARGET_STRICT_C_COMPILE_FLAGS   "${NA_TARGET_C_COMPILE_FLAGS}")
set(NA_TARGET_STRICT_CXX_COMPILE_FLAGS "${NA_TARGET_CXX_COMPILE_FLAGS}")

# default compile switches
set(ADDITIONAL_FLAGS                     "/errorReport:none"    ) # do not send error reports to Microsoft
set(ADDITIONAL_FLAGS "${ADDITIONAL_FLAGS} /DNOMINMAX"           ) # prevent MSVC headers from creating #defines for min, max which clash with std::min, std::max
set(ADDITIONAL_FLAGS "${ADDITIONAL_FLAGS} /DWIN32_LEAN_AND_MEAN") # speed up compilation of <windows.h>
                                                                  # http://stackoverflow.com/questions/11040133/what-does-defining-win32-lean-and-mean-exclude-exactly
                                                                  # https://support.microsoft.com/en-us/kb/166474
set(ADDITIONAL_FLAGS "${ADDITIONAL_FLAGS} /D_WIN32_WINNT=0x0601") # we support no windows.h API older than Windows 7 https://msdn.microsoft.com/en-us/library/6sehtctf.aspx

if (USE_MULTIPLE_PROCESSORS)
   set(ADDITIONAL_FLAGS "${ADDITIONAL_FLAGS} /MP"               ) # use multiple CPU cores for compiling https://msdn.microsoft.com/en-us/library/bb385193.aspx - currently commented out because some developer machines this way run out of memory
endif()

set(NA_STD_CMAKE_C_FLAGS   "${CMAKE_C_FLAGS} ${ADDITIONAL_FLAGS}"  )
set(NA_STD_CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${ADDITIONAL_FLAGS}")

# external code warnings disabling for: C
set(NA_EXTERNAL_C_COMPILE_FLAGS "/W1 ${DISABLED_WARNINGS}")
set(NA_EXTERNAL_C_COMPILE_FLAGS "${NA_EXTERNAL_C_COMPILE_FLAGS} /wd4018")                      # warning C4018: signed/unsigned mismatch
set(NA_EXTERNAL_C_COMPILE_FLAGS "${NA_EXTERNAL_C_COMPILE_FLAGS} /wd4244")                      # warning C4244: conversion from 'x' to 'y', possible loss of data
set(NA_EXTERNAL_C_COMPILE_FLAGS "${NA_EXTERNAL_C_COMPILE_FLAGS} /wd4800")                      # warning C4800: forcing value to bool 'true' or 'false' (performance warning)
set(NA_EXTERNAL_C_COMPILE_FLAGS "${NA_EXTERNAL_C_COMPILE_FLAGS} /wd4506")                      # warning C4506: no definition for inline function 'function'
if(MSVC14)
   set(NA_EXTERNAL_C_COMPILE_FLAGS "${NA_EXTERNAL_C_COMPILE_FLAGS} /wd4838")                   # warning C4838: conversion from 'unsigned int' to 'int' requires a narrowing conversion 
endif()

# external code warnings disabling for: C++
set(NA_EXTERNAL_CXX_COMPILE_FLAGS "${NA_EXTERNAL_C_COMPILE_FLAGS}")
set(NA_EXTERNAL_CXX_COMPILE_FLAGS "${NA_EXTERNAL_CXX_COMPILE_FLAGS} /wd4722")                  # warning C4722: destructor never returns, potential memory leak
if(MSVC14)
   set(NA_EXTERNAL_CXX_COMPILE_FLAGS "${NA_EXTERNAL_CXX_COMPILE_FLAGS} /Zc:implicitNoexcept-") # https://msdn.microsoft.com/en-us/library/dn818588.aspx
endif()

# For test code special flags are required
set(NA_TEST_C_COMPILE_FLAGS "/EHa ${DISABLED_WARNINGS}")
set(NA_TEST_CXX_COMPILE_FLAGS "${NA_TEST_C_COMPILE_FLAGS}")

# Find suitable Windows Platform SDK.
# Recently, Microsoft played variations on that name, they first changed it to "Microsoft SDK", and now to "Windows Kit".
# https://en.wikipedia.org/wiki/Microsoft_Windows_SDK
if((NOT WindowsSDK) OR (WindowsSDK STREQUAL WindowsSDK-NOTFOUND))

   if(MSVC12 OR MSVC14 OR MSVC15) # Visual Studio 12,14,15 (note that 13 doesn't exist for avoiding bad luck) ---> Windows Kit 8.1 
   
      find_path(WindowsSDK    SDKManifest.xml
                HINTS ENV     "ProgramFiles"
                      ENV     "ProgramFiles(x86)"
                PATH_SUFFIXES "Windows Kits/8.1"
                DOC           "installation location of Windows Kit 8.1, e.g. C:/Program Files (x86)/Windows Kits/8.1")
      if(NOT WindowsSDK OR (WindowsSDK STREQUAL WindowsSDK-NOTFOUND))
         message(FATAL_ERROR "cannot find Windows Kit 8.1")
      endif()         
      find_path(WindowsSDK_LibraryPath user32.lib
                HINTS                  ${WindowsSDK}
                PATH_SUFFIXES          "Lib/winv6.3/um/${CMAKE_GENERATOR_PLATFORM}"
                DOC                    "installation location of Windows Kit 8.1 libraries")
      if(NOT WindowsSDK_LibraryPath OR (WindowsSDK_LibraryPath STREQUAL WindowsSDK_LibraryPath-NOTFOUND))
         message(FATAL_ERROR "cannot find Windows Kit 8.1 libraries")
      endif()              

   elseif(MSVC11) # Visual Studio 11 ---> Windows Kit 8.0     

      find_path(WindowsSDK    SDKManifest.xml
                HINTS ENV     "ProgramFiles"
                      ENV     "ProgramFiles(x86)"
                PATH_SUFFIXES "Windows Kits/8.0"
                DOC           "installation location of Windows Kit 8.1, e.g. C:/Program Files (x86)/Windows Kits/8.0")
      if(NOT WindowsSDK OR (WindowsSDK STREQUAL WindowsSDK-NOTFOUND))
         message(FATAL_ERROR "cannot find Windows Kit 8.0")
      endif()         
      find_path(WindowsSDK_LibraryPath user32.lib
                HINTS                  ${WindowsSDK}                
                PATH_SUFFIXES          "Lib/win8/um/${CMAKE_GENERATOR_PLATFORM}"
                DOC                    "installation location of Windows Kit 8.0 libraries")
      if(NOT WindowsSDK_LibraryPath OR (WindowsSDK_LibraryPath STREQUAL WindowsSDK_LibraryPath-NOTFOUND))
         message(FATAL_ERROR "cannot find Windows Kit 8.0 libraries")
      endif()
	  
   elseif(MSVC10) # Visual Studio 10 ---> Microsoft SDK Windows 7.x
   
      find_path(WindowsSDK    Bin/CertMgr.Exe
                HINTS ENV     "ProgramFiles"
                      ENV     "ProgramFiles(x86)"
                PATH_SUFFIXES "Microsoft SDKs/Windows/v7.1A"
                              "Microsoft SDKs/Windows/v7.1"
                              "Microsoft SDKs/Windows/v7.0A"
                              "Microsoft SDKs/Windows/v7.0"
                DOC           "installation location of Windows Kit 7.x, e.g. C:/Program Files (x86)/Microsoft SDKs/Windows/v7.1A")
      if(NOT WindowsSDK OR (WindowsSDK STREQUAL WindowsSDK-NOTFOUND))
         message(FATAL_ERROR "cannot find Windows Kit 7.x")
      endif()         
      if(${CMAKE_GENERATOR_PLATFORM} STREQUAL "x86")	  
         set(WindowsSDK_LibraryPath "${WindowsSDK}/Lib"     CACHE PATH "installation location of Windows Kit 7.x x86 libraries")
      elseif(${CMAKE_GENERATOR_PLATFORM} STREQUAL "x64")
         set(WindowsSDK_LibraryPath "${WindowsSDK}/Lib/x64" CACHE PATH "installation location of Windows Kit 7.x x64 libraries")
      else()
         message(FATAL_ERROR "Unsupported value of CMAKE_GENERATOR_PLATFORM=${CMAKE_GENERATOR_PLATFORM}")
      endif()
	  
   else()
   
      message(FATAL_ERROR "Unknown Visual Studio version. Extend file na-MSVC.cmake to support it.")
	  
   endif()
endif()

if(MSVC10)
   include_directories( SYSTEM "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Compiler/msvc/vs10/include")
endif()

message(STATUS "Found Microsoft Windows Platform SDK (aka Windows Kit): ${WindowsSDK}")

set(WindowsSDK_IncludePath "${WindowsSDK}/Include" CACHE PATH "installation location of Windows Kit header files")

set(CMAKE_INCLUDE_PATH ${WindowsSDK_IncludePath})
set(CMAKE_LIBRARY_PATH ${WindowsSDK_LibraryPath})

# ignore warning LNK4221: This object file does not define any previously undefined public symbols, so it will not be used by any link operation that consumes this library
set(CMAKE_EXE_LINKER_FLAGS       "${CMAKE_EXE_LINKER_FLAGS} /ignore:4221")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} /ignore:4221")
set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} /ignore:4221")
set(CMAKE_STATIC_LINKER_FLAGS "${CMAKE_STATIC_LINKER_FLAGS} /ignore:4221")

# do not send error reports to Microsoft
# https://msdn.microsoft.com/en-us/library/ms235602.aspx
set(CMAKE_EXE_LINKER_FLAGS       "${CMAKE_EXE_LINKER_FLAGS} /errorReport:none")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} /errorReport:none")
set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} /errorReport:none")
set(CMAKE_STATIC_LINKER_FLAGS "${CMAKE_STATIC_LINKER_FLAGS} /errorReport:none")

if(CMAKE_BUILD_TYPE STREQUAL "Release")

   set(CMAKE_EXE_LINKER_FLAGS       "${CMAKE_EXE_LINKER_FLAGS} /nodefaultlib:msvcrtd.lib")
   set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} /nodefaultlib:msvcrtd.lib")
   set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} /nodefaultlib:msvcrtd.lib")

elseif(CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo")
   
   set(CMAKE_EXE_LINKER_FLAGS       "${CMAKE_EXE_LINKER_FLAGS} /nodefaultlib:msvcrtd.lib")
   set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} /nodefaultlib:msvcrtd.lib")
   set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} /nodefaultlib:msvcrtd.lib")

   if(MSVC10 OR MSVC11 OR MSVC12)
      # old versions don't have option /Debug:FASTLINK"
   else()
      # https://blogs.msdn.microsoft.com/vcblog/2015/10/16/debugfastlink-for-vs2015-update-1
      # https://blogs.msdn.microsoft.com/vcblog/2014/11/12/speeding-up-the-incremental-developer-build-scenario/
      set(CMAKE_EXE_LINKER_FLAGS       "${CMAKE_EXE_LINKER_FLAGS} /INCREMENTAL /Debug:FASTLINK")
      set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} /INCREMENTAL /Debug:FASTLINK")
      set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} /INCREMENTAL /Debug:FASTLINK")     
   endif()

elseif(CMAKE_BUILD_TYPE STREQUAL "Debug")

   set(CMAKE_EXE_LINKER_FLAGS       "${CMAKE_EXE_LINKER_FLAGS} /nodefaultlib:msvcrt.lib")
   set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} /nodefaultlib:msvcrt.lib")
   set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} /nodefaultlib:msvcrt.lib")

   if(MSVC10 OR MSVC11 OR MSVC12)
      # old versions don't have option /Debug:FASTLINK"
   else()
      # https://blogs.msdn.microsoft.com/vcblog/2015/10/16/debugfastlink-for-vs2015-update-1
      # https://blogs.msdn.microsoft.com/vcblog/2014/11/12/speeding-up-the-incremental-developer-build-scenario/
      set(CMAKE_EXE_LINKER_FLAGS       "${CMAKE_EXE_LINKER_FLAGS} /INCREMENTAL /Debug:FASTLINK")
      set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} /INCREMENTAL /Debug:FASTLINK")
      set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} /INCREMENTAL /Debug:FASTLINK")     
   endif()

else()
   message(FATAL_ERROR "Unknown CMAKE_BUILD_TYPE")
endif()
