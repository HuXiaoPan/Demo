# set a variable only if undefined
#
# Usage example:
# include(NaTools)
# unset(VAR)
# SetIfUndefined(VAR "hello")
# message(STATUS "VAR: ${VAR}")
# SetIfUndefined(VAR "world!")
# message(STATUS "VAR: ${VAR}")
#
# Output:
#  VAR: hello
#  VAR: hello
#

cmake_minimum_required(VERSION 2.8)

macro(SetIfUndefined var_ value_)
   if (NOT DEFINED ${var_})
      set(${var_} ${value_})
   endif()
endmacro(SetIfUndefined)
