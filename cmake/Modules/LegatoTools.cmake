#  Project: i-Navi
#  
#
# (c) Copyright 2015 - 2017
#
# All rights reserved.



set(LEGATO_INCLUDE_DIRS)
set(LEGATO_ROOT $ENV{LEGATO_ROOT})

# Build targets & defines
set(LEGATO_FRAMEWORK_DIR                    ${LEGATO_ROOT}/framework/c)
set(LEGATO_LIBRARIES                        ${LIBRARY_OUTPUT_PATH}/liblegato.so -lpthread -lrt)

# Tools
set(LEGATO_TOOL_IFGEN                       ${LEGATO_ROOT}/bin/ifgen)
set(LEGATO_TOOL_MKAPP                       ${LEGATO_ROOT}/bin/mkapp)
set(LEGATO_TOOL_MKEXE                       ${LEGATO_ROOT}/bin/mkexe)
set(LEGATO_TOOL_MKCOMP                      ${LEGATO_ROOT}/bin/mkcomp)
set(LEGATO_TOOL_MKSYS                       ${LEGATO_ROOT}/bin/mksys)
set(LEGATO_TOOL_INSTAPP                     ${LEGATO_ROOT}/bin/instapp)
set(LEGATO_TARGET                           ${CMAKE_SYSTEM_PROCESSOR})



# If embedded, need to build C/C++ code with LEGATO_EMBEDDED defined.
if(LEGATO_EMBEDDED)
    set (LEGATO_EMBEDDED_OPTION --cflags=-DLEGATO_EMBEDDED)
endif()



# Function to build a Legato application using mkapp
# Any subsequent parameters will be passed as-is to mkapp on its command line.
function(add_legato_mkapp ADEF)

    get_filename_component(PKG_NAME ${ADEF} NAME_WE)
    set(APP_PKG "${PKG_NAME}.${LEGATO_TARGET}.update")

    add_custom_target("${APP_PKG}"
                      COMMAND ${LEGATO_TOOL_MKAPP}
                              -t ${LEGATO_TARGET}
                              -v
                              ${ADEF}
            WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
            DEPENDS ${ADEF}
    )

    # message("-- you may build legato app package ${APP_PKG} via 'make pkg_${APP_NAME}'")

    # we define this special target name for comfort reasons
    add_custom_target("pkg_${PKG_NAME}" DEPENDS ${APP_PKG} ${PKG_NAME})
    message("-- you may build legato app package ${APP_PKG} via 'make pkg_${PKG_NAME}'")

endfunction()






# install a legato app onto a given target
#set(LEGATO_TARGET_INSTALL  "target-install")
function(add_legato_target_install APP_PKG TARGET_IP)

   get_filename_component(APP_NAME ${APP_PKG} NAME_WE)
   set(APP_PKG "${APP_NAME}.${LEGATO_TARGET}.update")

   add_custom_target("install_${APP_NAME}"
            COMMAND ${LEGATO_TOOL_INSTAPP} ${APP_PKG} ${TARGET_IP}
            WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
            DEPENDS ${APP_PKG}
   )

   message("-- you may install ${APP_PKG} on ${TARGET_IP} via 'make install_${APP_NAME}'")

endfunction()


# generate files for legato services from legato *.api-files
# API_FILE contains the full path to the *.api-file
# SRCS will contain the generated sources after this call
# To use the API you have to do the following two things
# - include ${SRCS} to your project sources
# - add the library "iface_legato_{API_NAME}_{srv/client}" to
#   the projects libraries and make the project depending on this library
# DEST must contain the full path, where the interface files should be generated
# IMPORT_DIR include directory for ifgen call
function(add_legato_ifgen_srv API_FILE SRCS DEST IMPORT_DIR)

   get_filename_component(API_NAME ${API_FILE} NAME_WE)
   message(STATUS "Generate Legato Server API: API_FILE: ${API_FILE} API_NAME: ${API_NAME}")

   if(IMPORT_DIR STREQUAL "")
      add_custom_target("iface_legato_${API_NAME}_srv"
               COMMAND ifgen --gen-server-interface --gen-server --gen-local
                        --output-dir ${DEST}
                        ${API_FILE}
               DEPENDS ${API_FILE}
      )
   else()
      add_custom_target("iface_legato_${API_NAME}_srv"
               COMMAND ifgen --gen-server-interface --gen-server --gen-local
                        --output-dir ${DEST}
                        --import-dir ${IMPORT_DIR}
                        ${API_FILE}
               DEPENDS ${API_FILE}
      )
   endif()
   
   set(GEN_SRCS
      "${DEST}/${API_NAME}_messages.h"
      "${DEST}/${API_NAME}_server.h"
      "${DEST}/${API_NAME}_server.c"
   )

   set_source_files_properties(${GEN_SRCS} PROPERTIES GENERATED TRUE)

   set(${SRCS} ${GEN_SRCS} PARENT_SCOPE)

endfunction()


# generate files for legato services from legato *.api-files
# API_FILE contains the full path to the *.api-file
# SRCS will contain the generated sources after this call
# To use the API you have to do the following two things
# - include ${SRCS} to your project sources
# - add the library "iface_legato_{API_NAME}_{srv/client}" to
#   the projects libraries and make the project depending on this library
# DEST must contain the full path, where the interface files should be generated
# IMPORT_DIR include directory for ifgen call
function(add_legato_ifgen_client API_FILE SRCS DEST IMPORT_DIR)

   get_filename_component(API_NAME ${API_FILE} NAME_WE)
   message(STATUS "Generate Legato Client API: API_FILE: ${API_FILE} API_NAME: ${API_NAME}")

   if(IMPORT_DIR STREQUAL "")
      add_custom_target("iface_legato_${API_NAME}_client"
               COMMAND ifgen --gen-interface --gen-client --gen-local
                        --output-dir ${DEST}
                        ${API_FILE}
               DEPENDS ${API_FILE}
      )
   else()
      add_custom_target("iface_legato_${API_NAME}_client"
               COMMAND ifgen --gen-interface --gen-client --gen-local
                        --output-dir ${DEST}
                        --import-dir ${IMPORT_DIR}
                        ${API_FILE}
               DEPENDS ${API_FILE}
      )
   endif()

   set(GEN_SRCS
      "${DEST}/${API_NAME}_messages.h"
      "${DEST}/${API_NAME}_interface.h"
      "${DEST}/${API_NAME}_client.c"
   )

   set_source_files_properties(${GEN_SRCS} PROPERTIES GENERATED TRUE)

   set(${SRCS} ${GEN_SRCS} PARENT_SCOPE)

endfunction()
