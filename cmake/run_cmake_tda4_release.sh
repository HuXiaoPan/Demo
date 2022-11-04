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
TARGET_BUILDMODE=TDA4_ALLNAVI

EDNA_BUILD_RELEASE_PATH=edna_build_arm_linux_release
EDNA_INSTALL_RELEASE_PATH=edna_install_arm_linux_release
EDNA_BUILD_FIRST_NAME=edna_build
EDNA_INSTALL_FIRST_NAME=edna_install
EDNA_SERVER=_server
EDNA_CLIENT=_client
EDNA_LAST_NAME=""
EDNA_PLATFORM=""
EDNA_STRIP=""

if [ $# -ne 0 ]; then
    while getopts ":m:i:s:f:" opt; do
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
            TARGET_BUILDMODE=TDA4_ALLNAVI
         elif [ "$OPTARG" = "server" ]; then
            TARGET_BUILDMODE=PICKMAP_SERVER
         elif [ "$OPTARG" = "client" ]; then
            TARGET_BUILDMODE=PICKMAP_CLIENT
         fi
       ;;
        s)
            if [ "$OPTARG" = "strip" ]; then
                if [ $TARGET_SYALLMODE = "NOSYALLMODE" ]; then
                    TARGET_SYALLMODE=SYALLMODE
                fi
                EDNA_STRIP=/strip
            fi
        ;;
	    f)
        qnxlic="$OPTARG";;
	    ?)
	    echo "unknow param eg:[-m syallmode] or [-i allnavi] or [-i server] or [-i client] or [-f qnxlice] or [-s strip]"
	    exit 1;;
	  esac
     done
fi
echo "TARGET_SYALLMODE = ${TARGET_SYALLMODE}"
echo "TARGET_BUILDMODE = ${TARGET_BUILDMODE}"

echo "Build Target:"
echo "1: TDA4 Linux Release"
echo "2: Linux PC Release"
echo "3: TDA4 QNX Release"
read -p "Choose Build Target:" _BuildTarget

    if [ $TARGET_BUILDMODE = "PICKMAP_SERVER" ]; then
        EDNA_LAST_NAME=${EDNA_SERVER}
    elif [ $TARGET_BUILDMODE = "PICKMAP_CLIENT" ]; then
        EDNA_LAST_NAME=${EDNA_CLIENT}
    else 
        EDNA_LAST_NAME=""
    fi

if [ ${_BuildTarget} = "1" ]; then
    source /opt/arago/environment-setup-aarch64-linux
    _Tmp = 1

    EDNA_PLATFORM=_arm_linux_release
    EDNA_BUILD_RELEASE_PATH=${EDNA_BUILD_FIRST_NAME}${EDNA_PLATFORM}${EDNA_LAST_NAME}
    EDNA_INSTALL_RELEASE_PATH=${EDNA_INSTALL_FIRST_NAME}${EDNA_PLATFORM}${EDNA_LAST_NAME}
    echo "EDNA_BUILD_RELEASE_PATH = ${EDNA_BUILD_RELEASE_PATH}"
    echo "EDNA_INSTALL_RELEASE_PATH = ${EDNA_INSTALL_RELEASE_PATH}"
    if [ ! -d "/${EDNA_BUILD_RELEASE_PATH}/" ];then
        mkdir -m 777 ${EDNA_BUILD_RELEASE_PATH}
    else
        echo "The folder edna_build already exists"
    fi

    if [ ! -d "/${EDNA_INSTALL_RELEASE_PATH}/" ];then
        mkdir -m 777 ${EDNA_INSTALL_RELEASE_PATH}
    else
        echo "The folder edna_install already exists"
    fi
    cp edna/funit/positioning/DR/SERVICE/OSAdaptor/libs/TDA4/ARM/Release/libOSAdaptor.a edna/funit/positioning/DR/SERVICE/OSAdaptor/libs/
    cp edna/funit/positioning/DR/SERVICE/ConfigureCache/libs/TDA4/ARM/Release/libConfigureCache.a edna/funit/positioning/DR/SERVICE/ConfigureCache/libs/
    cp edna/funit/positioning/DR/VehiclePosition/libs/TDA4/ARM/Release/libDeadReckoning.a edna/funit/positioning/DR/VehiclePosition/libs/
    cp edna/funit/positioning/DR/VehiclePosition/libs/TDA4/ARM/Release/libSensors.a edna/funit/positioning/DR/VehiclePosition/libs/
    cp edna/funit/positioning/DR/VehiclePosition/libs/TDA4/ARM/Release/libsmi230_psdk.a edna/funit/positioning/DR/VehiclePosition/libs/

    cd ${EDNA_BUILD_RELEASE_PATH}

    cmake -DTARGET_PLATFORM=tda4_linux -DTARGET_BUILDMODE=${TARGET_BUILDMODE} -DTARGET_SYALLMODE=${TARGET_SYALLMODE} -DWITH_PLUGINS=OFF -DWITH_DOCS=OFF -DWITH_TESTS=OFF -DNABASE_EGL_BACKEND=TDA4 -DDUMMY_GIT_VERSION=OFF -DCMAKE_INSTALL_PREFIX=../${EDNA_INSTALL_RELEASE_PATH} -DUSE_QT=OFF -DCMAKE_BUILD_TYPE=Release -DWITH_ASAN=OFF ../edna

