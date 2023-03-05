FROM debian:bullseye

RUN apt-get update && apt-get install -y git m4 dosfstools kpartx wget parted curl unzip xz-utils sudo vim cpio qemu-user-static

#install tools for target image ostree building
RUN echo "deb-src https://deb.debian.org/debian buster main non-free contrib" >> /etc/apt/sources.list && apt-get update && apt-get -y install build-essential && apt-get -y build-dep ostree

#install tools for u-boot building
RUN apt-get install -y u-boot-tools crossbuild-essential-arm64
RUN apt-get -y build-dep u-boot

RUN apt-get install -y ostree

ENTRYPOINT [ "/host/entrypoint.sh" ]
