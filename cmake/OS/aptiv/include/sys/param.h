#ifndef NA_SYS_PARAM_H_WRAPPER_INCLUDED_
#define NA_SYS_PARAM_H_WRAPPER_INCLUDED_

#include_next <sys/param.h>

#ifdef major
   #undef major
#endif
#ifdef minor
   #undef minor
#endif

#endif
