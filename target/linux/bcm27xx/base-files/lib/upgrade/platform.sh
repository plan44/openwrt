. /lib/functions.sh

REQUIRE_IMAGE_METADATA=1

# copied from x86's platform.sh

platform_check_image() {
	local diskdev partdev diff

	[ "$#" -gt 1 ] && return 1

	export_bootdevice && export_partdevice diskdev 0 || {
		echo "Unable to determine upgrade device"
		return 1
	}

	get_partitions "/dev/$diskdev" bootdisk

	#extract the boot sector from the image
	get_image "$@" | dd of=/tmp/image.bs count=1 bs=512b 2>/dev/null

	get_partitions /tmp/image.bs image

	#compare tables
	diff="$(grep -F -x -v -f /tmp/partmap.bootdisk /tmp/partmap.image)"

	rm -f /tmp/image.bs /tmp/partmap.bootdisk /tmp/partmap.image

	if [ -n "$diff" ]; then
		echo "Partition layout has changed. Full image will be written."
		ask_bool 0 "Abort" && exit 1
		return 0
	fi

	return 0;
}

platform_do_upgrade() {
	local diskdev partdev diff

	export_bootdevice && export_partdevice diskdev 0 || {
		echo "Unable to determine upgrade device"
		return 1
	}

	sync

	if [ "$UPGRADE_OPT_SAVE_PARTITIONS" = "1" ]; then
		get_partitions "/dev/$diskdev" bootdisk

		#extract the boot sector from the image
		get_image "$@" | dd of=/tmp/image.bs count=1 bs=512b

		get_partitions /tmp/image.bs image

		#compare tables
		diff="$(grep -F -x -v -f /tmp/partmap.bootdisk /tmp/partmap.image)"
	else
		diff=1
	fi

	if [ -n "$diff" ]; then
		get_image "$@" | dd of="/dev/$diskdev" bs=2M conv=fsync

		# Separate removal and addtion is necessary; otherwise, partition 1
		# will be missing if it overlaps with the old partition 2

		# Note: this will still fail when partition2 is a f2fs. For some reason
		#		the partition remains blocked and can't be removed, presumably by
		#		f2fs having something open on the partdev despite being unmounted
		#		and loopdev removed. So, partx -d will fail, and in consequence,
		#		partx -a will then fail, too.
		if ! partx -d - "/dev/$diskdev"; then
			# removing partition failed, set marker to enable workaround
			# below in platform_copy_config()
			touch /tmp/partitions_blocked
		fi
		partx -a - "/dev/$diskdev"

		return 0
	fi

	#iterate over each partition from the image and write it to the boot disk
	while read part start size; do
		if export_partdevice partdev $part; then
			echo "Writing image to /dev/$partdev..."
			get_image "$@" | dd of="/dev/$partdev" ibs="512" obs=1M skip="$start" count="$size" conv=fsync
		else
			echo "Unable to find partition $part device, skipped."
	fi
	done < /tmp/partmap.image

	#copy partition uuid
	echo "Writing new UUID to /dev/$diskdev..."
	get_image "$@" | dd of="/dev/$diskdev" bs=1 skip=440 count=4 seek=440 conv=fsync
}

platform_copy_config() {
	local partdev diskdev

	if [ -f /tmp/partitions_blocked ]; then
		# need to work around blocked partition: access possibly grown boot via loop
		if export_bootdevice && export_partdevice diskdev 0; then
			get_partitions "/dev/$diskdev" newbootdisk
			read BOOTNO BOOTOFFS BOOTSZ < /tmp/partmap.newbootdisk
			BYTEOFFS=$((BOOTOFFS * 512))
			BYTESZ=$((BOOTSZ * 512))
			LOOPDEV=$(losetup -f "/dev/$diskdev" -o $BYTEOFFS --sizelimit $BYTESZ --show)
			mkdir -p /boot
			[ -f /boot/kernel.img ] || mount -t vfat -o rw,noatime "$LOOPDEV" /boot
			cp -af "$UPGRADE_BACKUP" "/boot/$BACKUP_FILE"
			tar -C / -zxvf "$UPGRADE_BACKUP" boot/cmdline.txt boot/config.txt
			sync
			umount /boot
		fi
	else
		if export_partdevice partdev 1; then
			mkdir -p /boot
			[ -f /boot/kernel.img ] || mount -t vfat -o rw,noatime "/dev/$partdev" /boot
			cp -af "$UPGRADE_BACKUP" "/boot/$BACKUP_FILE"
			tar -C / -zxvf "$UPGRADE_BACKUP" boot/cmdline.txt boot/config.txt
			sync
			umount /boot
		fi
	fi
}
