FROM debian:bullseye

RUN apt-get update && apt-get install -y git m4 dosfstools kpartx wget parted curl unzip xz-utils sudo uuid vim cpio qemu-user-static u-boot-tools

RUN apt-get install -y ostree

ENTRYPOINT [ "/host/entrypoint.sh" ]
