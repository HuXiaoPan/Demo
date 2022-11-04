# - Flite
# Flite (festival-lite) is a small, fast run-time synthesis engine developed at CMU and primarily
# designed for small embedded machines and/or large servers.
#
# This module looks for flite and relative header file and libraries.
# The flite interface will be called by TTS engine to make voice driving recommendation.
#
# Flite work need the following libraries:
# libflite.so
# libflite_usenglish.so
# libflite_cmu_us_kal.so
# libflite_cmu_us_slt.so
# libflite_cmulex.so
# libm.so
# libssound.so
#
# Usage Example:
# --------------------------------------------------------------------------------
# First, add definiation and include directories in CMakeList.
# if(USE_FLITE)
#   add_definitions("-DUSE_FLITE")
#   find_package(Flite REQUIRED)
#   if(FLITE_FOUND)
#      include_directories(SYSTEM ${FLITE_INCLUDE_DIR})
#   endif()
# endif()
#
# Second, include flite header file in source code with.
# #ifdef USE_FLITE
# #include <flite.h>
# #endif !USE_FLITE
#
# Third, link flite libraries.
# if(USE_FLITE)
#    target_link_libraries(flite_test ${FLITE_LIBRARIES})
# endif()
#
#=============================================================================
# Flite_VERSION        - the version info of flite.
# FLITE_INCLUDE_DIR    - the directory of flite header files.
# FLITE_LIB            - the path value of libflite.so.
# FLITE_USENGLISH_LIB  - the path value of libflite_usenglish.so.
# FLITE_CMU_US_KAL_LIB - the path value of libflite_cmu_us_kal.so.
# FLITE_CMU_US_SLT_LIB - the path value of libflite_cmu_us_slt.so.
# FLITE_CMULEX_LIB     - the path value of libflite_cmulex.so.
# FLITE_M_LIB          - the path value of libm.so.
# FLITE_ASOUND_LIB     - the path value of libssound.so.
# FLITE_FOUND          - If flite found and ready for using.
# FLITE_LIBRARIES      - all flite necessary libraries.
#=============================================================================
# More information about Flite: http://www.speech.cs.cmu.edu/flite/
#=============================================================================

cmake_minimum_required(VERSION 2.8)

#set flite version as we use flite 1.4-release.
SET( Flite_VERSION 1.4.0 )

#find flite header file directories.
find_path( FLITE_INCLUDE_DIR NAMES flite.h PATHS /usr/include)

#find all flite necessary libraries.
find_library( FLITE_LIB NAMES flite PATHS /usr/lib)
find_library( FLITE_USENGLISH_LIB NAMES flite_usenglish PATHS /usr/lib)
find_library( FLITE_CMU_US_KAL_LIB NAMES flite_cmu_us_kal PATHS /usr/lib)
find_library( FLITE_CMU_US_SLT_LIB NAMES flite_cmu_us_slt PATHS /usr/lib)
find_library( FLITE_CMULEX_LIB NAMES flite_cmulex PATHS /usr/lib)
find_library( FLITE_M_LIB NAMES m PATHS /usr/lib)
find_library( FLITE_ASOUND_LIB NAMES asound PATHS /usr/lib)

#check header file and libraries status.
include(FindPackageHandleStandardArgs)
find_package_handle_standard_ARGS(Flite DEFAULT_MSG
            FLITE_LIB
            FLITE_USENGLISH_LIB
            FLITE_CMU_US_KAL_LIB
            FLITE_CMU_US_SLT_LIB
            FLITE_CMULEX_LIB
            FLITE_M_LIB
            FLITE_ASOUND_LIB
            FLITE_INCLUDE_DIR
            Flite_VERSION)

if (FLITE_FOUND)
   #set FLITE_LIBRARIES for target link.
   set( FLITE_LIBRARIES
        ${FLITE_LIB}
        ${FLITE_USENGLISH_LIB}
        ${FLITE_CMU_US_KAL_LIB}
        ${FLITE_CMU_US_SLT_LIB}
        ${FLITE_CMULEX_LIB}
        ${FLITE_M_LIB}
        ${FLITE_ASOUND_LIB})
endif()



