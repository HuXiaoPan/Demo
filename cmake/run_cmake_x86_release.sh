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

if [ ! -d "/edna_build_x86_Release/" ];then
  mkdir -m 777 edna_build_x86_Release
else
  echo "The folder edna_build_x86_Release already exists"
fi

if [ ! -d "/edna_install_x86_Release/" ];then
  mkdir -m 777 edna_install_x86_Release
else
  echo "The folder edna_install_x86_Release already exists"
fi

cp edna/funit/positioning/DR/SERVICE/OSAdaptor/libs/Android/X86/Release/libOSAdaptor.a edna/funit/positioning/DR/SERVICE/OSAdaptor/libs/
cp edna/funit/positioning/DR/SERVICE/ConfigureCache/libs/Android/X86/Release/libConfigureCache.a edna/funit/positioning/DR/SERVICE/ConfigureCache/libs/
cp edna/funit/positioning/DR/VehiclePosition/libs/Android/X86/Release/libDeadReckoning.a edna/funit/positioning/DR/VehiclePosition/libs/
cp edna/funit/positioning/DR/VehiclePosition/libs/Android/X86/Release/libSensors.a edna/funit/positioning/DR/VehiclePosition/libs/

cd edna_build_x86_Release

export PKG_CONFIG_SYSROOT_DIR=$ANDROID_NDK_SYSROOT
export PKG_CONFIG_PATH=$PKG_CONFIG_SYSROOT_DIR/usr/lib/pkgconfig:$PKG_CONFIG_SYSROOT_DIR/usr/share/pkgconfig

cmake -DTARGET_ANDROID=ON -DANDROID_SDK_API_LEVEL=29 -DANDROID_SDK_MIN_API_LEVEL=29 -DANDROID_ABI=x86 -DANDROID_SDK=$ANDROID_SDK -DANDROID_NDK=$ANDROID_NDK -DANDROID_JAR=$ANDROID_SDK/platforms/android-29/android.jar -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake -DWITH_PLUGINS=OFF -DWITH_DOCS=OFF -DWITH_TESTS=OFF -DDUMMY_GIT_VERSION=OFF -DNABASE_EGL_BACKEND=Android -DCMAKE_INSTALL_PREFIX=../edna_install_x86_Release -DUSE_QT=OFF -DCMAKE_BUILD_TYPE=Release ../edna
make -j16 install

