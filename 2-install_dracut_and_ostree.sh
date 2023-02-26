#!/bin/bash

echo "Installing dracut and ostree..."

# From https://github.com/beagleboard/image-builder/blob/master/scripts/chroot.sh
chroot_mount () {
  if [ "$(mount | grep ${BUILDDIR}/sys | awk '{print $3}')" != "${BUILDDIR}/sys" ] ; then
    sudo mount -t sysfs sysfs "${BUILDDIR}/sys"
  fi

  if [ "$(mount | grep ${BUILDDIR}/proc | awk '{print $3}')" != "${BUILDDIR}/proc" ] ; then
    sudo mount -t proc proc "${BUILDDIR}/proc"
  fi

  if [ ! -d "${BUILDDIR}/dev/pts" ] ; then
    sudo mkdir -p ${BUILDDIR}/dev/pts || true
  fi

  if [ "$(mount | grep ${BUILDDIR}/dev/pts | awk '{print $3}')" != "${BUILDDIR}/dev/pts" ] ; then
    sudo mount -t devpts devpts "${BUILDDIR}/dev/pts"
  fi
}

chroot_umount () {
  if [ "$(mount | grep ${BUILDDIR}/dev/pts | awk '{print $3}')" = "${BUILDDIR}/dev/pts" ] ; then
    echo "Log: umount: [${BUILDDIR}/dev/pts]"
    sync
    sudo umount -fl "${BUILDDIR}/dev/pts"

    if [ "$(mount | grep ${BUILDDIR}/dev/pts | awk '{print $3}')" = "${BUILDDIR}/dev/pts" ] ; then
      echo "Log: ERROR: umount [${BUILDDIR}/dev/pts] failed..."
      exit 1
    fi
  fi

  if [ "$(mount | grep ${BUILDDIR}/proc | awk '{print $3}')" = "${BUILDDIR}/proc" ] ; then
    echo "Log: umount: [${BUILDDIR}/proc]"
    sync
    sudo umount -fl "${BUILDDIR}/proc"

    if [ "$(mount | grep ${BUILDDIR}/proc | awk '{print $3}')" = "${BUILDDIR}/proc" ] ; then
      echo "Log: ERROR: umount [${BUILDDIR}/proc] failed..."
      exit 1
    fi
  fi

  if [ "$(mount | grep ${BUILDDIR}/sys | awk '{print $3}')" = "${BUILDDIR}/sys" ] ; then
    echo "Log: umount: [${BUILDDIR}/sys]"
    sync
    sudo umount -fl "${BUILDDIR}/sys"

    if [ "$(mount | grep ${BUILDDIR}/sys | awk '{print $3}')" = "${BUILDDIR}/sys" ] ; then
      echo "Log: ERROR: umount [${BUILDDIR}/sys] failed..."
      exit 1
    fi
  fi

  if [ "$(mount | grep ${BUILDDIR}/run | awk '{print $3}')" = "${BUILDDIR}/run" ] ; then
    echo "Log: umount: [${BUILDDIR}/run]"
    sync
    sudo umount -fl "${BUILDDIR}/run"

    if [ "$(mount | grep ${BUILDDIR}/run | awk '{print $3}')" = "${BUILDDIR}/run" ] ; then
      echo "Log: ERROR: umount [${BUILDDIR}/run] failed..."
      exit 1
    fi
  fi
}

cat > "${BUILDDIR}/chroot_script.sh" <<-__EOF__
ls -l /usr/bin/apt-get
apt-get update
apt-get install -y dracut

# install ostree and it's dependencies
# CAREFUL - we're building from source
# so dependencies may have changed since
# current debian version of ostree
apt-get install -y ostree

# remove ostree so only dependencies are left
apt-get purge -y ostree libostree-1-1

cd /tmp

tar xzf ostree-withdracut.tar.gz
cd ostree-withdracut
cp -r * /
cd ..
rm -r ostree-withdracut
ls -l /usr/lib/dracut/modules.d/98ostree/
rm ostree-withdracut.tar.gz

dracut --force --no-compress --add ostree /boot/initrd.img-$KERNEL_VERSION $KERNEL_VERSION

rm -rf /usr/etc

rm /usr/bin/qemu-aarch64-static
#rm /etc/resolv.conf
#ln -s  /run/connman/resolv.conf /etc/resolv.conf

apt-get clean

rm /chroot_script.sh

__EOF__


QEMU=$(which qemu-aarch64-static)

if [ ! -n "${QEMU}" ]; then
  echo "qemu-user-static package must be installed"
fi

cp /home/seeed/ostree/bbb-ostree-helper-scripts/kernel8.img ${BUILDDIR}/boot 

cp $QEMU ${BUILDDIR}/usr/bin
cp --remove-destination /etc/resolv.conf ${BUILDDIR}/etc/resolv.conf
ls -l ${BUILDDIR}/usr/bin | grep qemu
chroot_mount
chroot ${BUILDDIR} qemu-aarch64-static /bin/bash -e /chroot_script.sh
chroot_umount