# Asciidoc
# This module looks for asciidoc and a2napdf
# Special targets "doc_pdf" and "doc_html" are created to build all documents of
# the specific type. Use "all" to build all documents.
#
# Usage Example:
# --------------------------------------------------------------------------------
# find_package(Asciidoc REQUIRED 0.9.2)
#
# AsciiDoc_Generate_PDF(architecture_pdf
#                       architecture_specification.adoc
#                       development_guidelines.adoc
#                       rfc2119.adoc)
#
# AsciiDoc_Generate_HTML(genivi_html
#                        genivi/GENIVI-Collaboration-Workflow.adoc)
# --------------------------------------------------------------------------------
#
# ASCIIDOC_EXECUTABLE    - the full path to asciidoc
# ASCIIDOC_FOUND         - If false, don't attempt to use asciidoc.
# A2NAPDF_SCRIPT         - the full path to a2napdf
# A2NAPDF_FOUND          - If false, don't attempt to use a2napdf.
#
# ASCIIDOC_GENERATE_PDF  - function to generate pdfs from adoc files.
# ASCIIDOC_GENERATE_HTML - function to generate html from adoc files.

cmake_minimum_required(VERSION 2.8)

# Version number of the EDT customized asciidoc toolchain. Defaults to 0.0.0 
# In case an 'out of the box' asciidoc toolchain is used the default 0.0.0 will identify that.
set(ASCIIDOC_VERSION 10.0.2)

find_program(ASCIIDOC_EXECUTABLE NAMES asciidoc asciidoc.py asciidoc.bat)
find_program(A2NAPDF_SCRIPT NAMES a2napdf.sh a2napdf.bat)
find_program(ASCIIDOCTOR_EXECUTABLE NAMES asciidoctor)
if(ASCIIDOCTOR_EXECUTABLE)
   get_filename_component(adoctorexe_dir ${ASCIIDOCTOR_EXECUTABLE} DIRECTORY)
endif()

if(ASCIIDOC_EXECUTABLE)
   # Find the Readme.adoc file (EDT customized toolchain has that) in parent dir of ASCIIDOC_EXECUTABLE.
   # If it exists parse it for version number <Major>.<Minor>.<patch>.
   # Else set ASCIIDOC_VERSION to 0.0.0 to mark an unknown, probably non customized, toolchain.
   # TODO (MKindel 2017-02-15): Define a Linux rollout of the EDT toolchain and add the version parsing for that.
   set(version_regex "^[ \\t]*:version:[ \\t]*([0-9]+\\.[0-9]+\\.[0-9]+)")

   get_filename_component(adocexe_dir ${ASCIIDOC_EXECUTABLE} DIRECTORY)
   if(EXISTS "${adocexe_dir}/../Readme.adoc")
      file(STRINGS "${adocexe_dir}/../Readme.adoc" version_string REGEX "${version_regex}")
      if(version_string)
         string(REGEX REPLACE "${version_regex}" "\\1" ASCIIDOC_VERSION ${version_string})
      endif()
   endif()
   unset(adocexe_dir)
   unset(version_regex)
   unset(version_string)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_ARGS(AsciiDoc REQUIRED_VARS ASCIIDOC_EXECUTABLE
                                           VERSION_VAR ASCIIDOC_VERSION)
find_package_handle_standard_ARGS(AsciiDocScript REQUIRED_VARS A2NAPDF_SCRIPT)
mark_as_advanced(ASCIIDOC_EXECUTABLE A2NAPDF_SCRIPT ASCIIDOCTOR_EXECUTABLE)

if (A2NAPDF_SCRIPT)
   set(A2NAPDF_FOUND TRUE)
endif()

