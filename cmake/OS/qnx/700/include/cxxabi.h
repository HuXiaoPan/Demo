/**
 *  Project: i-Navi
 *  
 *
 * (c) Copyright 2015
 *
 * All rights reserved.
 */

// Currently we only need the __cxa_demangle

#ifndef NA_QNX_CXXABI_H_INCLUDED_
#define NA_QNX_CXXABI_H_INCLUDED_

#include <malloc.h>
namespace abi
{
   extern "C" char* __cxa_demangle (const char* mangled_name, char* buf, size_t* n, int* status);
}

#endif
