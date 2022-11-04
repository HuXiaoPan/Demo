# hacky whacky script to find DBUS

if(DBUS_ROOT)

   find_path( DBUS_INCLUDE_DIR dbus/dbus.h
              PATHS ${DBUS_ROOT}/include 
              CMAKE_FIND_ROOT_PATH_BOTH
              NO_DEFAULT_PATH)
   find_path( DBUS_INCLUDE_LIB_DIR dbus/dbus-arch-deps.h
              PATHS ${DBUS_ROOT}/include 
              CMAKE_FIND_ROOT_PATH_BOTH
              NO_DEFAULT_PATH)
   find_library( DBUS_LIBRARIES
              NAME  dbus-1
              PATHS ${DBUS_ROOT}/lib 
              CMAKE_FIND_ROOT_PATH_BOTH
              NO_DEFAULT_PATH)
   if(WIN32)
      find_file( DBUS_DLLS
                 NAME  dbus-1.dll
                 PATHS ${DBUS_ROOT}/bin
                 CMAKE_FIND_ROOT_PATH_BOTH
                 NO_DEFAULT_PATH)
   else()
      set( DBUS_DLLS "")
   endif()

else()
   
   # manual search
   if(WIN32)

      # on Win32, we'll scan the PATH environment variable.
      foreach(P $ENV{PATH})
         set( DBUS_LIB_SEARCH_PATHS     ${DBUS_LIB_SEARCH_PATHS} ${P}/../lib)
         set( DBUS_DLL_SEARCH_PATHS     ${DBUS_DLL_SEARCH_PATHS} ${P}/../bin)
         set( DBUS_INCLUDE_SEARCH_PATHS ${DBUS_INCLUDE_SEARCH_PATHS} ${P}/../include)
      endforeach()
      set( DBUS_INCLUDE_LIB_SEARCH_PATHS ${DBUS_INCLUDE_SEARCH_PATHS})
      
      find_file( DBUS_DLLS
                 NAME  dbus-1.dll
                 PATHS ${DBUS_DLL_SEARCH_PATHS}
               )
   else()

      set( DBUS_LIB_SEARCH_PATHS /usr/lib 
                                 /usr/local/lib )
      set( DBUS_INCLUDE_SEARCH_PATHS /usr/include/dbus-1.0
                                     /usr/local/include/dbus-1.0 )
      set( DBUS_INCLUDE_LIB_SEARCH_PATHS /usr/lib/${CMAKE_C_LIBRARY_ARCHITECTURE}/dbus-1.0/include
                                         /usr/local/lib/${CMAKE_C_LIBRARY_ARCHITECTURE}/dbus-1.0/include
                                         /lib/dbus-1.0/include
                                         /usr/lib/dbus-1.0/include
                                         /usr/lib64/dbus-1.0/include
                                         /usr/local/lib/dbus-1.0/include )

      if(CMAKE_SYSTEM_NAME STREQUAL "QNX")
          set( DBUS_INCLUDE_LIB_SEARCH_PATHS 
                                         ${DBUS_INCLUDE_LIB_SEARCH_PATHS}
                                         /${QNX_TARGET_ARCHITECTURE}/usr/lib/dbus-1.0/include)
      endif()

      set( DBUS_DLLS "")

   endif()

   #message( "DBUS_LIB_SEARCH_PATHS:         ${DBUS_LIB_SEARCH_PATHS}")
   #message( "DBUS_INCLUDE_SEARCH_PATHS:     ${DBUS_INCLUDE_SEARCH_PATHS}")
   #message( "DBUS_INCLUDE_LIB_SEARCH_PATHS: ${DBUS_INCLUDE_LIB_SEARCH_PATHS}")

    find_path( DBUS_INCLUDE_DIR dbus/dbus.h
            PATHS ${DBUS_INCLUDE_SEARCH_PATHS}
            )

    find_path( DBUS_INCLUDE_LIB_DIR dbus/dbus-arch-deps.h
            PATHS ${DBUS_INCLUDE_LIB_SEARCH_PATHS}
            )

    find_library( DBUS_LIBRARIES
                NAME  dbus-1
                PATHS ${DBUS_LIB_SEARCH_PATHS}
                )
endif()


#message( "DBUS_INCLUDE_DIR:     ${DBUS_INCLUDE_DIR}")
#message( "DBUS_INCLUDE_LIB_DIR: ${DBUS_INCLUDE_LIB_DIR}")
#message( "DBUS_LIBRARIES:       ${DBUS_LIBRARIES}")
#message( "DBUS_DLLS:            ${DBUS_DLLS}")

if( DBUS_INCLUDE_DIR AND DBUS_INCLUDE_LIB_DIR AND DBUS_LIBRARIES )
   set( DBUS_FOUND TRUE )
endif()

if( DBUS_INCLUDE_DIR AND DBUS_INCLUDE_LIB_DIR )
   set( DBUS_INCLUDE_DIRS ${DBUS_INCLUDE_DIR} ${DBUS_INCLUDE_LIB_DIR} )
endif()

if(DBUS_FOUND)
   if( NOT DBUS_FIND_QUIETLY )
      message( STATUS "Found dbus: ${DBUS_LIBRARIES}" )
   endif()
else()
   if( DBUS_FIND_REQUIRED )
      message( FATAL_ERROR "Could not find dbus" )
   endif()
endif()
