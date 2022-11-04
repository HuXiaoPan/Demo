@echo off
color


echo This file is prototypical only currently. It runs a cmake build for Android.
echo See http://ntswiki.easydrivetech.com/wiki/Setting_up_the_Android_Build_Environment_for_BCore for more information.
echo Open it and adjust the ..._HOME variables to your local machine and disable this blocker message.
echo In future, this will be made much more elegant, for example this file could become a perl script,
echo and the ..._HOME variables could be taken from your global environment.
echo And this file should be merged with the existing run_cmake.pl probably.
echo This program will exit now.
pause
goto :eof


set        JAVA_HOME=C:\Program Files (x86)\Java\jdk1.7.0_79
set       CMAKE_HOME=C:\Program Files (x86)\CMake 2.8
set       MINGW_HOME=E:\MinGW
set          QT_HOME=E:\Qt\Qt5.3.1\5.3\android_armv7
set ANDROID_NDK_HOME=E:\android-ndk-r10
set ANDROID_SDK_HOME=%LOCALAPPDATA%\Android\android-studio\sdk

set     BUILD_FOLDER=edna-build-android


rem --- no customization necessary from here on --------------------------------------------------------------------------------------


if not exist "%JAVA_HOME%" (
   echo JAVA_HOME does not point to a valid Java installation: "%JAVA_HOME%"
   pause
   goto :eof
)

if not exist "%CMAKE_HOME%" (
   echo CMAKE_HOME does not point to a valid CMake installation: "%CMAKE_HOME%"
   pause
   goto :eof
)

if not exist "%MINGW_HOME%" (
   echo MINGW_HOME does not point to a valid MinGW installation: "%MINGW_HOME%"
   pause
   goto :eof
)

if not exist "%QT_HOME%" (
   echo QT_HOME does not point to a valid Qt installation: "%QT_HOME%"
   pause
   goto :eof
)

if not exist "%ANDROID_NDK_HOME%" (
   echo ANDROID_NDK_HOME does not point to a valid Android NDK installation: "%ANDROID_NDK_HOME%"
   pause
   goto :eof
)

if not exist "%ANDROID_SDK_HOME%" (
   echo ANDROID_SDK_HOME does not point to a valid Android NDK installation: "%ANDROID_SDK_HOME%"
   pause
   goto :eof
)

if not exist "%ANDROID_SDK_HOME%\extras\google\google_play_services\libproject\google-play-services_lib\libs\google-play-services.jar" (
   echo google-play-services.jar is not installed. Run Android SDK Manager and install that package please.
   pause
   goto :eof
)


rem change into the folder where this script resides
cd /d "%~dp0"
set SRC_FOLDER=%CD%
if not exist "..\%BUILD_FOLDER%" (
   mkdir "..\%BUILD_FOLDER%"
)
cd /d "..\%BUILD_FOLDER%"


rem Remove everything from PATH which might interfere with the MinGW build (e.g. some folder which offers a clashing sh.exe or something...)
PATH=%MINGW_HOME%\bin;%CMAKE_HOME%\bin;%JAVA_HOME%\bin;%SystemRoot%\system32;%SystemRoot%;%SystemRoot%\System32\Wbem


cmake -DTARGET_ANDROID=ON -DANDROID_NDK=%ANDROID_NDK_HOME% -DANDROID_SDK=%ANDROID_SDK_HOME% -DCMAKE_PREFIX_PATH=%QT_HOME% -DCMAKE_BUILD_TYPE=Release -G "MinGW Makefiles" %SRC_FOLDER%


rem Workaround because we currently have no git executable inside MinGW because the binaries accompanying git (e.g. sh.exe) clash with MinGW.
rem This problem will soon go away when we drop MinGW.

echo #include "nabase/include/version/VersionTag.hpp"  >dummy_gitversion.hpp
echo #define  GIT_REVISION  "none"                    >>dummy_gitversion.hpp
echo #define  GIT_TAG       "none"                    >>dummy_gitversion.hpp

if not exist nabase                          mkdir nabase
if not exist nanav                           mkdir nanav

if not exist funit\addr                      mkdir funit\addr
if not exist funit\dbupdate                  mkdir funit\dbupdate
if not exist funit\fts                       mkdir funit\fts
if not exist funit\guidanceviewer\src\styles mkdir funit\guidanceviewer\src\styles
if not exist funit\maneuver-calc\src         mkdir funit\maneuver-calc\src
if not exist funit\lane-calc\src             mkdir funit\lane-calc\src
if not exist funit\online-poi                mkdir funit\online-poi
if not exist funit\poi                       mkdir funit\poi
if not exist funit\positioning               mkdir funit\positioning
if not exist funit\route\src                 mkdir funit\route
if not exist funit\speech\src                mkdir funit\speech\src

