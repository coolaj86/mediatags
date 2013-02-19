#!/bin/bash
brew help > /dev/null || ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"
brew install hg
brew install pkg-config
brew install poppler
#poppler-data comes with poppler?
brew install fontconfig
brew install automake
brew install cmake
brew install libtool
#brew install libxml2

#subversion already installed with cli tools
#git-core already installed with cli tools
#libexpat1-dev \
#libfreetype6 \
#libfreetype6-dev \

PKG_CONFIG_PATH=/usr/lib/pkgconfig
export PKG_CONFIG_PATH

make deps
make mediatags
