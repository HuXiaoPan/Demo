#ifndef NA_ASMN_PAGE_H_WRAPPER_INCLUDED_
#define NA_ASMN_PAGE_H_WRAPPER_INCLUDED_

#include <android/api-level.h>

#if defined(__ANDROID_API__) && __ANDROID_API__ >= 20
/* asm/page.h no longer supported, get definitions from limits.h */
#include <limits.h>
#else
#include_next <asm/page.h>
#endif

#endif
