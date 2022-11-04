#!/bin/bash


cd ../
if [ -a "CMakeLists.txt" ]
then
  echo "CMakeLists.txt exist"
else
	echo "CMakeLists.txt file NOT exists"
	exit 3
fi
cd cmake

cd ../../


#build param:
#allnavi
#server
#client
TARGET_SYALLMODE=NOSYALLMODE
TARGET_BUILDMODE=ANDROID_ALLNAVI

EDNA_BUILD_DEBUG_PATH=edna_build_android_x86_debug
EDNA_INSTALL_DEBUG_PATH=edna_install_android_x86_debug
EDNA_BUILD_FIRST_NAME=edna_build
EDNA_INSTALL_FIRST_NAME=edna_install
EDNA_SERVER=_server
EDNA_CLIENT=_client
EDNA_LAST_NAME=""
EDNA_PLATFORM=""


if [ $# -ne 0 ]; then
    while getopts ":m:i:" opt; do
	  case $opt in
	    m)
	    TARGET_SYALLMODE="$OPTARG"
         if [ "$OPTARG" = "syallmode" ]; then
            TARGET_SYALLMODE=SYALLMODE
         fi
       ;;
	    i)
	    TARGET_BUILDMODE="$OPTARG"
         if [ "$OPTARG" = "allnavi" ]; then
            TARGET_BUILDMODE=ANDROID_ALLNAVI
         elif [ "$OPTARG" = "server" ]; then
            TARGET_BUILDMODE=PICKMAP_SERVER
         elif [ "$OPTARG" = "client" ]; then
            TARGET_BUILDMODE=PICKMAP_CLIENT
         fi
       ;;
	    ?)
	    echo "unknow param eg:[-m syallmode] or [-i allnavi] or [-i server] or [-i client]"
	    exit 1;;
	  esac
     done
fi
echo "TARGET_SYALLMODE = ${TARGET_SYALLMODE}"
echo "TARGET_BUILDMODE = ${TARGET_BUILDMODE}"


echo "buildType:"
echo "1:  AOM_ANDROID_X86"
echo "2:  AOM_ANDROID_armeabi-v7a"
echo "3:  AOM_ANDROID_arm64-v8a"
read -p "Choose build Type:" _UseType

    if [ $TARGET_BUILDMODE = "PICKMAP_SERVER" ]; then
        EDNA_LAST_NAME=${EDNA_SERVER}
    elif [ $TARGET_BUILDMODE = "PICKMAP_CLIENT" ]; then
        EDNA_LAST_NAME=${EDNA_CLIENT}
    else 
        EDNA_LAST_NAME=""
    fi

