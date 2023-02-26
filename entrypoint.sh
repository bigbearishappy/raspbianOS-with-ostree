#!/bin/bash

export INPUT_IMG=/host/$1
export IMG=/tmp/$(basename $INPUT_IMG)
export OUTPUT_IMG=/host/$(basename $INPUT_IMG .img)-ostree.img

. /host/1-prepare_builddir.sh
. /host/2-install_dracut_and_ostree.sh
. /host/3-ostree_prep_rootfs.sh
. /host/4-create_ostree_rootfs.sh
. /host/5-cleanup.sh
