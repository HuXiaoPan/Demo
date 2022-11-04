# see http://www.kitware.com/blog/home/post/390

function(echo_target_property tgt prop)
  # v for value, d for defined, s for set
  get_property(v TARGET ${tgt} PROPERTY ${prop})
  get_property(d TARGET ${tgt} PROPERTY ${prop} DEFINED)
  get_property(s TARGET ${tgt} PROPERTY ${prop} SET)

  # only produce output for values that are set
  if(s)
    message("tgt='${tgt}' prop='${prop}'")
    message("  value='${v}'")
    message("  defined='${d}'")
    message("  set='${s}'")
    message("")
  endif()
endfunction()


function(echo_source_property src prop)
  # v for value, d for defined, s for set
  get_property(v SOURCE ${src} PROPERTY ${prop})
  get_property(d SOURCE ${src} PROPERTY ${prop} DEFINED)
  get_property(s SOURCE ${src} PROPERTY ${prop} SET)

  # only produce output for values that are set
  if(s)
    message("src='${src}' prop='${prop}'")
    message("  value='${v}'")
    message("  defined='${d}'")
    message("  set='${s}'")
    message("")
  endif()
endfunction()

function(echo_global_property glb prop)
  # v for value, d for defined, s for set
  get_property(v GLOBAL ${glb} PROPERTY ${prop})
  get_property(d GLOBAL ${glb} PROPERTY ${prop} DEFINED)
  get_property(s GLOBAL ${glb} PROPERTY ${prop} SET)

  # only produce output for values that are set
  if(s)
    message("glb='${glb}' prop='${prop}'")
    message("  value='${v}'")
    message("  defined='${d}'")
    message("  set='${s}'")
    message("")
  endif()
endfunction()

# ---------------------------------------------------------
# ---------------------------------------------------------
# ---------------------------------------------------------

function(echo_target tgt)

  if(NOT TARGET ${tgt})
    message("There is no target named '${tgt}'")
    return()
  endif()

  set(props
DEBUG_OUTPUT_NAME
DEBUG_POSTFIX
RELEASE_OUTPUT_NAME
RELEASE_POSTFIX
ARCHIVE_OUTPUT_DIRECTORY
ARCHIVE_OUTPUT_DIRECTORY_DEBUG
ARCHIVE_OUTPUT_DIRECTORY_RELEASE
ARCHIVE_OUTPUT_NAME
ARCHIVE_OUTPUT_NAME_DEBUG
ARCHIVE_OUTPUT_NAME_RELEASE
AUTOMOC
AUTOMOC_MOC_OPTIONS
BUILD_WITH_INSTALL_RPATH
BUNDLE
BUNDLE_EXTENSION
COMPILE_DEFINITIONS
COMPILE_DEFINITIONS_DEBUG
COMPILE_DEFINITIONS_RELEASE
COMPILE_FLAGS
DEBUG_POSTFIX
RELEASE_POSTFIX
DEFINE_SYMBOL
ENABLE_EXPORTS
EXCLUDE_FROM_ALL
EchoString
FOLDER
FRAMEWORK
Fortran_FORMAT
Fortran_MODULE_DIRECTORY
GENERATOR_FILE_NAME
GNUtoMS
HAS_CXX
IMPLICIT_DEPENDS_INCLUDE_TRANSFORM
IMPORTED
IMPORTED_CONFIGURATIONS
IMPORTED_IMPLIB
IMPORTED_IMPLIB_DEBUG
IMPORTED_IMPLIB_RELEASE
IMPORTED_LINK_DEPENDENT_LIBRARIES
IMPORTED_LINK_DEPENDENT_LIBRARIES_DEBUG
IMPORTED_LINK_DEPENDENT_LIBRARIES_RELEASE
IMPORTED_LINK_INTERFACE_LANGUAGES
IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG
IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE
IMPORTED_LINK_INTERFACE_LIBRARIES
IMPORTED_LINK_INTERFACE_LIBRARIES_DEBUG
IMPORTED_LINK_INTERFACE_LIBRARIES_RELEASE
IMPORTED_LINK_INTERFACE_MULTIPLICITY
IMPORTED_LINK_INTERFACE_MULTIPLICITY_DEBUG
IMPORTED_LINK_INTERFACE_MULTIPLICITY_RELEASE
IMPORTED_LOCATION
IMPORTED_LOCATION_DEBUG
IMPORTED_LOCATION_RELEASE
IMPORTED_NO_SONAME
IMPORTED_NO_SONAME_DEBUG
IMPORTED_NO_SONAME_RELEASE
IMPORTED_SONAME
IMPORTED_SONAME_DEBUG
IMPORTED_SONAME_RELEASE
IMPORT_PREFIX
IMPORT_SUFFIX
INCLUDE_DIRECTORIES
INSTALL_NAME_DIR
INSTALL_RPATH
INSTALL_RPATH_USE_LINK_PATH
INTERPROCEDURAL_OPTIMIZATION
INTERPROCEDURAL_OPTIMIZATION_DEBUG
INTERPROCEDURAL_OPTIMIZATION_RELEASE
LABELS
LIBRARY_OUTPUT_DIRECTORY
LIBRARY_OUTPUT_DIRECTORY_DEBUG
LIBRARY_OUTPUT_DIRECTORY_RELEASE
LIBRARY_OUTPUT_NAME
LIBRARY_OUTPUT_NAME_DEBUG
LIBRARY_OUTPUT_NAME_RELEASE
LINKER_LANGUAGE
LINK_DEPENDS
LINK_FLAGS
LINK_FLAGS_DEBUG
LINK_FLAGS_RELEASE
LINK_INTERFACE_LIBRARIES
LINK_INTERFACE_LIBRARIES_DEBUG
LINK_INTERFACE_LIBRARIES_RELEASE
LINK_INTERFACE_MULTIPLICITY
LINK_INTERFACE_MULTIPLICITY_DEBUG
LINK_INTERFACE_MULTIPLICITY_RELEASE
LINK_LIBRARIES
LINK_SEARCH_END_STATIC
LINK_SEARCH_START_STATIC
LOCATION
LOCATION_DEBUG
LOCATION_RELEASE
MACOSX_BUNDLE
MACOSX_BUNDLE_INFO_PLIST
MACOSX_FRAMEWORK_INFO_PLIST
MAP_IMPORTED_CONFIG_DEBUG
MAP_IMPORTED_CONFIG_RELEASE
OSX_ARCHITECTURES
OSX_ARCHITECTURES_DEBUG
OSX_ARCHITECTURES_RELEASE
OUTPUT_NAME
OUTPUT_NAME_DEBUG
OUTPUT_NAME_RELEASE
POST_INSTALL_SCRIPT
PREFIX
PRE_INSTALL_SCRIPT
PRIVATE_HEADER
PROJECT_LABEL
PUBLIC_HEADER
RESOURCE
RULE_LAUNCH_COMPILE
RULE_LAUNCH_CUSTOM
RULE_LAUNCH_LINK
RUNTIME_OUTPUT_DIRECTORY
RUNTIME_OUTPUT_DIRECTORY_DEBUG
RUNTIME_OUTPUT_DIRECTORY_RELEASE
RUNTIME_OUTPUT_NAME
RUNTIME_OUTPUT_NAME_DEBUG
RUNTIME_OUTPUT_NAME_RELEASE
SKIP_BUILD_RPATH
SOURCES
SOVERSION
STATIC_LIBRARY_FLAGS
STATIC_LIBRARY_FLAGS_DEBUG
STATIC_LIBRARY_FLAGS_RELEASE
SUFFIX
TYPE
VERSION
VS_DOTNET_REFERENCES
VS_GLOBAL_WHATEVER
VS_GLOBAL_KEYWORD
VS_GLOBAL_PROJECT_TYPES
VS_KEYWORD
VS_SCC_AUXPATH
VS_SCC_LOCALPATH
VS_SCC_PROJECTNAME
VS_SCC_PROVIDER
VS_WINRT_EXTENSIONS
VS_WINRT_REFERENCES
WIN32_EXECUTABLE
XCODE_ATTRIBUTE_WHATEVER
)

  message("======================== ${tgt} ========================")
  foreach(p ${props})
    echo_target_property("${tgt}" "${p}")
  endforeach()
  message("")