if [[ ${_UseType} = "1" ]]; then

    EDNA_PLATFORM=_android_x86_debug
    EDNA_BUILD_DEBUG_PATH=${EDNA_BUILD_FIRST_NAME}${EDNA_PLATFORM}${EDNA_LAST_NAME}
    EDNA_INSTALL_DEBUG_PATH=${EDNA_INSTALL_FIRST_NAME}${EDNA_PLATFORM}${EDNA_LAST_NAME}
    echo "EDNA_BUILD_DEBUG_PATH = ${EDNA_BUILD_DEBUG_PATH}"
    echo "EDNA_INSTALL_DEBUG_PATH = ${EDNA_INSTALL_DEBUG_PATH}"
   if [ ! -d "/${EDNA_BUILD_DEBUG_PATH}/" ];then
      mkdir -m 777 ${EDNA_BUILD_DEBUG_PATH}
   fi

   if [ ! -d "/${EDNA_INSTALL_DEBUG_PATH}/" ];then
      mkdir -m 777 ${EDNA_INSTALL_DEBUG_PATH}
   fi

   cp edna/funit/positioning/DR/SERVICE/OSAdaptor/libs/Android/X86/Debug/libOSAdaptor.a edna/funit/positioning/DR/SERVICE/OSAdaptor/libs/
   cp edna/funit/positioning/DR/SERVICE/ConfigureCache/libs/Android/X86/Debug/libConfigureCache.a edna/funit/positioning/DR/SERVICE/ConfigureCache/libs/
   cp edna/funit/positioning/DR/VehiclePosition/libs/Android/X86/Debug/libDeadReckoning.a edna/funit/positioning/DR/VehiclePosition/libs/
   cp edna/funit/positioning/DR/VehiclePosition/libs/Android/X86/Debug/libSensors.a edna/funit/positioning/DR/VehiclePosition/libs/

   cd ${EDNA_BUILD_DEBUG_PATH}

   cmake -DTARGET_ANDROID=ON -DTARGET_BUILDMODE=${TARGET_BUILDMODE} -DTARGET_SYALLMODE=${TARGET_SYALLMODE} -DANDROID_SDK_API_LEVEL=29 -DANDROID_SDK_MIN_API_LEVEL=29 -DANDROID_ABI=x86 -DANDROID_SDK=$ANDROID_SDK -DANDROID_NDK=$ANDROID_NDK -DANDROID_JAR=$ANDROID_SDK/platforms/android-29/android.jar -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake -DWITH_PLUGINS=OFF -DWITH_DOCS=OFF -DWITH_TESTS=OFF -DDUMMY_GIT_VERSION=OFF -DNABASE_EGL_BACKEND=Android -DCMAKE_INSTALL_PREFIX=../${EDNA_INSTALL_DEBUG_PATH} -DUSE_QT=OFF -DCMAKE_BUILD_TYPE=Debug ../edna

elif [[ ${_UseType} = "2" ]]; then
    EDNA_PLATFORM=_android_armeabi-v7a_debug
    EDNA_BUILD_DEBUG_PATH=${EDNA_BUILD_FIRST_NAME}${EDNA_PLATFORM}${EDNA_LAST_NAME}
    EDNA_INSTALL_DEBUG_PATH=${EDNA_INSTALL_FIRST_NAME}${EDNA_PLATFORM}${EDNA_LAST_NAME}
    echo "EDNA_BUILD_DEBUG_PATH = ${EDNA_BUILD_DEBUG_PATH}"
    echo "EDNA_INSTALL_DEBUG_PATH = ${EDNA_INSTALL_DEBUG_PATH}"
   if [ ! -d "/${EDNA_BUILD_DEBUG_PATH}/" ];then
      mkdir -m 777 ${EDNA_BUILD_DEBUG_PATH}
   fi

   if [ ! -d "/${EDNA_INSTALL_DEBUG_PATH}/" ];then
      mkdir -m 777 ${EDNA_INSTALL_DEBUG_PATH}
   fi

   cp edna/funit/positioning/DR/SERVICE/OSAdaptor/libs/Android/armeabi-v7a/Debug/libOSAdaptor.a edna/funit/positioning/DR/SERVICE/OSAdaptor/libs/
   cp edna/funit/positioning/DR/SERVICE/ConfigureCache/libs/Android/armeabi-v7a/Debug/libConfigureCache.a edna/funit/positioning/DR/SERVICE/ConfigureCache/libs/
   cp edna/funit/positioning/DR/VehiclePosition/libs/Android/armeabi-v7a/Debug/libDeadReckoning.a edna/funit/positioning/DR/VehiclePosition/libs/
   cp edna/funit/positioning/DR/VehiclePosition/libs/Android/armeabi-v7a/Debug/libSensors.a edna/funit/positioning/DR/VehiclePosition/libs/

   cd ${EDNA_BUILD_DEBUG_PATH}
   cmake -DTARGET_ANDROID=ON -DTARGET_BUILDMODE=${TARGET_BUILDMODE} -DTARGET_SYALLMODE=${TARGET_SYALLMODE} -DANDROID_SDK=$ANDROID_SDK -DANDROID_SDK_API_LEVEL=29 -DANDROID_ABI=armeabi-v7a -DANDROID_JAR=$ANDROID_SDK/platforms/android-29/android.jar -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake -DWITH_PLUGINS=OFF -DWITH_DOCS=OFF -DWITH_TESTS=OFF -DDUMMY_GIT_VERSION=OFF -DNABASE_EGL_BACKEND=Android -DCMAKE_INSTALL_PREFIX=../${EDNA_INSTALL_DEBUG_PATH} -DUSE_QT=OFF -DCMAKE_BUILD_TYPE=Debug -DDISABLE_WINDOW_HANDLING=OFF -DCMAKE_ANDROID_STANDALONE_TOOLCHAIN=$ANDROID_NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/arm-linux-androideabi ../edna

