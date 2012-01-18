#!/bin/bash
rm -rf "/tmp/mtags.*"

TMPD=`mktemp -d /tmp/mtags.XXXX` || echo 'failed to create tmpdir'
PWD=`pwd`

if [ "`uname -a | grep -i 'darwin'`" ]
then
  echo "OS X"
  PLAT="osx-lion"
elif [ "`uname -a | grep -i 'linux'`" ]
then
  echo "Linux"
  if [ "`arch | grep arm`" ]
  then
    echo "ARM"
    PLAT="linux-ubuntu-natty-armv7a-bins"
  else
    echo "x86 / x86_64"
    PLAT="linux-x86-bins"
  fi
else
  echo "Unknown OS, guessing Linux anyway"
  PLAT="linux-x86-bins"
fi
echo ""

if [ -e "${PWD}/osx-lion" ] && [ -e "${PWD}/linux-x86-bins" ]
then
  echo "Retreive from local file"
  MURL="file:///${PWD}"
else
  echo "Retreive from web"
  MURL='https://github.com/coolaj86/mtags/raw/master'
fi
echo ""

MURL="${MURL}/${PLAT}"
COPTS='--progress-bar --location --max-redirs 3'

echo "Retrieving id3tags"
curl ${COPTS} "${MURL}/id3tags" -o "${TMPD}/id3tags"
chmod a+x "${TMPD}/id3tags"

echo "Retrieving pdftags"
curl ${COPTS} "${MURL}/pdftags" -o "${TMPD}/pdftags"
chmod a+x "${TMPD}/pdftags"

echo "Retrieving imgtags"
curl ${COPTS} "${MURL}/imgtags" -o "${TMPD}/imgtags"
chmod a+x "${TMPD}/imgtags"

echo "Retrieving AtomicParsley"
curl ${COPTS} "${MURL}/AtomicParsley" -o "${TMPD}/AtomicParsley"
chmod a+x "${TMPD}/AtomicParsley"

echo "Retrieving m4atags"
curl ${COPTS} "${MURL}/m4atags.js" -o "${TMPD}/m4atags.js"
chmod a+x "${TMPD}/m4atags.js"
ln -s m4atags.js "${TMPD}/m4atags"

echo ""
echo "Installing to /usr/local/bin"
echo ""
rsync -av ${TMPD}/ /usr/local/bin/ 2>/dev/null || sudo rsync -av ${TMPD}/ /usr/local/bin/

rm -rf "${TMPD}"