endfunction()

# ---------------------------------------------------------
# ---------------------------------------------------------

function(echo_source src)
  set(props
    ABSTRACT
    AUTOUIC_OPTIONS
    AUTORCC_OPTIONS
    COMPILE_DEFINITIONS
#   COMPILE_DEFINITIONS_<CONFIG>
    COMPILE_DEFINITIONS_DEBUG
    COMPILE_DEFINITIONS_RELEASE
    COMPILE_FLAGS
    EXTERNAL_OBJECT
    Fortran_FORMAT
    GENERATED
    HEADER_FILE_ONLY
    KEEP_EXTENSION
    LABELS
    LANGUAGE
    LOCATION
    MACOSX_PACKAGE_LOCATION
    OBJECT_DEPENDS
    OBJECT_OUTPUTS
    SYMBOLIC
    WRAP_EXCLUDE
  )

  message("======================== ${src} ========================")
  foreach(p ${props})
    echo_source_property("${src}" "${p}")
  endforeach()
  message("")
endfunction()

# ---------------------------------------------------------
# ---------------------------------------------------------

function(echo_global glbl)
  set(props
    ALLOW_DUPLICATE_CUSTOM_TARGETS
    AUTOGEN_TARGETS_FOLDER
    AUTOMOC_TARGETS_FOLDER
    DEBUG_CONFIGURATIONS
    DISABLED_FEATURES
    ENABLED_FEATURES
    ENABLED_LANGUAGES
    FIND_LIBRARY_USE_LIB64_PATHS
    FIND_LIBRARY_USE_OPENBSD_VERSIONING
    GLOBAL_DEPENDS_DEBUG_MODE
    GLOBAL_DEPENDS_NO_CYCLES
    IN_TRY_COMPILE
    PACKAGES_FOUND
    PACKAGES_NOT_FOUND
    JOB_POOLS
    PREDEFINED_TARGETS_FOLDER
    ECLIPSE_EXTRA_NATURES
    REPORT_UNDEFINED_PROPERTIES
    RULE_LAUNCH_COMPILE
    RULE_LAUNCH_CUSTOM
    RULE_LAUNCH_LINK
    RULE_MESSAGES
    TARGET_ARCHIVES_MAY_BE_SHARED_LIBS
    TARGET_SUPPORTS_SHARED_LIBS
    USE_FOLDERS
  )

  message("======================== ${glbl} ========================")
  foreach(p ${props})
    echo_global_property("${glbl}" "${p}")
  endforeach()
  message("")
endfunction()

# ---------------------------------------------------------
# ---------------------------------------------------------

function(echo_targets)
  set(tgts ${ARGV})
  foreach(t ${tgts})
    echo_target("${t}")
  endforeach()
endfunction()

# ---------------------------------------------------------

function(echo_sources)
  set(srcs ${ARGV})
  foreach(s ${srcs})
    echo_source("${s}")
  endforeach()
endfunction()

# ---------------------------------------------------------

function(echo_globals)
  set(gl ${ARGV})
  foreach(g ${gl})
    echo_global("${g}")
  endforeach()
endfunction()

# ---------------------------------------------------------

