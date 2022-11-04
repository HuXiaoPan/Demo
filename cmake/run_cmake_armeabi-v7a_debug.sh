if [ ! -f "../CMakeLists.txt" ];then
  echo "CMakeLists.txt file NOT exists"
  exit 3
fi

cd ../../

if [ ! -d "/edna_build_arm/" ];then
  mkdir -m 777 edna_build_arm
else
  echo "The folder edna_build already exists"
fi

if [ ! -d "/edna_install_arm/" ];then
  mkdir -m 777 edna_install_arm
else
  echo "The folder edna_install already exists" 
fi
cp edna/funit/positioning/DR/SERVICE/OSAdaptor/libs/Android/ARM/Debug/libOSAdaptor.a edna/funit/positioning/DR/SERVICE/OSAdaptor/libs/
cp edna/funit/positioning/DR/SERVICE/ConfigureCache/libs/Android/ARM/Debug/libConfigureCache.a edna/funit/positioning/DR/SERVICE/ConfigureCache/libs/
cp edna/funit/positioning/DR/VehiclePosition/libs/Android/ARM/Debug/libDeadReckoning.a edna/funit/positioning/DR/VehiclePosition/libs/
cp edna/funit/positioning/DR/VehiclePosition/libs/Android/ARM/Debug/libSensors.a edna/funit/positioning/DR/VehiclePosition/libs/

cd edna_build_arm
cmake -DTARGET_ANDROID=ON -DANDROID_SDK=$ANDROID_SDK -DANDROID_SDK_API_LEVEL=28 -DANDROID_ABI=armeabi-v7a -DANDROID_JAR=$ANDROID_SDK/platforms/android-28/android.jar -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake -DWITH_PLUGINS=OFF -DWITH_DOCS=OFF -DWITH_TESTS=OFF -DDUMMY_GIT_VERSION=OFF -DNABASE_EGL_BACKEND=Android -DCMAKE_INSTALL_PREFIX=../edna_install_arm -DUSE_QT=OFF -DCMAKE_BUILD_TYPE=Debug -DDISABLE_WINDOW_HANDLING=OFF -DCMAKE_ANDROID_STANDALONE_TOOLCHAIN=$ANDROID_NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/arm-linux-androideabi ../edna


