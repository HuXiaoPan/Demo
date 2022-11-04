/**
 *  Project: i-Navi
 * (c) copyright 2015
 *  
 * All rights reserved
 */
#ifndef _NA_CMAKE_COMPILER_MSVC_VS10_INTTYPES_H_
#define _NA_CMAKE_COMPILER_MSVC_VS10_INTTYPES_H_

// from http://pubs.opengroup.org/onlinepubs/009695399/basedefs/inttypes.h.html:
// "The <inttypes.h> header shall include the <stdint.h> header."
#include <stdint.h>

/**
 * This header provides functions and definitions expected to be found in <inttypes.h> which
 * is completely absent from Visual Studio 10 (2010).
 */
 
#define PRId8  "d"
#define PRIi8  "i"
#define PRIu8  "u"
#define PRIo8  "o"
#define PRIx8  "x"
#define PRIX8  "x"

#define PRId16 "d"
#define PRIi16 "i"
#define PRIu16 "u"
#define PRIo16 "o"
#define PRIx16 "x"
#define PRIX16 "X"

#define PRId32 "I32d"
#define PRIi32 "I32i"
#define PRIu32 "I32u"
#define PRIo32 "I32o"
#define PRIx32 "I32x"
#define PRIX32 "I32X"

#define PRId64 "I64d"
#define PRIi64 "I64i"
#define PRIu64 "I64u"
#define PRIo64 "I64o"
#define PRIx64 "I64x"
#define PRIX64 "I64X"

// ARG! Scanning of 8-bit values is not supported by MSVC

#define SCNd16 "hd"
#define SCNi16 "hi"
#define SCNu16 "hu"
#define SCNo16 "ho"
#define SCNx16 "hx"

#define SCNd32 "I32d"
#define SCNi32 "I32i"
#define SCNu32 "I32u"
#define SCNo32 "I32o"
#define SCNx32 "I32x"

#define SCNd64 "I64d"
#define SCNi64 "I64i"
#define SCNu64 "I64u"
#define SCNo64 "I64o"
#define SCNx64 "I64x"

// [u]intptr_t support
#ifdef _WIN64
#define _NA_PFX_PTR_  "ll"
#else
#define _NA_PFX_PTR_  "l"
#endif

#define PRIiPTR      _NA_PFX_PTR_ "i"
#define PRIoPTR      _NA_PFX_PTR_ "o"
#define PRIuPTR      _NA_PFX_PTR_ "u"
#define PRIxPTR      _NA_PFX_PTR_ "x"
#define PRIXPTR      _NA_PFX_PTR_ "X"

#define SCNdPTR      _NA_PFX_PTR_ "d"
#define SCNiPTR      _NA_PFX_PTR_ "i"
#define SCNoPTR      _NA_PFX_PTR_ "o"
#define SCNuPTR      _NA_PFX_PTR_ "u"
#define SCNxPTR      _NA_PFX_PTR_ "x"

#endif //_NA_CMAKE_COMPILER_MSVC_VS10_INTTYPES_H_
