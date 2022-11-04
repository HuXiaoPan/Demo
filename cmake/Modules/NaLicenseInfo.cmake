# Helper to define the license information for external libraries
#
# Usage Example:
# --------------------------------------------------------------------------------
#   include(NaLicenseInfo)
#
#   NaProvideLicenseInfo(<component> <license-header-file> <license-body-file>)
#
#   # enable the next line to create a single license
#   # info file for each component in the given directory
#   #set(NaLicenseInfoDebugPath "${CMAKE_CURRENT_BINARY_DIR}/debug")
#
#   NaCreateLicenseFile(<file>)
#
#   # Show all modules with license info
#   NaCreateLicenseOverview(<file>)
# --------------------------------------------------------------------------------

if(na_NaLicenseInfo_INCLUDED)
  return()
endif()
SET(na_NaLicenseInfo_INCLUDED 1)

unset(NaLicenseInfo_List)
unset(NaLicenseInfo_List CACHE)
get_directory_property(_hasParent PARENT_DIRECTORY)
if(_hasParent)
   unset(NaLicenseInfo_List PARENT_SCOPE)
endif()

function(NaAddSingleLicenseInfo _comp LicenseFile_)
   if(DEFINED NA_LICENSE_HEADER_${_comp})
      file(APPEND ${LicenseFile_} "\n")
      file(APPEND ${LicenseFile_} "--------------------------------------------------------------------------------\n") # 80 dashes
      file(READ ${NA_LICENSE_HEADER_${_comp}} _header)
      file(APPEND ${LicenseFile_} "${_header}")
      file(APPEND ${LicenseFile_} "--------------------------------------------------------------------------------\n") # 80 dashes
      unset(_header)
   endif()
   if(DEFINED NA_LICENSE_BODY_${_comp})
      set(_first TRUE)
      foreach(_lic_body ${NA_LICENSE_BODY_${_comp}})
         file(READ ${_lic_body} _body)
         if(_first)
            set(_first FALSE)
         else()
            file(APPEND ${LicenseFile_} "\n--------------------------------------------------------------------------------") # 80 dashes
         endif()
         file(APPEND ${LicenseFile_} "\n${_body}")
         unset(_body)
      endforeach()
   endif()
endfunction(NaAddSingleLicenseInfo)

function(NaCreateLicenseFile LicenseFile_)
   file(WRITE ${LicenseFile_} "This product uses the following third party software:\n")
   if(NaLicenseInfo_List)
      set(_info_list ${NaLicenseInfo_List})
      list(SORT _info_list)
      #message(STATUS "NaLicenseInfo_List: ${_info_list}")
      foreach(_comp ${_info_list})
         NaAddSingleLicenseInfo(${_comp} ${LicenseFile_})
         if(NaLicenseInfoDebugPath)
            get_filename_component(debug_license_out "${NaLicenseInfoDebugPath}/lic_${_comp}.txt" ABSOLUTE)
            file(REMOVE ${debug_license_out})
            NaAddSingleLicenseInfo(${_comp} ${debug_license_out})
         endif()
      endforeach()
   endif()
   list(LENGTH NaLicenseInfo_List _NaLicenseInfo_List_count_)
   message(STATUS "Copied ${_NaLicenseInfo_List_count_} license infos to ${LicenseFile_}")
endfunction(NaCreateLicenseFile)

function(NaCreateLicenseOverview OverviewFile_)
   file(WRITE ${OverviewFile_} "This product uses the following third party software:\n")
   if(NaLicenseInfo_List)
      set(_info_list ${NaLicenseInfo_List})
      list(SORT _info_list)
      #message(STATUS "NaLicenseInfo_List: ${_info_list}")
      foreach(_comp ${_info_list})
         if(DEFINED NA_LICENSE_HEADER_${_comp})
            file(READ ${NA_LICENSE_HEADER_${_comp}} _header)
            file(APPEND ${OverviewFile_} "${_header}")
            unset(_header)
         endif()
      endforeach()
   endif()
   list(LENGTH NaLicenseInfo_List _NaLicenseInfo_List_count_)
   message(STATUS "Listed ${_NaLicenseInfo_List_count_} modules in ${OverviewFile_}")
endfunction(NaCreateLicenseOverview)

MACRO(NaProvideLicenseInfo CompShortCut_ LicenseHeaderFile_ LicenseBodyFile_)
   set(_licensebodyfile ${LicenseBodyFile_})
   # Look for additional license files
   set(_argn "${ARGN}")
   if (_argn)
      foreach(_f ${_argn})
         list(APPEND _licensebodyfile ${_f})
      endforeach()
   endif()

   # Adjust list of components
   list(FIND NaLicenseInfo_List ${CompShortCut_} _index)
   if (${_index} GREATER -1)
      message(WARNING "NaProvideLicenseInfo: External '${CompShortCut_}' has already been defined! (@${_index})")
   else()
      # Prepare in current scope
      set(_info_list ${NaLicenseInfo_List})
      list(APPEND _info_list ${CompShortCut_})

      # Update list in cache to emulate global variable
      set(NaLicenseInfo_List "${_info_list}" CACHE INTERNAL "component list for license info")
   endif()

   # Set component specific variables in cache to emulate global variables
   set(NA_LICENSE_HEADER_${CompShortCut_} "${LicenseHeaderFile_}" CACHE INTERNAL "${CompShortCut_} license header file")
   set(NA_LICENSE_BODY_${CompShortCut_}   "${_licensebodyfile}"   CACHE INTERNAL "${CompShortCut_} license body file(s)")
ENDMACRO(NaProvideLicenseInfo)
