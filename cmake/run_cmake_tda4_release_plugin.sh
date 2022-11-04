if [ ! -f "../CMakeLists.txt" ];then
  echo "CMakeLists.txt file NOT exists"
  exit 3
fi

cd ../../



    if [ ! -d "/edna_build_linux_release_pc/" ];then
        mkdir -m 777 edna_build_linux_release_pc
    fi
    if [ ! -d "/edna_install_linux_release_pc/" ];then
        mkdir -m 777 edna_install_linux_release_pc
    fi

    cp edna/funit/positioning/DR/SERVICE/OSAdaptor/libs/TDA4/X86/Release/libOSAdaptor.a edna/funit/positioning/DR/SERVICE/OSAdaptor/libs/
    cp edna/funit/positioning/DR/SERVICE/ConfigureCache/libs/TDA4/X86/Release/libConfigureCache.a edna/funit/positioning/DR/SERVICE/ConfigureCache/libs/
    cp edna/funit/positioning/DR/VehiclePosition/libs/TDA4/X86/Release/libDeadReckoning.a edna/funit/positioning/DR/VehiclePosition/libs/
    cp edna/funit/positioning/DR/VehiclePosition/libs/TDA4/X86/Release/libSensors.a edna/funit/positioning/DR/VehiclePosition/libs/

    cd edna_build_linux_release_pc
    cmake -DWITH_PLUGINS=ON -DWITH_DOCS=OFF -DWITH_TESTS=OFF -DDUMMY_GIT_VERSION=OFF -DNABASE_EGL_BACKEND=Qt -DCMAKE_INSTALL_PREFIX=../edna_install_linux_release_pc -DUSE_QT=ON -DCMAKE_BUILD_TYPE=Release -DDISABLE_WINDOW_HANDLING=OFF -DWITH_ASAN=OFF ../edna


if [ $? -ne 0 ]; then
    echo "cmake failed!!"
else
    echo "cmake succeed!!"
    
    make -j8 all install
        

fi


