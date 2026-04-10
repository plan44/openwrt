#
# Copyright (C) 2010 OpenWrt.org
# Copyright (C) 2025 plan44/luz
#

PART_NAME=firmware
REQUIRE_IMAGE_METADATA=1

RAMFS_COPY_BIN='fw_printenv fw_setenv'
RAMFS_COPY_DATA='/etc/fw_env.config /var/lock/fw_printenv.lock'


platform_do_upgrade() {
	local board=$(board_name)

	case "$board" in
	rockchip,rv1106g-luckfox-pico-86panel-w)
	  # set BOOTDEV_MAJOR and BOOTDEV_MINOR env vars
		export_bootdevice
		# set "rootdev" env var (can be any var name as needed)
		# to the device name of 0=root, 1,2,…=partition1,2,
		# Note: this looks up the device name (not path!) based on BOOTDEV_MAJOR + BOOTDEV_MINOR+<given number>
		export_partdevice rootdev 0
		CI_ROOTDEV="$rootdev"
		# CI_xx are partition names, known by the kernel via /sys/block/$rootdev/${rootdev}p*/uevent PARTNAME
		# when these are set (and EMMC_xx_DEV are NOT set), emmc_do_upgrade uses find_mmc_part() to
		# define EMMC_xx_DEV accordingly.
		CI_KERNPART="boot"
		CI_ROOTPART="rootfs"
		# alternatively, EMMC_xx_DEV can be specified directly instead of by name with CI_xx
		# but that requires a fixed partition numbering schema, which is dangerous
		## This is how the partition numbers are for luckfox boards at this time
		#export_partdevice kernpart 4
		#export_partdevice rootfspart 7
		#export EMMC_KERN_DEV="/dev/$kernpart"
		#export EMMC_ROOT_DEV="/dev/$rootfspart"
		# now perform the update
		emmc_do_upgrade "$1"
		;;
	luckfox,rv1106-luckfox-pico-max|\
	luckfox,rv1103-luckfox-pico-mini-b|\
	onion,rv1103b-omega4-evb|\
	plan44,p44-xx-pico-max)
		# CI_xx are mtd partition names, known by the kernel via /sys/block/mtdblockX/device/name
		CI_KERNPART="boot"
		CI_ROOTPART="rootfs"
		nand_do_upgrade "$1"
		;;
	luckfox,rv1103-luckfox-pico-mini-a)
		export_bootdevice && export_partdevice diskdev 0 || {
			echo "Unable to determine upgrade device"
			return 1
		}
		sync
		get_image "$@" | dd of="/dev/$diskdev" bs=4096 conv=fsync
		;;
	*)
		default_do_upgrade "$1"
		;;
	esac
}

platform_check_image() {
	local magic="$(get_magic_long "$1")"
	local board=$(board_name)

	[ "$#" -gt 1 ] && return 1

	case "$board" in
	rockchip,rv1106g-luckfox-pico-86panel-w)
		# NAND check is ok-ish here, as we use a tar file
		nand_do_platform_check "$board" "$1"
		return $?
		;;
	luckfox,rv1106-luckfox-pico-max|\
	luckfox,rv1103-luckfox-pico-mini-b|\
	onion,rv1103b-omega4-evb|\
	plan44,p44-xx-pico-max)
		nand_do_platform_check "$board" "$1"
		return $?
		;;
	luckfox,rv1103-luckfox-pico-mini-a)
		return 0
		;;
	*)
		echo "Sysupgrade is not supported on your board yet."
		return 1
		;;
	esac

	return 0
}

platform_copy_config() {
	case "$(board_name)" in
	rockchip,rv1106g-luckfox-pico-86panel-w)
		emmc_copy_config
		;;
	esac
}

