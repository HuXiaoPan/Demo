#ifndef NA_SYS_TYPES_H_WRAPPER_INCLUDED_
#define NA_SYS_TYPES_H_WRAPPER_INCLUDED_

#include_next <sys/types.h>

#ifdef major
#undef major
#endif
#ifdef minor
#undef minor
#endif

#endif