# Creates an X.pdf file from each given X.adoc document input file.
# All targets (X.pdf) are added to the target given by PDF_TARGET.
# The PDF_TARGET target is added to the "doc_pdf" target (build all
# pdf documents).
function(ASCIIDOC_GENERATE_PDF PDF_TARGET)
   if(NOT ARGN)
      message(SEND_ERROR "Error: ASCIIDOC_GENERATE_PDF() called without any files")
      return()
   endif()

   if(NOT A2NAPDF_FOUND)
      message(WARNING "script a2napdf not found, cannot generate PDF documentation")
      return()
   endif()

   # convert adoc -> pdf
   foreach(adoc ${ARGN})

      get_filename_component(path_adoc ${adoc} ABSOLUTE)
      get_filename_component(dir_adoc ${adoc} PATH)

      string(REGEX REPLACE "(.*)\\.adoc" "\\1.pdf" pdf ${adoc})
      string(REGEX REPLACE ".*/(.*)\\.adoc" "\\1.pdf" target ${adoc})
      string(REPLACE "/" "." target ${pdf})

      set(doc_output_base_path "${CMAKE_CURRENT_BINARY_DIR}/doc/pdf")

      file(MAKE_DIRECTORY ${doc_output_base_path}/${dir_adoc})
      # message(STATUS "Processing Target ${target} : ${adoc} -> ${pdf} : DIR ${dir_adoc} PATH ${path_adoc} OUT_BASE ${doc_output_base_path}")

      parseImageIncludes(${path_adoc})

      add_custom_command(
         OUTPUT "${doc_output_base_path}/${pdf}"
         COMMAND ${A2NAPDF_SCRIPT} ${path_adoc} ${doc_output_base_path}/${dir_adoc}
         DEPENDS ${path_adoc} ${images_included}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${dir_adoc}
         COMMENT "Generating ${pdf}"
         SOURCES ${adoc} ${images_included}
      )
      add_custom_target(${target} DEPENDS "${doc_output_base_path}/${pdf}")

      set_target_properties(${target} PROPERTIES FOLDER "Documentation/${PDF_TARGET}")

      list(APPEND pdf_targets ${target})

      # add generated files to clean target
      string(REGEX REPLACE "(.*)\\.pdf" "${doc_output_base_path}/\\1.fo" fo ${pdf})
      string(REGEX REPLACE "(.*)\\.pdf" "${doc_output_base_path}/\\1.xml" xml ${pdf})
      list(APPEND clean_files "${fo}" "${xml}" "${doc_output_base_path}/${pdf}")
   endforeach()

   if (NOT TARGET ${PDF_TARGET})
      add_custom_target(${PDF_TARGET})
      set_target_properties(${PDF_TARGET} PROPERTIES FOLDER "Documentation/${PDF_TARGET}")
   endif()
   add_dependencies(${PDF_TARGET} ${pdf_targets})

   if (NOT TARGET doc_pdf)
      add_custom_target(doc_pdf)
      set_target_properties(doc_pdf PROPERTIES FOLDER "Documentation")
   endif()
   add_dependencies(doc_pdf ${PDF_TARGET})
   add_dependencies(doc doc_pdf)

   list(REMOVE_DUPLICATES clean_files)
   set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES "${clean_files}")
endfunction()







function(ASCIIDOCTOR_GENERATE_HTML HTML_TARGET)
   if(NOT ARGN)
      message(SEND_ERROR "Error: ASCIIDOCTOR_GENERATE_HTML() called without any files")
      return()
   endif()
   
   if(NOT ASCIIDOC_FOUND)
      message(WARNING "AsciiDoc not found, cannot generate HTML documentation")
      return()
   endif()
   
   foreach(adoc ${ARGN})
      get_filename_component(path_adoc ${adoc} ABSOLUTE)
      get_filename_component(dir_adoc ${adoc} PATH)     

      string(REGEX REPLACE "(.*)\\.adoc" "\\1.html" html ${adoc})
      string(REGEX REPLACE ".*/(.*)\\.adoc" "\\1.html" target ${adoc})
      string(REPLACE "/" "." target ${html})

      set(doc_output_base_path "${CMAKE_CURRENT_BINARY_DIR}/doc/html")

      # create destination and copy image files
      file(MAKE_DIRECTORY ${doc_output_base_path}/${dir_adoc})

      parseImageIncludes(${path_adoc})

      if(NOT dir_adoc)
         set(dir_adoc ".")
      endif(NOT dir_adoc)

      foreach(image ${images_included})
         string(REPLACE "${CMAKE_CURRENT_SOURCE_DIR}" "" image_rel_path ${image})
         configure_file("${dir_adoc}/${image}" "${doc_output_base_path}/${dir_adoc}/${image_rel_path}" COPYONLY)
         # add image to "make clean" file list
         list(APPEND clean_files "${doc_output_base_path}/${dir_adoc}/${image_rel_path}")
      endforeach(image ${images_included})

      add_custom_command(
         OUTPUT "${doc_output_base_path}/${html}"
         COMMAND ${ASCIIDOCTOR_EXECUTABLE}
            -r asciidoctor-diagram
            --out-file="${doc_output_base_path}/${html}"
            "${path_adoc}"
         DEPENDS ${path_adoc} ${images_included}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${dir_adoc}
         COMMENT "Generating ${html}"
         SOURCES ${adoc} ${images_included}
      )

      add_custom_target(${target} DEPENDS "${doc_output_base_path}/${html}")

      set_target_properties(${target} PROPERTIES FOLDER "Documentation/${HTML_TARGET}")

      list(APPEND html_targets ${target})

      # add generated files to clean target
      list(APPEND clean_files "${doc_output_base_path}/${html}")
   endforeach(adoc ${ARGN})

   if (NOT TARGET ${HTML_TARGET})
      add_custom_target(${HTML_TARGET} DEPENDS ${html_targets})
      set_target_properties(${HTML_TARGET} PROPERTIES FOLDER "Documentation/${HTML_TARGET}")
   endif()

   if(NOT TARGET doc_html)
      add_custom_target(doc_html)
      set_target_properties(doc_html PROPERTIES FOLDER "Documentation")
   endif()
   add_dependencies(doc_html ${HTML_TARGET})
   add_dependencies(doc doc_html)

   list(REMOVE_DUPLICATES clean_files)
   set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES "${clean_files}")
endfunction(ASCIIDOCTOR_GENERATE_HTML HTML_TARGET)

