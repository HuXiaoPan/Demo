# This file supplies your build with Qt5's webkit libraries.
#
# Usage:
# --------
# project(xyz)
# include(cmake/na-qt5-webkitwidgets-default.cmake)
# --------
#
# Note: The name of this file is chosen to be analogous to Qt5's supplied cmake build files, i.e.:
#       <your_qt_folder>\lib\cmake\Qt5WebKitWidgets
#       In future, there might be more such files, each supplying your build with Qt5 libraries.
#       Each of them should be chosen to be also analogous to the <your_qt_folder>\lib\cmake\ folders.
#       It should be possible to include them all.
#       E.g. if one mgr/X wants na-qt5-websockets-default.cmake and another mgr/Y wants na-qt5-core-default.cmake,
#       you simply can include both. Each na-qt5-XYZ-default.cmake should resolve any conflicts.

if((NOT CMAKE_C_COMPILER_ID) OR (NOT CMAKE_CXX_COMPILER_ID))
   message(FATAL_ERROR "na-qt5-websockets-default.cmake must be included *after* project()")
   # The reason for this is that project() initializes the build environment,
   # and the packages used in here rely on that information.
endif()

find_package(Qt5WebKitWidgets REQUIRED)

add_definitions(${Qt5WebKitWidgets_DEFINITIONS})

include_directories(SYSTEM ${Qt5WebKitWidgets_INCLUDE_DIRS})
