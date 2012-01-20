Prereqs
===

    brew install hg
    brew install poppler

Fixes
===

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

id3/id3tagjson.cpp && m4a/m4atags.cpp;

    #include <libgen.h>

Other Tips
---

How to tell wether a library was compiled 32-bit or 64-bit?

OS X:

    file /path/to/object.o

CMake:

I did a lot of `grep`ing through `hg clone https://bitbucket.org/sinbad/ogre` to half-figure out 
the OS X framework includes and eventually got it right by trial and error.

The errors about libraries not available for x86_64 had nothing to do with i386 or 32-bit vs 64-bit
but rather that the CoreFoundation frameworks weren't being included