# Creates an X.html file from each given X.adoc document input file.
# All targets (X.html) are added to the target given by HTML_TARGET.
# The HTML_TARGET target is added to the "doc_html" target (build all
# html documents).
function(ASCIIDOC_GENERATE_HTML HTML_TARGET)
   if(NOT ARGN)
      message(SEND_ERROR "Error: ASCIIDOC_GENERATE_HTML() called without any files")
      return()
   endif()

   if(NOT ASCIIDOC_FOUND)
      message(WARNING "AsciiDoc not found, cannot generate HTML documentation")
      return()
   endif()

   foreach(adoc ${ARGN})
   
      get_filename_component(path_adoc ${adoc} ABSOLUTE)
      get_filename_component(dir_adoc ${adoc} PATH)     

      string(REGEX REPLACE "(.*)\\.adoc" "\\1.html" html ${adoc})
      string(REGEX REPLACE ".*/(.*)\\.adoc" "\\1.html" target ${adoc})
      string(REPLACE "/" "." target ${html})

      set(doc_output_base_path "${CMAKE_CURRENT_BINARY_DIR}/doc/html")

      # create destination and copy image files
      file(MAKE_DIRECTORY ${doc_output_base_path}/${dir_adoc})

      parseImageIncludes(${path_adoc})

      if(NOT dir_adoc)
         set(dir_adoc ".")
      endif(NOT dir_adoc)

      foreach(image ${images_included})
         string(REPLACE "${CMAKE_CURRENT_SOURCE_DIR}" "" image_rel_path ${image})
         configure_file("${dir_adoc}/${image}" "${doc_output_base_path}/${dir_adoc}/${image_rel_path}" COPYONLY)
         # add image to "make clean" file list
         list(APPEND clean_files "${doc_output_base_path}/${dir_adoc}/${image_rel_path}")
      endforeach(image ${images_included})

      add_custom_command(
         OUTPUT "${doc_output_base_path}/${html}"
         COMMAND ${ASCIIDOC_EXECUTABLE}
            -b xhtml11
            -a data-uri
            -a icons
            -a toc2
            -a numbered
            -a imagesdir="."
            # TODO (MKindel 2017-02-15): Create a new 'EDT' theme (in EDT toolchain) and use that.
            --theme flask
            --out-file="${doc_output_base_path}/${html}"
            "${path_adoc}"
         DEPENDS ${path_adoc} ${images_included}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${dir_adoc}
         COMMENT "Generating ${html}"
         SOURCES ${adoc} ${images_included}
      )

      add_custom_target(${target} DEPENDS "${doc_output_base_path}/${html}")

      set_target_properties(${target} PROPERTIES FOLDER "Documentation/${HTML_TARGET}")

      list(APPEND html_targets ${target})

      # add generated files to clean target
      list(APPEND clean_files "${doc_output_base_path}/${html}")
   endforeach(adoc ${ARGN})

   if (NOT TARGET ${HTML_TARGET})
      add_custom_target(${HTML_TARGET} DEPENDS ${html_targets})
      set_target_properties(${HTML_TARGET} PROPERTIES FOLDER "Documentation/${HTML_TARGET}")
   endif()

   if(NOT TARGET doc_html)
      add_custom_target(doc_html)
      set_target_properties(doc_html PROPERTIES FOLDER "Documentation")
   endif()
   add_dependencies(doc_html ${HTML_TARGET})
   add_dependencies(doc doc_html)

   list(REMOVE_DUPLICATES clean_files)
   set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES "${clean_files}")
endfunction(ASCIIDOC_GENERATE_HTML HTML_TARGET)

####################################
# HELPER
####################################

function(parseDocIncludes doc_to_parse)
      file(STRINGS "${doc_to_parse}" in_file})
      foreach(line ${in_file})
         string(REGEX MATCH "include::.*$" include_line ${line})
         if(include_line)
            string(REGEX REPLACE "^.*::" "" include_tmp ${include_line})
            string(REGEX REPLACE "\\[.*$" "" include_file ${include_tmp})
            list(APPEND docs_found ${include_file})
         endif(include_line)
      endforeach(line ${in_file})
      set(docs_included ${docs_found} PARENT_SCOPE)
      #message(STATUS "${doc_to_parse} file entries: ${docs_included}")
endfunction(parseDocIncludes doc_to_parse)

function(parseImageIncludes doc_to_parse)
   file(STRINGS "${doc_to_parse}" in_file)
      foreach(line ${in_file})
         string(REGEX MATCH "image::.*$" image_line ${line})
         if(image_line)
            string(REGEX REPLACE "^.*::" "" image_tmp ${image_line})
            string(REGEX REPLACE "\\[.*$" "" image_file ${image_tmp})
            list(APPEND images_found ${image_file})
         endif(image_line)
      endforeach(line ${in_file})
      set(images_included ${images_found} PARENT_SCOPE)
      #message(STATUS "${doc_to_parse} image entries: ${images_found}")
endfunction(parseImageIncludes doc_to_parse)

