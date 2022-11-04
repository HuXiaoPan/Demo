# - AndroidSDK
# This module looks for the Android SDK and additional subcomponents.
# This code sets the following variables:
#
#  ANDROID_SDK                  = the full path to the Android SDK installation
#  ANDROID_SDK_API_LEVEL        = a supported API version;
#                                 if not supplied by user, ${ANDROID_SDK} will be searched for
#                                 supported API version greater or equal ${ANDROID_SDK_MIN_API_LEVEL}
#  ANDROID_JAR                  = the full path to the Android JAR library;
#                                 if not supplied by user, the value will be constructed based on
#                                 ${ANDROID_SDK} and ${ANDROID_SDK_API_LEVEL}
#  GOOGLE_PLAY_SERVICES_JAR     = the full path to the Google Play Services JAR libaray (optional);
#                                 if not supplied by user, the script will try to locate this
#                                 library in ${ANDROID_SDK}
#  GOOGLE_PLAY_SERVICES_VERSION = version of the found Google Play Services
#
# The behavior of this script can be altered by overriding any of these
# variables using the "-D<name>=<value>" syntax on the CMake command line. Also, the
# following variables can be used to control the script:
#
#  ANDROID_SDK_MIN_API_LEVEL        = minimum expected API level (default: 1)
#  GOOGLE_PLAY_SERVICES_MIN_VERSION = minimum expected Google Play Services Version

# make sure that JAVA is searched in the host system, not the target sysroot
set( OLD_CMAKE_FIND_ROOT_PATH_MODE_PROGRAM "${CMAKE_FIND_ROOT_PATH_MODE_PROGRAM}")
  set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER )
  find_package(Java COMPONENTS Development REQUIRED)
set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM "${OLD_CMAKE_FIND_ROOT_PATH_MODE_PROGRAM}")
unset( OLD_CMAKE_FIND_ROOT_PATH_MODE_PROGRAM)

if( NOT DEFINED ANDROID_SDK)
  # try to find ANDROID SDK
  if( DEFINED ENV{ANDROID_SDK})
#    message( "found environment variable: $ENV{ANDROID_SDK}")
    set( ANDROID_SDK ENV{ANDROID_SDK})
  else()
#    message( "no ANDROID_SDK set from outside")

    set( __candidates "android-sdk" "android-studio/sdk")

    if(CMAKE_HOST_WIN32)
      set( __search_paths "$ENV{ProgramFiles}/Android" "$ENV{ProgramFiles(x86)}/Android" "$ENV{ProgramW6432}/Android" "C:/Android" "D:/Android")
      set( __adb_path "platform-tools/adb.exe")
    else()
      set( __search_paths "/opt" ENV{HOME})
      set( __adb_path "platform-tools/adb")
      list( APPEND __candidates "android-sdk-linux")
    endif()

#    message( "__search_paths : ${__search_paths}")

    foreach( __search_path ${__search_paths})
      foreach( __candidate ${__candidates})
        if( EXISTS "${__search_path}/${__candidate}/${__adb_path}")
#          message( STATUS "found Android SDK: ${__search_path}/${__candidate}")
          set( ANDROID_SDK ${__search_path}/${__candidate})
          break()
        endif()
      endforeach()
      if( DEFINED ANDROID_SDK)
        break()
      endif()
    endforeach()

    unset( __candidate)
    unset( __search_path)
    unset( __candidates)
    unset( __adb_path)
    unset( __search_paths)
  endif()
endif()

if( DEFINED ANDROID_SDK)
  set( ANDROID_SDK "${ANDROID_SDK}" CACHE PATH "path to Android SDK install root")
  unset( ANDROID_SDK)
endif()

if( NOT DEFINED ANDROID_SDK_MIN_API_LEVEL)
  set( ANDROID_SDK_MIN_API_LEVEL 1)
endif()

