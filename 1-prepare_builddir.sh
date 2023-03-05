#!/bin/bash

if [ ! -n "${INPUT_IMG}" ]; then
  echo "\$INPUT_IMG must be defined"
  exit 1
fi
if [ ! -n "${IMG}" ]; then
  echo "\$IMG must be defined"
  exit 1
fi

cp $INPUT_IMG $IMG

export LOOP_DEV=$(losetup -f)
export LOOP_NUM=$(echo ${LOOP_DEV} | awk -F'/' '{print $3}')
losetup $LOOP_DEV $IMG
kpartx -av $LOOP_DEV

export BUILDDIR=/mnt/ostree_rootfs
mkdir -p $BUILDDIR

mount /dev/mapper/${LOOP_NUM}p2 $BUILDDIR


export ROOTDIR=/mnt/boot
mkdir -p $ROOTDIR

mount /dev/mapper/${LOOP_NUM}p1 $ROOTDIR

cp $ROOTDIR/kernel8.img $BUILDDIR/boot/

# get the kernel version from kernel image
KERNEL_IMG=$BUILDDIR/boot/kernel8.img
IMG_OFFSET=$(LC_ALL=C grep -abo $'\x1f\x8b\x08\x00' $KERNEL_IMG | head -n 1 | cut -d ':' -f 1)

export KERNEL_VERSION=$(dd if=$KERNEL_IMG obs=64K ibs=4 skip=$(( IMG_OFFSET / 4)) 2>/dev/null | zcat | grep -a -m1 "Linux version" | strings | awk '{ print $3; }')
export UNAME_R=$KERNEL_VERSION

echo current target image kernel version:$KERNEL_VERSION
