FROM debian:buster

RUN apt-get update && apt-get install -y git m4 dosfstools kpartx wget parted curl unzip xz-utils sudo uuid vim cpio qemu-user-static

RUN apt-get install -y ostree

ENTRYPOINT [ "/host/entrypoint.sh" ]
