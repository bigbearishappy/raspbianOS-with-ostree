#!/bin/bash

cd /tmp

git clone git://git.denx.de/u-boot.git

cd u-boot

make CROSS_COMPILE=aarch64-linux-gnu- rpi_4_defconfig
make -j`nproc`
