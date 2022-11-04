if [ ! -f "../CMakeLists.txt" ];then
  echo "CMakeLists.txt file NOT exists"
  exit 3
fi

cd ../../

if [ ! -d "/edna_build_x86/" ];then
  mkdir -m 777 edna_build_x86
else
  echo "The folder edna_build already exists"
fi

if [ ! -d "/edna_install_x86/" ];then
  mkdir -m 777 edna_install_x86
else
  echo "The folder edna_install already exists" 
fi

cp edna/funit/positioning/DR/SERVICE/OSAdaptor/libs/Android/X86/Debug/libOSAdaptor.a edna/funit/positioning/DR/SERVICE/OSAdaptor/libs/
    cp edna/funit/positioning/DR/SERVICE/ConfigureCache/libs/Android/X86/Debug/libConfigureCache.a edna/funit/positioning/DR/SERVICE/ConfigureCache/libs/
    cp edna/funit/positioning/DR/VehiclePosition/libs/Android/X86/Debug/libDeadReckoning.a edna/funit/positioning/DR/VehiclePosition/libs/
    cp edna/funit/positioning/DR/VehiclePosition/libs/Android/X86/Debug/libSensors.a edna/funit/positioning/DR/VehiclePosition/libs/

cd edna_build_x86

cmake -DTARGET_ANDROID=ON -DANDROID_SDK_API_LEVEL=28 -DANDROID_ABI=x86 -DANDROID_SDK=$ANDROID_SDK -DANDROID_NDK=$ANDROID_NDK -DANDROID_JAR=$ANDROID_SDK/platforms/android-28/android.jar -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake -DWITH_PLUGINS=OFF -DWITH_DOCS=ON -DWITH_TESTS=OFF -DDUMMY_GIT_VERSION=OFF -DNABASE_EGL_BACKEND=Android -DCMAKE_INSTALL_PREFIX=../edna_install_x86 -DUSE_QT=OFF -DCMAKE_BUILD_TYPE=Debug ../edna

