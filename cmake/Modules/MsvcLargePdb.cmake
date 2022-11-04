# MS Visual C helper: Create PDB files with max size of 2GB
# Before VS2013 Update 2 the Linker used 2K pages with up to 1GB max size
#
# For details see
# http://stackoverflow.com/questions/16308861/lnk1201-visual-c-2010-large-project-failing-to-generate-pdb
#
# Usage Example:
# --------------------------------------------------------------------------------
# include(MsvcLargePdb)
#
# add_executable(hello ...)
# CreateLargePdb(hello)
# --------------------------------------------------------------------------------

if(na_MsvcLargePdb_INCLUDED)
  return()
endif()
SET(na_MsvcLargePdb_INCLUDED 1)

MACRO( CreateLargePdb BuildTarget )
   # Linker in VS2013 (Update 2) has been fixed, only handle older versions
   if(MSVC AND (MSVC_VERSION LESS 1800))
      # First get the target name
      get_target_property(local_target_file ${BuildTarget} LOCATION)
      # need to replace the configuration by current build type
      STRING(REPLACE "$(Configuration)" "${CMAKE_BUILD_TYPE}" local_EXE ${local_target_file})
      # replace .exe/.dll by .pdb
      STRING(REGEX REPLACE "[.]exe" ".pdb" local_TMP ${local_EXE})
      STRING(REGEX REPLACE "[.]dll" ".pdb" local_PDB ${local_TMP})
      #message(STATUS "LOCATION: ${local_target_file}")
      #message(STATUS "target  : ${local_EXE}")
      #message(STATUS "PDB name: ${local_PDB}")
      set(local_NEED_PDB FALSE)
      if (EXISTS "${local_PDB}")
         #message(STATUS "${local_PDB} already exists")
         # Check in pdb header if pagesize is 4K  (0x1000 -> 0010 little endian)
         file(READ "${local_PDB}" PDB_PAGESIZE LIMIT 2 OFFSET 32 HEX)
         #message(STATUS "PDB_PAGESIZE: ${PDB_PAGESIZE}")
         if (NOT "${PDB_PAGESIZE}" STREQUAL "0010")
            message(STATUS "Pagesize of ${local_PDB} not 4K, re-create")
            set(local_NEED_PDB TRUE)
            file(REMOVE "${local_PDB}")
         endif()
      else()
         message(STATUS "${local_PDB} not found, create")
         set(local_NEED_PDB TRUE)
      endif()
      if (local_NEED_PDB)
        file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/dummy_empty.cpp)
        execute_process(COMMAND ${CMAKE_CXX_COMPILER} /nologo /c "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/dummy_empty.cpp" /Zi /Fd${local_PDB}
                        RESULT_VARIABLE result_BUILD_PDB)
        file(REMOVE ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/dummy_empty.cpp)
        if (result_BUILD_PDB)
           message(WARNING "Building PDB failed")
           message(STATUS "Command line: ${CMAKE_CXX_COMPILER} /nologo /c ${CMAKE_CURRENT_BINARY_DIR}/dummy_empty.cpp /Zi /Fd${local_PDB}")
        elseif(NOT EXISTS "${local_PDB}")
           message(WARNING "PDB ${local_PDB} not found after compiler run")
           message(STATUS "Command line: ${CMAKE_CXX_COMPILER} /nologo /c ${CMAKE_CURRENT_BINARY_DIR}/dummy_empty.cpp /Zi /Fd${local_PDB}")
        endif()
         # Ensure the target is removed so we get linker run
         # with the new pdb file
         if (EXISTS "${local_EXE}")
            file(REMOVE "${local_EXE}")
         endif()
      endif()
   endif()
ENDMACRO( CreateLargePdb )
