Prereqs
===

    brew install hg
    brew install poppler

Fixes
===

m4atags / AtomicParsley
---

There's currently no work-around to build the real `m4atags` from 
source so there's a nodejs shim around AtomicParsely.

  * md5sums aren't the same
  * art output very nearly works (has a few trailing bytes that seem to work)

Comment out AtomicParsley stuff at the bottom in `build-deps.sh`

    brew install hg
    hg clone https://bitbucket.org/wez/atomicparsley
    cd atomicparsley/
    autoconf & automake
    ./configure  --disable-universal
    make
    make install
    AtomicParsley 

pdftags / poppler
---

Use `build-deps.sh` to download the source for libpoppler (and comment it out once it fails),
but actually install it using `homebrew` and  to compile poppler rather than using 

    brew install poppler
    LDFLAGS="-L/usr/local/Cellar/fontconfig/2.8.0/lib ${LDFLAGS}"
    CPPFLAGS="-I/usr/local/Cellar/fontconfig/2.8.0/include ${LDFLAGS}"

_Bool has not been declared
---

    /usr/local/include/mutils/mutils.h:250: error: '_Bool' has not been declared

/usr/local/include/mutils/mutils.h:

    #if !defined(__MUTILS_H)
    #define __MUTILS_H

    // Added to satisfy OS X
    #if !defined(_Bool)
    #define _Bool bool
    #endif
    // End custom addition

    #include <mutils/mincludes.h>

    #if defined(const)
    #define __const const
    #endif 

'basename' has not been declared
---

id3/id3tagjson.cpp:

    #include <libgen.h>
