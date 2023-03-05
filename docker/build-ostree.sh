#!/bin/bash

cd /tmp

git clone https://github.com/ostreedev/ostree.git --depth=1

cd ostree
git submodule update --init
env NOCONFIGURE=1 ./autogen.sh
./configure --with-dracut

make -j`nproc`

mkdir -p /tmp/ostree_with_dracut
make install DESTDIR=/tmp/ostree_with_dracut

