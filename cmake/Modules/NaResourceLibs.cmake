# Simplify handling of resource libraries

cmake_minimum_required(VERSION 2.8)

function(na_add_resource_library targetname)
   add_library(${targetname} ${ARGN})
   set_target_properties(${targetname}
                         PROPERTIES FOLDER "Resources")
endfunction()