if( DEFINED ANDROID_SDK)
  set( __playServicesRepoPath "${ANDROID_SDK}/extras/google/m2repository/com/google/android/gms/play-services")

  if( NOT DEFINED ANDROID_SDK_API_LEVEL)
    # figure out best match API level
    foreach( __api_level RANGE ${ANDROID_SDK_MIN_API_LEVEL} 99)
      if( EXISTS "${ANDROID_SDK}/platforms/android-${__api_level}")
        message( STATUS "Found Android SDK API level ${__api_level}")
        set( ANDROID_SDK_API_LEVEL ${__api_level})
        break()
      else()
        message( "API level ${__api_level} does not exist")
      endif()
    endforeach()
    unset( __api_level)
    unset( __supported_sdk_versions)
  endif()
  if( DEFINED ANDROID_SDK_API_LEVEL)
    set( ANDROID_SDK_API_LEVEL "${ANDROID_SDK_API_LEVEL}" CACHE STRING "Android API version")
  endif()

  if( DEFINED ANDROID_SDK_API_LEVEL)
    find_file( ANDROID_JAR "android.jar"
               HINTS "${ANDROID_SDK}/platforms/android-${ANDROID_SDK_API_LEVEL}"
               DOC "android.jar file"
               NO_CMAKE_FIND_ROOT_PATH)
  endif()

	set( GOOGLE_PLAY_SERVICES_JAR "${ANDROID_SDK}/extras/google/google_play_services/google-play-services-16.0.0.jar")

  if(     NOT DEFINED GOOGLE_PLAY_SERVICES_VERSION
      AND NOT DEFINED GOOGLE_PLAY_SERVICES_JAR
      AND     DEFINED GOOGLE_PLAY_SERVICES_MIN_VERSION)
    if(NOT EXISTS "${__playServicesRepoPath}")
      message( FATAL_ERROR "Google Repository '${__playServicesRepoPath}' not found! Please install or specify GOOGLE_PLAY_SERVICES_JAR manually")
    endif()
    file(GLOB __playServicesCandidates IN "${__playServicesRepoPath}/*/play-services-*.aar")

    set( __playServicesBestMatchVersion "99.99.99")

    foreach( __playServicesCandidate ${__playServicesCandidates})
      string( REGEX REPLACE "^.+\\/play-services-(.+)\\.aar$" "\\1" __playServicesCandidateVersion ${__playServicesCandidate})

      if( __playServicesCandidateVersion VERSION_LESS GOOGLE_PLAY_SERVICES_MIN_VERSION )
        #message( "skipping Google Play Services version ${__playServicesCandidateVersion}")
      elseif( __playServicesCandidateVersion VERSION_LESS __playServicesBestMatchVersion)
        #message( "found suitable version ${__playServicesCandidateVersion}")
        set( __playServicesBestMatchVersion "${__playServicesCandidateVersion}")
      else()
        #message( "skipping Google Play Services version ${__playServicesCandidateVersion}")
      endif()
    endforeach()

    if( __playServicesBestMatchVersion VERSION_LESS "99.99.99")
      message( STATUS "found Google Play Services version ${__playServicesBestMatchVersion}")
      set( GOOGLE_PLAY_SERVICES_VERSION "${__playServicesBestMatchVersion}" CACHE STRING "Google Play Services Version")
    else()
      message( WARNING "no suitable Google Play Services version found")
    endif()

    unset( __playServicesBestMatchVersion)
    unset( __playServicesCandidateVersion)
    unset( __playServicesCandidate)
    unset( __playServicesCandidates)

    if( NOT DEFINED GOOGLE_PLAY_SERVICES_VERSION)
      message( FATAL_ERROR "No suitable Google Play Services version found")
    endif()
  endif()

  if( DEFINED GOOGLE_PLAY_SERVICES_VERSION)
    set( __playServicesArchive
         "${__playServicesRepoPath}/${GOOGLE_PLAY_SERVICES_VERSION}/play-services-${GOOGLE_PLAY_SERVICES_VERSION}.aar")
    set( __playServicesDefaultJar "${CMAKE_BINARY_DIR}/play-services-${GOOGLE_PLAY_SERVICES_VERSION}.jar")
    set( GOOGLE_PLAY_SERVICES_JAR "${__playServicesDefaultJar}" CACHE FILE "google-play-services.jar file")
    if ( GOOGLE_PLAY_SERVICES_JAR STREQUAL __playServicesDefaultJar)
      # okay, we assume that the jar path was not configured manually
      if( NOT EXISTS "${GOOGLE_PLAY_SERVICES_JAR}")
        # extract
        execute_process( COMMAND            "${Java_JAR_EXECUTABLE}" xf "${__playServicesArchive}" classes.jar
                         WORKING_DIRECTORY  "${CMAKE_BINARY_DIR}"
                         RESULT_VARIABLE    __extractionProcess)
        if(NOT __extractionProcess EQUAL 0)
          message( FATAL_ERROR "failed to extract classes from ${__playServicesArchive}")
        else()
          file(RENAME "${CMAKE_BINARY_DIR}/classes.jar" "${GOOGLE_PLAY_SERVICES_JAR}")
        endif()
      endif()
    endif()
    unset( __playServicesDefaultJar)
    unset( __playServicesArchive)
  endif()

  unset( __playServicesRepoPath)
endif()

#message( "ANDROID_SDK : ${ANDROID_SDK}")
#message( "ANDROID_SDK_API_LEVEL : ${ANDROID_SDK_API_LEVEL}")
#message( "ANDROID_SDK_MIN_API_LEVEL : ${ANDROID_SDK_MIN_API_LEVEL}")
#message( "ANDROID_JAR : ${ANDROID_JAR}")
#message( "GOOGLE_PLAY_SERVICES_JAR : ${GOOGLE_PLAY_SERVICES_JAR}")

find_package_handle_standard_args(AndroidSDK
                                  REQUIRED_VARS ANDROID_SDK ANDROID_SDK_API_LEVEL ANDROID_JAR)
