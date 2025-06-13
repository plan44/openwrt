#!/bin/sh

set -x
[ $# -eq 5 ] || {
    echo "SYNTAX: $0 <file> <bootfs image> <rootfs image> <bootfs size> <rootfs size>"
    exit 1
}

OUTPUT="$1"
BOOTFS="$2"
ROOTFS="$3"
BOOTFSSIZE="$4"
ROOTFSSIZE="$5"

head=4
sect=63

set $(ptgen -o $OUTPUT -h $head -s $sect -l 4096 -t c -p ${BOOTFSSIZE}M -t 83 -p ${ROOTFSSIZE}M)

BOOTOFFSET="$(($1 / 512))"
BOOTSIZE="$(($2 / 512))"
ROOTFSOFFSET="$(($3 / 512))"
ROOTFSSIZE="$(($4 / 512))"

# for sqashfs + f2fs layout, the rootfs image is only the sqashfs part, which
# is (usually much) smaller than the rootfs partition.
# The f2fs part (for the overlay) will be created only at first boot
# into the new image, when mount_root does not detect a valid filesystem already
# present. To make sure random data from previous installations are not falsely
# detected (which could and did happen in earlier versions), we add 1 MB zero padding
# or up to the end of the rootfs partition, whichever is less.
# While the padding is required for the squashfs+f2fs layout only, it does not
# interfere with other rootfs partition types such as ext4.

# the image itself is usually less than the partition size (ROOTFSSIZE)
ROOTFSBYTES="$(wc -c < $ROOTFS)"
ROOTFSIMGSIZE="$(( ($ROOTFSBYTES+511) / 512))"
# we start padding one block BEFORE image ends
PADOFFSET="$(($ROOTFSOFFSET + $ROOTFSIMGSIZE - 1))"
PADSIZE="$(($ROOTFSSIZE - ROOTFSIMGSIZE + 1))"
# limit the padding to 1M, it needs to be just enough to prevent false fs detection by mount_root
if (( $PADSIZE > 2048 )); then
  PADSIZE=2048
fi

# write the boot partition
dd bs=512 if="$BOOTFS" of="$OUTPUT" seek="$BOOTOFFSET" conv=notrunc
# pad out some space after rootfs image, overlapping last block
if (( $PADSIZE > 0 )); then
  dd bs=512 if=/dev/zero of="$OUTPUT" seek="$PADOFFSET" count="$PADSIZE" conv=notrunc
fi
# write the rootfs image which does usually not fill the entire partition
dd bs=512 if="$ROOTFS" of="$OUTPUT" seek="$ROOTFSOFFSET" conv=notrunc
