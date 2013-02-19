Prereqs
===

First you must install *XCode* from the *App Store* and
*Command Line Tools* from <https://developer.apple.com/downloads/>

The rest of the pre-reqs can be installed by the installer script, which can be run like so:

    bash build.osx.sh

Installation
===

NOTE:
**UNFORTUNATELY** the installer doesn't automatically handle some known bugs,
so a few fixes must be applied by hand (as noted in the fixes section).

Once the build tools are installed, you can continue to install the direct dependencies
of the project with the installer script.

    LDFLAGS="-L/usr/local/Cellar/fontconfig/2.8.0/lib ${LDFLAGS}"
    CPPFLAGS="-I/usr/local/Cellar/fontconfig/2.8.0/include ${LDFLAGS}"
    bash build-deps.sh

Assuming all of the dependencies installed correctly,
you can build the core products and install them like so:

    make mediabox
    make install

Fixes
===

pdftags / poppler
---

Use `build-deps.sh` to download the source for libpoppler (and comment it out once it fails),
but actually install it using **homebrew** and  to compile poppler rather than using 

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
