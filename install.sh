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
  elif [ "`arch | grep 64`" ]
  then
    echo "x86_64"
    PLAT="linux-ubuntu-precise-x64-bins"    
  else
    echo "x86"
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

echo "Retrieving m4atags"
curl ${COPTS} "${MURL}/m4atags" -o "${TMPD}/m4atags"
chmod a+x "${TMPD}/m4atags"

echo "Retrieving id3tags"
curl ${COPTS} "${MURL}/id3tags" -o "${TMPD}/id3tags"
chmod a+x "${TMPD}/id3tags"

echo "Retrieving pdftags"
curl ${COPTS} "${MURL}/pdftags" -o "${TMPD}/pdftags"
chmod a+x "${TMPD}/pdftags"

echo "Retrieving imgtags"
curl ${COPTS} "${MURL}/imgtags" -o "${TMPD}/imgtags"
chmod a+x "${TMPD}/imgtags"

echo ""
echo "Installing to /usr/local/bin"
echo ""
rsync -av ${TMPD}/ /usr/local/bin/ 2>/dev/null || sudo rsync -av ${TMPD}/ /usr/local/bin/

echo "WAIT!"
echo ""
echo "Your not done yet, you still need to install poppler for pdftags (and possibly exiv2)... and you may need to compile them from source"
echo ""
echo "sudo apt-get install -y poppler-data # Ubuntu / Debian Linux"
echo "sudo apt-get install -y libexiv2-11"
echo ""
echo "brew install poppler # OS X Lion"
echo ""

rm -rf "${TMPD}"
