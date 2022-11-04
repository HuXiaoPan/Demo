# This is the default configuration of all QT5 packages (including GUI parts) used by TTNA.
# Every 'root' or 'integration' repository which needs to use an funit or mgr which uses QT GUI can
# simply include this instead of copy'n'paste the configuration.
#
# Usage:
# --------
# project(xyz)
# include(cmake/na-qt5-gui-default.cmake)
# --------
#
# Note: The name of this file is chosen to be analogous to Qt5's supplied cmake build files, i.e.:
#       <your_qt_folder>\lib\cmake\Qt5Gui
#       In future, there might be more such files, each supplying your build with Qt5 libraries.
#       Each of them should be chosen to be also analogous to the <your_qt_folder>\lib\cmake\ folders.
#       It should be possible to include them all.
#       E.g. if one mgr/X wants na-qt5-gui-default.cmake and another mgr/Y wants na-qt5-core-default.cmake,
#       you simply can include both. Each na-qt5-XYZ-default.cmake should resolve any conflicts.

if((NOT CMAKE_C_COMPILER_ID) OR (NOT CMAKE_CXX_COMPILER_ID))
   message(FATAL_ERROR "na-qt5-gui-default.cmake must be included *after* project()")
   # The reason for this is that project() initializes the build environment,
   # and the packages used in here rely on that information.
endif()

find_package(Qt5Core REQUIRED)
find_package(Qt5Gui REQUIRED)
find_package(Qt5Widgets REQUIRED)
find_package(Qt5OpenGL REQUIRED)

add_definitions(${Qt5Gui_DEFINITIONS})
add_definitions(${Qt5Widgets_DEFINITIONS})
add_definitions(${Qt5OpenGL_DEFINITIONS})

include_directories(SYSTEM ${Qt5Core_INCLUDE_DIRS})
include_directories(SYSTEM ${Qt5Gui_INCLUDE_DIRS})
include_directories(SYSTEM ${Qt5Widgets_INCLUDE_DIRS})
include_directories(SYSTEM ${Qt5OpenGL_INCLUDE_DIRS})

# set CMAKE policy CMP0020 to NEW behaviour => auto link qtmain.lib to qt executable
# This disables the cmake warning about unset policy, which was issued for every cmakelists.txt file which didn't require cmake version 2.8.12.
# !MKi 2016-01-21: CMake docu strongly suggests to use CMAKE_POLICY(SET CMP0020 NEW). But that must be done in every CMakelists.txt!
# With setting the default policy in the cache, all warnings are disabled at once (the policy can still be set differently locally).
set(CMAKE_POLICY_DEFAULT_CMP0020 NEW CACHE UNINITIALIZED "projects using na-qt5-gui-default use QT policy CMP0020 NEW by default")
