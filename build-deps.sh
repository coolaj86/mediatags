#!/bin/bash
set -e
set -u

CURDIR=`pwd`

mkdir -p deps
cd deps



#
# jhead
#
function build_jhead {
  if [ ! -f "jhead-2.90.tar.gz" ]
  then
    wget http://www.sentex.net/~mwandel/jhead/jhead-2.90.tar.gz
  fi
  if [ ! -d "jhead-2.90" ]
  then
    tar xf jhead-2.90.tar.gz
  fi
  cd jhead-2.90
    make
    sudo make install
  cd -
}



#
# TagLib
#
function build_taglib {
  # Note taglib_config.h
  if [ ! -d "taglib/.git" ]
  then
    git clone git://github.com/taglib/taglib.git
  fi
  mkdir -p taglib/build
  cd taglib/build
    git checkout stable
    cmake ..
    make
    sudo make install
  cd -
}



#
# AtomicParsley
#
function build_atomicparsley_hg {
  # The current AP has cleaned up a few things we depended on
  # TODO make the switch
  
  if [ -d "wez-atomicparsley" ]
  then
    return
  fi
  hg clone https://bitbucket.org/wez/atomicparsley wez-atomicparsley
  cd wez-atomicparsley
    ./autogen.sh
    ./configure --disable-universal # for OSX
    make
    sudo make install
  cd -
}
function build_atomicparsley_hg_tar {
  APHGVER="3b67584ebdb2"
  APHGPKG="wez-atomicparsley"
  if [ ! -f "${APHGPKG}-${APHGVER}.tar.gz" ]
  then
    curl https://bitbucket.org/wez/atomicparsley/get/${APHGVER}.tar.gz -o ${APHGPKG}-${APHGVER}.tar.gz
  fi
  if [ ! -d "${APHGPKG}-${APHGVER}" ]
  then
    tar xf ${APHGPKG}-${APHGVER}.tar.gz
  fi
  cd ${APHGPKG}-${APHGVER}
    ./autogen.sh
    ./configure
    make
    sudo make install
  cd -
}
function build_atomicparsley_svn {
  # SVN version is broken in later versions
  svn co -r 91 https://atomicparsley.svn.sourceforge.net/svnroot/atomicparsley/trunk/atomicparsley atomicparsley
  cd atomicparsley
  rm -rf ./*
    svn up -r 91
    patch -p1 < ../../atomicparsley.patch
    ./build
    # uses autoconf in later versions
    #autoconf && autoheader
    #./configure
    #make
  cd -
}



#
# mhash
#
function build_mhash {
  if [ ! -f "mhash-0.9.9.9.tar.bz2" ]
  then
    wget http://downloads.sourceforge.net/project/mhash/mhash/0.9.9.9/mhash-0.9.9.9.tar.bz2
  fi
  if [ ! -d "mhash-0.9.9.9" ]
  then
    tar xf mhash-0.9.9.9.tar.bz2
    cd mhash-0.9.9.9
    ./configure --disable-shared --disable-md4 --disable-md2 --disable-tiger --disable-haval  --disable-crc32 --disable-adler32 --disable-ripemd --disable-gost --disable-snefru --disable-whirlpool >/dev/null
  else
    cd mhash-0.9.9.9
  fi
  make >/dev/null
  sudo make install
  cd -
}



#
# libb64
#
function build_libb64 {
  if [ ! -f "libb64-1.2.src.zip" ]
  then
    wget http://downloads.sourceforge.net/project/libb64/libb64/libb64/libb64-1.2.src.zip
  fi
  if [ ! -d "libb64-1.2" ]
  then
    unzip libb64-1.2.src.zip
  fi
  cd libb64-1.2/src
    make
  cd -
}



#
# libjson
#
function build_libjson {
  if [ ! -f "libjson_7.0.1.zip" ]
  then
    wget http://downloads.sourceforge.net/project/libjson/libjson_7.0.1.zip
  fi
  if [ ! -d "libjson_7.0.1" ]
  then
    unzip libjson_7.0.1.zip
    # fix permissions error
    chmod -R a+rx libjson/Source/JSONDefs
  fi
  cd libjson
    make
    sudo make install
  cd -
}



#
# exiv2
#
function build_exiv2 {
  svn checkout -r 2426 svn://dev.exiv2.org/svn/trunk exiv2
  svn up -r 2426
  mkdir -p exiv2/build
  cd exiv2/build
    cmake ..
    make
    sudo make install
  cd -
}



#
# fontconfig
#
function get_fontconfig {
  if [ -d "fontconfig" ]
  then
    return
  fi
  git clone git://anongit.freedesktop.org/fontconfig
  pushd fontconfig
    git checkout 2.9.0
    ./autogen.sh || true
    ./autogen.sh
  popd
}
function build_fontconfig {
  pushd fontconfig
    make
    sudo make install || true
    sudo ldconfig || true
    sudo make install
  popd
}

function build_fontconfig_osx {
  # or true in case it's already installed
  brew install fontconfig || true
}



#
# poppler
#
function get_poppler {
  # TODO use the git repo instead
  # git clone git://git.freedesktop.org/git/poppler/poppler
  if [ ! -f "poppler-0.16.2.tar.gz" ]
  then
    wget http://poppler.freedesktop.org/poppler-0.16.2.tar.gz
  fi
  if [ ! -d "poppler-0.16.2" ]
  then
    tar xf poppler-0.16.2.tar.gz
  fi
}
function build_poppler {
  #mkdir -p poppler-0.16.2/build
  #cd poppler-0.16.2/build
  pushd poppler-0.16.2
    ./configure --enable-xpdf-headers
    make
    sudo make install
  popd
  pushd poppler-0.16.2
    sudo mkdir -p /usr/local/include/poppler/
    sudo rsync -a poppler/*.h /usr/local/include/poppler/
    sudo rsync -a goo/ /usr/local/include/poppler/goo/
  popd
}
function build_poppler_osx {
  # or true in case it's already installed
  brew install poppler || true
}

function build_poppler_data {
  LPDVER="0.4.4"
  if [ ! -f "poppler-data-${LPDVER}.tar.gz" ]
  then
    wget http://poppler.freedesktop.org/poppler-data-${LPDVER}.tar.gz
  fi
  if [ ! -d "poppler-data-${LPDVER}" ]
  then
    tar xf poppler-data-${LPDVER}.tar.gz
  fi
  mkdir -p poppler-data-${LPDVER}/build
  cd poppler-data-${LPDVER}/build
    cmake ..
    make
    sudo make install
  cd -
}

##build_jhead
build_taglib
##build_atomicparsley_svn
build_atomicparsley_hg
##build_atomicparsley_hg_tar
build_mhash
build_libb64
build_libjson
build_exiv2
export PKG_CONFIG_PATH=`which pkg-config`
get_fontconfig
get_poppler
if [ -n `uname | grep -i darwin` ]
then
  build_fontconfig_osx
  build_poppler_osx
else
  build_fontconfig
  build_poppler
fi
build_poppler_data
