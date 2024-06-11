# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2020 Tobias Maedel

### env.img generate scripts ###
define Build/env-rv1106-sd-img
	mkenvimage -s 0x8000 -p 0x0 -o $(STAGING_DIR_IMAGE)/$(UBOOT_DEVICE_NAME)-env.img ./rv1106-uboot.env.sd.txt
endef

define Device/Default-emmc
  $(Device/Default-arm32)
  FILESYSTEMS += squashfs ext4
  IMAGES := boot.img rootfs.img
  IMAGE/rootfs.img := append-rootfs | pad-extra 128k
  IMAGE/boot.img := resource-img | boot-arm-bin
endef

define Device/Default-sdcard
  $(Device/Default-arm32)
  FILESYSTEMS += squashfs ext4
  IMAGES := boot.img rootfs.img
  IMAGE/rootfs.img := append-rootfs | pad-extra 128k
  IMAGE/boot.img := resource-img | boot-arm-bin
endef

define Device/Default-spiflash
  $(Device/Default-arm32)
  FILESYSTEMS += squashfs jffs2
  IMAGES := boot.img rootfs.img
  IMAGE/rootfs.img := append-rootfs | pad-extra 128k
  IMAGE/boot.img := resource-img | boot-arm-bin
endef

define Device/Default-nandflash
  $(Device/Default-arm32)
  FILESYSTEMS += squashfs ubifs
  IMAGES := boot.img rootfs.img
  IMAGE/rootfs.img := append-rootfs | pad-extra 128k
  IMAGE/boot.img := resource-img | boot-arm-bin
endef

define Device/luckfox_pico-max
  $(Device/Default-emmc)
  DEVICE_TITLE := Luckfox Pico Max
  SUPPORTED_DEVICES := luckfox,pico-max
  SOC := rv1106
  DEVICE_DTS := rv1106g-luckfox-pico-pro-max
  UBOOT_DEVICE_NAME := rv1106-emmc
  DEFAULT_PACKAGES += kmod-rknpu-rockchip
  IMAGES += sysupgrade.img.gz
  IMAGE/sysupgrade.img.gz := env-rv1106-sd-img | rockchip32-legacy-bin | append-rootfs | gzip | append-metadata
endef
TARGET_DEVICES += luckfox_pico-max

define Device/luckfox_pico
  $(Device/Default-emmc)
  DEVICE_TITLE := Luckfox Pico
  SUPPORTED_DEVICES := luckfox,pico
  SOC := rv1103
  DEVICE_DTS := rv1103g-luckfox-pico
  UBOOT_DEVICE_NAME := rv1106-emmc
  DEFAULT_PACKAGES += kmod-rknpu-rockchip
  IMAGES += sysupgrade.img.gz
  IMAGE/sysupgrade.img.gz := env-sd-img | rockchip32-legacy-bin | append-rootfs | pad-extra 128k | gzip | append-metadata
endef
TARGET_DEVICES += luckfox_pico