elif [[ ${_UseType} = "3" ]]; then
    EDNA_PLATFORM=_android_arm64-v8a_debug
    EDNA_BUILD_DEBUG_PATH=${EDNA_BUILD_FIRST_NAME}${EDNA_PLATFORM}${EDNA_LAST_NAME}
    EDNA_INSTALL_DEBUG_PATH=${EDNA_INSTALL_FIRST_NAME}${EDNA_PLATFORM}${EDNA_LAST_NAME}
    echo "EDNA_BUILD_DEBUG_PATH = ${EDNA_BUILD_DEBUG_PATH}"
    echo "EDNA_INSTALL_DEBUG_PATH = ${EDNA_INSTALL_DEBUG_PATH}"
   if [ ! -d "/${EDNA_BUILD_DEBUG_PATH}/" ];then
      mkdir -m 777 ${EDNA_BUILD_DEBUG_PATH}
   fi

   if [ ! -d "/${EDNA_INSTALL_DEBUG_PATH}/" ];then
      mkdir -m 777 ${EDNA_INSTALL_DEBUG_PATH}
   fi

   cp edna/funit/positioning/DR/SERVICE/OSAdaptor/libs/Android/arm64-v8a/Debug/libOSAdaptor.a edna/funit/positioning/DR/SERVICE/OSAdaptor/libs/
   cp edna/funit/positioning/DR/SERVICE/ConfigureCache/libs/Android/arm64-v8a/Debug/libConfigureCache.a edna/funit/positioning/DR/SERVICE/ConfigureCache/libs/
   cp edna/funit/positioning/DR/VehiclePosition/libs/Android/arm64-v8a/Debug/libDeadReckoning.a edna/funit/positioning/DR/VehiclePosition/libs/
   cp edna/funit/positioning/DR/VehiclePosition/libs/Android/arm64-v8a/Debug/libSensors.a edna/funit/positioning/DR/VehiclePosition/libs/

   cd ${EDNA_BUILD_DEBUG_PATH}
   cmake -DTARGET_ANDROID=ON -DTARGET_BUILDMODE=${TARGET_BUILDMODE} -DTARGET_SYALLMODE=${TARGET_SYALLMODE} -DANDROID_SDK=$ANDROID_SDK -DANDROID_SDK_API_LEVEL=29 -DANDROID_ABI=arm64-v8a -DANDROID_JAR=$ANDROID_SDK/platforms/android-29/android.jar -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake -DWITH_PLUGINS=OFF -DWITH_DOCS=OFF -DWITH_TESTS=OFF -DDUMMY_GIT_VERSION=OFF -DNABASE_EGL_BACKEND=Android -DCMAKE_INSTALL_PREFIX=../${EDNA_INSTALL_DEBUG_PATH} -DUSE_QT=OFF -DCMAKE_BUILD_TYPE=Debug -DDISABLE_WINDOW_HANDLING=OFF -DCMAKE_ANDROID_STANDALONE_TOOLCHAIN=$ANDROID_NDK/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/aarch64-linux-android ../edna

else
    echo "UseType: ${_UseType} Error"
    exit 3
fi


make -j8 install

