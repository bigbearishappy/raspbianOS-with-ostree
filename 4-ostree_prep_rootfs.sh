#!/bin/bash

# Modified from
# https://salsa.debian.org/debian/ostree/-/blob/debian/master/debian/ostree-boot-examples/modified-deb-ostree-builder

if [ ! -n "${BUILDDIR}" ]; then
  echo "\$BUILDDIR must be defined"
  exit 1
fi
if [ ! -n "${KERNEL_VERSION}" ]; then
  echo "\$KERNEL_VERSION must be defined"
  exit 1
fi
if [ ! -n "${OSTREE_BRANCH}" ]; then
  echo "\$OSTREE_BRANCH must be defined"
  exit 1
fi
if [ ! -n "${OSTREE_SUBJECT}" ]; then
  echo "\$OSTREE_SUBJECT must be defined"
  exit 1
fi

if [ ! -n "${OSTREE_VERSION}" ]; then
  echo "\$OSTREE_VERSION must be defined"
  exit 1
fi

cd /tmp

cd ${BUILDDIR}


mv opt usr
ln -s usr/opt opt

rm -rf dev
mkdir dev

sed -i -e 's|DHOME=/home|DHOME=/sysroot/home|g' etc/adduser.conf
sed -i -e 's|DHOME=/home|DHOME=/sysroot/home|g' etc/default/useradd
mv etc usr

mkdir -p usr/share/dpkg

mv var/lib/dpkg usr/share/dpkg/database
ln -sr usr/share/dpkg/database var/lib/dpkg

cat > usr/lib/tmpfiles.d/ostree.conf <<EOF
L /var/home - - - - ../sysroot/home
d /sysroot/home 0755 root root -
d /sysroot/root 0700 root root -
d /run/media 0755 root root -
L /var/lib/dpkg - - - - ../../usr/share/dpkg/database
EOF

mkdir -p sysroot
mv home /tmp/home
mv var /tmp/var
mkdir var
rm -rf {root,media} 
ln -s /sysroot/ostree ostree
ln -s /sysroot/home home
ln -s /sysroot/root root
ln -s /run/media media


cd /tmp 

# This is in here so ostree doesn't complain about the kernel 
# when doing "ostree admin deploy"
cd ${BUILDDIR}
cp boot/kernel8.img usr/lib/modules/$KERNEL_VERSION/vmlinuz
cp boot/initrd.img-$KERNEL_VERSION usr/lib/modules/$KERNEL_VERSION/initramfs.img
CHECKSUM=$(cat boot/kernel8.img boot/initrd.img-$KERNEL_VERSION | sha256sum | head -c 64)
rm boot/kernel8.img
rm boot/initrd.img-$KERNEL_VERSION

REPO=/host/repo
if [ ! -d "$REPO" ]; then
  ostree --repo="$REPO" init --mode=archive-z2
fi
ostree commit --repo="$REPO" --branch="${OSTREE_BRANCH}" --subject="${OSTREE_SUBJECT}" --skip-if-unchanged --table-output --add-metadata-string="version=${OSTREE_VERSION}" "${BUILDDIR}"
ostree summary --repo="$REPO" --update

# Remove rootfs so ostree_client_setup.sh can replace them 
rm -r ${BUILDDIR}/*