if not exist mgr\addr                        mkdir mgr\addr
if not exist mgr\configuration               mkdir mgr\configuration
if not exist mgr\dbupdate                    mkdir mgr\dbupdate
if not exist mgr\fts                         mkdir mgr\fts
if not exist mgr\guidance\src                mkdir mgr\guidance\src
if not exist mgr\guidanceviewer\src          mkdir mgr\guidanceviewer\src
if not exist mgr\lane-calc\src               mkdir mgr\lane-calc\src
if not exist mgr\location                    mkdir mgr\location
if not exist mgr\mapviewer\src               mkdir mgr\mapviewer\src
if not exist mgr\mpd                         mkdir mgr\mpd
if not exist mgr\nds\src                     mkdir mgr\nds\src
if not exist mgr\online-poi\src              mkdir mgr\online-poi\src
if not exist mgr\onoff                       mkdir mgr\onoff
if not exist mgr\otto                        mkdir mgr\otto
if not exist mgr\poi                         mkdir mgr\poi
if not exist mgr\positioning                 mkdir mgr\positioning
if not exist mgr\route                       mkdir mgr\route
if not exist mgr\traffic                     mkdir mgr\traffic
if not exist mgr\tts\src                     mkdir mgr\tts\src

if not exist main\src\na_dbu                 mkdir main\src\na_dbu
if not exist main\src\na_bcore             mkdir main\src\na_bcore
if not exist main\src\na_onoff               mkdir main\src\na_onoff


copy /y dummy_gitversion.hpp                 nabase\gitversion.hpp                           >nul
copy /y dummy_gitversion.hpp                 nanav\gitversion.hpp                            >nul

copy /y dummy_gitversion.hpp                 funit\addr\configure.hpp                        >nul
copy /y dummy_gitversion.hpp                 funit\dbupdate\gitversion.hpp                   >nul
copy /y dummy_gitversion.hpp                 funit\fts\configure.hpp                         >nul
copy /y dummy_gitversion.hpp                 funit\guidanceviewer\src\styles\gitversion.hpp  >nul
copy /y dummy_gitversion.hpp                 funit\lane-calc\src\configure.hpp               >nul
copy /y dummy_gitversion.hpp                 funit\maneuver-calc\src\configure.hpp           >nul
copy /y dummy_gitversion.hpp                 funit\online-poi\configure.hpp                  >nul
copy /y dummy_gitversion.hpp                 funit\poi\configure.hpp                         >nul
copy /y dummy_gitversion.hpp                 funit\positioning\gitversion.hpp                >nul
copy /y dummy_gitversion.hpp                 funit\route\gitversion.hpp                      >nul
copy /y dummy_gitversion.hpp                 funit\route\test\gitversion.hpp                 >nul
copy /y dummy_gitversion.hpp                 funit\speech\src\configure.hpp                  >nul

copy /y dummy_gitversion.hpp                 mgr\addr\configure.hpp                          >nul
copy /y dummy_gitversion.hpp                 mgr\configuration\gitversion.hpp                >nul
copy /y dummy_gitversion.hpp                 mgr\dbupdate\gitversion.hpp                     >nul
copy /y dummy_gitversion.hpp                 mgr\fts\configure.hpp                           >nul
copy /y dummy_gitversion.hpp                 mgr\guidance\src\configure.hpp                  >nul
copy /y dummy_gitversion.hpp                 mgr\guidanceviewer\src\configure.hpp            >nul
copy /y dummy_gitversion.hpp                 mgr\lane-calc\src\configure.hpp                 >nul
copy /y dummy_gitversion.hpp                 mgr\location\configure.hpp                      >nul
copy /y dummy_gitversion.hpp                 mgr\mapviewer\src\configure.hpp                 >nul
copy /y dummy_gitversion.hpp                 mgr\mpd\gitversion.hpp                          >nul
copy /y dummy_gitversion.hpp                 mgr\nds\src\configure.hpp                       >nul
copy /y dummy_gitversion.hpp                 mgr\online-poi\src\configure.hpp                >nul
copy /y dummy_gitversion.hpp                 mgr\onoff\gitversion.hpp                        >nul
copy /y dummy_gitversion.hpp                 mgr\otto\gitversion.hpp                         >nul
copy /y dummy_gitversion.hpp                 mgr\poi\configure.hpp                           >nul
copy /y dummy_gitversion.hpp                 mgr\positioning\gitversion.hpp                  >nul
copy /y dummy_gitversion.hpp                 mgr\route\gitversion.hpp                        >nul
copy /y dummy_gitversion.hpp                 mgr\traffic\gitversion.hpp                      >nul
copy /y dummy_gitversion.hpp                 mgr\tts\src\configure.hpp                       >nul

copy /y dummy_gitversion.hpp                 main\src\na_dbu\gitversion.hpp                  >nul
copy /y dummy_gitversion.hpp                 main\src\na_bcore\gitversion.hpp              >nul
copy /y dummy_gitversion.hpp                 main\src\na_onoff\gitversion.hpp                >nul

mingw32-make -j4 all package
