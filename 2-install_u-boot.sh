#!/bin/bash

echo build and install u-boot...

cd /tmp

cp /host/boot_cmd.txt ./
mkimage -A arm64 -O linux -T script -C none -d boot_cmd.txt boot.scr

# deploy the u-boot to target image
cp u-boot/u-boot.bin $ROOTDIR/u-boot.bin
cp boot.scr $ROOTDIR/boot.scr

echo "enable_uart=1" >> $ROOTDIR/config.txt
echo "kernel=u-boot.bin" >> $ROOTDIR/config.txt

echo install u-boot done.