elif [ ${_BuildTarget} = "2" ]; then
    _Tmp = 2
    EDNA_PLATFORM=_linux_release_pc
    EDNA_BUILD_RELEASE_PATH=${EDNA_BUILD_FIRST_NAME}${EDNA_PLATFORM}${EDNA_LAST_NAME}
    EDNA_INSTALL_RELEASE_PATH=${EDNA_INSTALL_FIRST_NAME}${EDNA_PLATFORM}${EDNA_LAST_NAME}
    echo "EDNA_BUILD_RELEASE_PATH = ${EDNA_BUILD_RELEASE_PATH}"
    echo "EDNA_INSTALL_RELEASE_PATH = ${EDNA_INSTALL_RELEASE_PATH}"
    if [ ! -d "/${EDNA_BUILD_RELEASE_PATH}/" ];then
        mkdir -m 777 ${EDNA_BUILD_RELEASE_PATH}
    fi
    if [ ! -d "/${EDNA_INSTALL_RELEASE_PATH}/" ];then
        mkdir -m 777 ${EDNA_INSTALL_RELEASE_PATH}
    fi

    cp edna/funit/positioning/DR/SERVICE/OSAdaptor/libs/TDA4/X86/Release/libOSAdaptor.a edna/funit/positioning/DR/SERVICE/OSAdaptor/libs/
    cp edna/funit/positioning/DR/SERVICE/ConfigureCache/libs/TDA4/X86/Release/libConfigureCache.a edna/funit/positioning/DR/SERVICE/ConfigureCache/libs/
    cp edna/funit/positioning/DR/VehiclePosition/libs/TDA4/X86/Release/libDeadReckoning.a edna/funit/positioning/DR/VehiclePosition/libs/
    cp edna/funit/positioning/DR/VehiclePosition/libs/TDA4/X86/Release/libSensors.a edna/funit/positioning/DR/VehiclePosition/libs/

    cd ${EDNA_BUILD_RELEASE_PATH}
    if [ $TARGET_BUILDMODE = "PICKMAP_SERVER" ]; then
        echo "TARGET_BUILDMODE == PICKMAP_SERVER"
        cmake -DWITH_PLUGINS=OFF -DTARGET_BUILDMODE=${TARGET_BUILDMODE} -DTARGET_SYALLMODE=${TARGET_SYALLMODE} -DWITH_DOCS=OFF -DWITH_TESTS=OFF -DDUMMY_GIT_VERSION=OFF -DNABASE_EGL_BACKEND=Qt -DCMAKE_INSTALL_PREFIX=../${EDNA_INSTALL_RELEASE_PATH} -DUSE_QT=OFF -DCMAKE_BUILD_TYPE=Release -DDISABLE_WINDOW_HANDLING=ON -DWITH_ASAN=OFF ../edna
    else
        cmake -DWITH_PLUGINS=OFF -DTARGET_BUILDMODE=${TARGET_BUILDMODE} -DTARGET_SYALLMODE=${TARGET_SYALLMODE} -DWITH_DOCS=OFF -DWITH_TESTS=OFF -DDUMMY_GIT_VERSION=OFF -DNABASE_EGL_BACKEND=Qt -DCMAKE_INSTALL_PREFIX=../${EDNA_INSTALL_RELEASE_PATH} -DUSE_QT=ON -DCMAKE_BUILD_TYPE=Release -DDISABLE_WINDOW_HANDLING=OFF -DWITH_ASAN=OFF ../edna
    fi

