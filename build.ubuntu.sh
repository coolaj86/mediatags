#!/bin/bash
sudo apt-get update
sudo apt-get install \
  build-essential \
  subversion \
  mercurial \
  automake \
  pkg-config \
  libxml2-dev \
  libexpat1-dev \
  git-core \
  cmake \
  libfreetype6 \
  libfreetype6-dev \
  libtool

PKG_CONFIG_PATH=/usr/lib/pkgconfig
export PKG_CONFIG_PATH

make deps
make mediatags
