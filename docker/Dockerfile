FROM debian:bullseye

RUN apt-get update && apt-get install -y git m4 dosfstools kpartx wget parted curl unzip xz-utils sudo uuid vim cpio qemu-user-static u-boot-tools crossbuild-essential-arm64

RUN apt-get install -y ostree

RUN build-u-boot.sh

RUN build-ostree.sh

ENTRYPOINT [ "/host/entrypoint.sh" ]