elif [ ${_BuildTarget} = "3" ]; then
    _Tmp =3
    echo "qnx param:$qnxlic"
    source /opt/qnx/qnx710/qnxsdp-env.sh
    if [ $qnxlic = "qnxlice" ]; then
        echo "qnx sdk lice"
        source /opt/qnx/A_Core_SDK/sdk_env_lice.sh
    else
        echo "qnx sdk free"
        source /opt/qnx/A_Core_SDK/sdk_env_free.sh
    fi

    EDNA_PLATFORM=_arm_qnx_release
    EDNA_BUILD_RELEASE_PATH=${EDNA_BUILD_FIRST_NAME}${EDNA_PLATFORM}${EDNA_LAST_NAME}
    EDNA_INSTALL_RELEASE_PATH=${EDNA_INSTALL_FIRST_NAME}${EDNA_PLATFORM}${EDNA_LAST_NAME}
    echo "EDNA_BUILD_RELEASE_PATH = ${EDNA_BUILD_RELEASE_PATH}"
    echo "EDNA_INSTALL_RELEASE_PATH = ${EDNA_INSTALL_RELEASE_PATH}"
    if [ ! -d "/${EDNA_BUILD_RELEASE_PATH}/" ];then
        mkdir -m 777 ${EDNA_BUILD_RELEASE_PATH}
    else
        echo "The folder edna_build already exists"
    fi

    if [ ! -d "/${EDNA_INSTALL_RELEASE_PATH}/" ];then
        mkdir -m 777 ${EDNA_INSTALL_RELEASE_PATH}
    else
        echo "The folder edna_install already exists"
    fi
    cp edna/funit/positioning/DR/SERVICE/OSAdaptor/libs/TDA4_QNX/ARM/Release/libOSAdaptor.a edna/funit/positioning/DR/SERVICE/OSAdaptor/libs/
    cp edna/funit/positioning/DR/SERVICE/ConfigureCache/libs/TDA4_QNX/ARM/Release/libConfigureCache.a edna/funit/positioning/DR/SERVICE/ConfigureCache/libs/
    cp edna/funit/positioning/DR/VehiclePosition/libs/TDA4_QNX/ARM/Release/libDeadReckoning.a edna/funit/positioning/DR/VehiclePosition/libs/
    cp edna/funit/positioning/DR/VehiclePosition/libs/TDA4_QNX/ARM/Release/libSensors.a edna/funit/positioning/DR/VehiclePosition/libs/
    #cp edna/funit/positioning/DR/VehiclePosition/libs/TDA4_QNX/ARM/Debug/libsmi230_psdk.a edna/funit/positioning/DR/VehiclePosition/libs/

    cd ${EDNA_BUILD_RELEASE_PATH}

    cmake  -DTARGET_PLATFORM=tda4_qnx -DTARGET_BUILDMODE=${TARGET_BUILDMODE} -DTARGET_SYALLMODE=${TARGET_SYALLMODE} -DWITH_PLUGINS=OFF -DWITH_DOCS=OFF -DWITH_TESTS=OFF -DNABASE_EGL_BACKEND=TDA4 -DDUMMY_GIT_VERSION=ON -DCMAKE_INSTALL_PREFIX=../${EDNA_INSTALL_RELEASE_PATH} -DUSE_QT=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE} -DWITH_ASAN=OFF ../edna
else
    echo "Build Target: ${_BuildTarget} Error"
    exit 3
fi


if [ $? -ne 0 ]; then
    echo "cmake failed!!"
else
    echo "cmake succeed!!"
    #cur_dir=cd $(dirname $0); pwd -P
    #cd ../edna_build_arm_release
    make -j8 all install${EDNA_STRIP}
fi


