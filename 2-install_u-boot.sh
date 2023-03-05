#!/bin/bash

echo build and install u-boot...

if [ ! -f /host/u-boot.bin ]
then
apt -y build-dep u-boot
echo u-boot.bin not exist, build it now ...
cd /tmp

git clone git://git.denx.de/u-boot.git --depth=1

cd u-boot

make CROSS_COMPILE=aarch64-linux-gnu- rpi_4_defconfig
make -j`nproc`
cp u-boot.bin /host
fi

cd /tmp
cp /host/boot_cmd.txt ./
mkimage -A arm64 -O linux -T script -C none -d boot_cmd.txt boot.scr

# deploy the u-boot to target image
cp /host/u-boot.bin $ROOTDIR/u-boot.bin
cp boot.scr $ROOTDIR/boot.scr

echo "enable_uart=1" >> $ROOTDIR/config.txt
echo "kernel=u-boot.bin" >> $ROOTDIR/config.txt

echo install u-boot done.
