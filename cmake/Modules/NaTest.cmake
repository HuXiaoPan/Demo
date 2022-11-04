# - Simple test for EasyDrive software
#
# The 'NaTest_add_test' function wraps the standard cmake add_test() command
#  NaTest_add_test(<testname> [SOURCES src1 ...] [LIBS lib1 ...] [<add_test_args>*])
#
# Operation:
#  - adds an executable <testname> build from given SOURCES files
#  - links given libs LIBS to <testname>
#  - adds NA_TEST_COMPILE_FLAGS compile options to <testname> compilation
# If no COMMAND is specified in <add_test_args>
#  - calls add_test(NAME run_<testname> <add_test_args> COMMAND <testname>
# otherwise
#  - calls add_test(NAME run_<testname> <add_test_args>
#
# The 'NaTest_add_example' takes the same arguments as NaTest_add_test but
# add_test() command is only done if coverage compilation is active
#
# The 'NaTest_add_test_ext' takes the same arguments as NaTest_add_test but
# add_test() command is only done if coverage compilation or extended tests
# are active. Otherwise the executable build only.
#
# Variables:
#  NA_COVERAGE_BUILD : if set and TRUE executables added by NaTest_add_example() will be run as test
#  NA_EXTENDED_TESTS : if set and TRUE executables added by NaTest_add_test_ext() will be run as test
#  NA_DATABASE_TESTS : if set and TRUE executables added by NaTest_add_test_db() will be run as test
#
#  NA_COVERAGE_BUILD : if set and TRUE executables added by NaTest_add_test_DB() will be run as test
#                      if set and TRUE executables added by NaTest_add_test_ext() will be run as test
#                      if set and TRUE executables added by NaTest_add_example() will be run as test
#
# Usage example:
# include(NaTest)
# add_library(mylib mylib1.cpp)
# NaTest_add_test(test_mylib SOURCES simpletest.cpp LIBS mylib)
#

cmake_minimum_required(VERSION 2.8)

include(NaTargetLibs)

function(_NaTest_add_test_impl isTest testname group)
  set(SOURCES "")
  set(LIBS "")
  set(OTHERS "")
  set(MODE 0)
  set(HAVE_COMMAND 0)
  # optional CONFIGURATION command to add_test
  set(configurations "")
  foreach(arg IN LISTS ARGN)
    if("x${arg}" STREQUAL "xSOURCES")
      if (${MODE} LESS 1)
        set(MODE 1)
      else()
        message(FATAL_ERROR "Didn't expect SOURCES!")
        return()
      endif()
    elseif("x${arg}" STREQUAL "xLIBS")
      if (${MODE} LESS 2)
        set(MODE 2)
      else()
        message(FATAL_ERROR "Didn't expect LIBS!")
        return()
      endif()
    elseif(  "x${arg}" STREQUAL "xCONFIGURATIONS"
          OR "x${arg}" STREQUAL "xWORKING_DIRECTORY")
      set(MODE 99)
      list(APPEND OTHERS ${arg})
    elseif("x${arg}" STREQUAL "xCOMMAND")
      set(MODE 99)
      list(APPEND OTHERS ${arg})
      set(HAVE_COMMAND 1)
    elseif(${MODE} EQUAL 1)
      list(APPEND SOURCES ${arg})
    elseif(${MODE} EQUAL 2)
      list(APPEND LIBS ${arg})
    else()
      set(MODE 99)
      list(APPEND OTHERS ${arg})
    endif()
  endforeach()

  add_executable(${testname} ${SOURCES})
  if (NA_TEST_COMPILE_FLAGS)
    set_target_properties(${testname} PROPERTIES COMPILE_FLAGS ${NA_TEST_COMPILE_FLAGS})
  endif()
  if (LIBS)
    na_target_link_libraries(${testname} LIBS ${LIBS})
  endif()
  if (group)
    set_target_properties(${testname}
                          PROPERTIES FOLDER ${group})
  endif()
  if (${isTest})
     if (HAVE_COMMAND EQUAL 0)
        list(APPEND OTHERS "COMMAND" ${testname})
     endif()
     add_test(NAME run_${testname} ${OTHERS})
     #sadly, the following line isn't syntactically accepted by cmake:
     #add_dependencies(run_${testname} ${testname}) # before you can RUN a test, you need to BUILD it
   endif()
endfunction()

function(NaTest_add_test testname)
   _NaTest_add_test_impl(TRUE ${testname} "Tests" ${ARGN})
endfunction()

function(NaTest_add_test_ext testname)
   if (NA_COVERAGE_BUILD)
      _NaTest_add_test_impl(TRUE ${testname} "Tests" ${ARGN})
   elseif (NA_EXTENDED_TESTS)
      _NaTest_add_test_impl(TRUE ${testname} "Tests" ${ARGN})
   else()
      _NaTest_add_test_impl(FALSE ${testname} "Tests" ${ARGN})
   endif()
endfunction()

function(NaTest_add_test_db testname)
   if (NA_COVERAGE_BUILD)
      _NaTest_add_test_impl(TRUE ${testname} "Tests" ${ARGN})
   elseif (NA_DATABASE_TESTS)
      _NaTest_add_test_impl(TRUE ${testname} "Tests" ${ARGN})
   else()
      _NaTest_add_test_impl(FALSE ${testname} "Tests" ${ARGN})
   endif()
endfunction()

function(NaTest_add_example xmplname)
   if (NA_COVERAGE_BUILD)
      _NaTest_add_test_impl(TRUE ${xmplname} "Examples" ${ARGN})
   else()
      _NaTest_add_test_impl(FALSE ${xmplname} "Examples" ${ARGN})
   endif()
endfunction()


