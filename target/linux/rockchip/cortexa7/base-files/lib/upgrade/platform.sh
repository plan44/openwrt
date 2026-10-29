# SPDX-License-Identifier: GPL-2.0-only
PART_NAME=firmware
REQUIRE_IMAGE_METADATA=1

RAMFS_COPY_BIN='fw_printenv fw_setenv'
RAMFS_COPY_DATA='/etc/fw_env.config /var/lock/fw_printenv.lock'

# The installed bootargs use /dev/ubiblock0_0. Creating provisioning first
# would take volume ID 0 when rootfs is recreated. Keep this layout unchanged.
omega4_check_upgrade_options() {
	if [ "${ADD_PROVISIONING:-0}:${UPGRADE_OPT_ADD_PROVISIONING:-0}" != "0:0" ]; then
		echo "Omega4 does not support sysupgrade -P: rootfs must remain UBI volume 0."
		return 1
	fi
}

platform_check_image() {
	omega4_check_upgrade_options || return 1
	[ "$#" -eq 1 ] || return 1
	case "$(board_name)" in
	plan44,rv1103b-p44-base-omega4)
		nand_do_platform_check "$(board_name)" "$1"
		;;
	*)
		echo "Sysupgrade is not supported on this board."
		return 1
		;;
	esac
}

platform_do_upgrade() {
	omega4_check_upgrade_options || return 1
	case "$(board_name)" in
	plan44,rv1103b-p44-base-omega4)
		CI_KERNPART="boot"
		CI_ROOTPART="rootfs"
		CI_UBIPART="ubi"
		nand_do_upgrade "$1"
		;;
	*)
		echo "Sysupgrade is not supported on this board."
		return 1
		;;
	esac
}
