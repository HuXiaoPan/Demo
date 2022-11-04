#ifndef NA_SYS_NEUTRINO_H_WRAPPER_INCLUDED_
#define NA_SYS_NEUTRINO_H_WRAPPER_INCLUDED_

#include_next <sys/neutrino.h>

#ifdef major
   #undef major
#endif
#ifdef minor
   #undef minor
#endif

#endif
