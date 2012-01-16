Fixes
===

Comment out AtomicParsley stuff at the bottom in `build-deps.sh`

_Bool has not been declared
---

    /usr/local/include/mutils/mutils.h:250: error: '_Bool' has not been declared

mutils.h and mhash.h:

    #if !defined(_Bool)
    #define _Bool bool
    #endif

'basename' has not been declared
---

id3/id3tagjson.cpp:

    #include <libgen.h>
