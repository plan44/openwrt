# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2020 Tobias Maedel

### env.img generate scripts ###
define Build/env-rv1106-sd-img
	mkenvimage -s 0x8000 -p 0x0 -o $(STAGING_DIR_IMAGE)/$(UBOOT_DEVICE_NAME)-env.img ./rv1106-uboot.env.sd.txt
endef

define Build/env-rv1106-nand-img
	mkenvimage -s 0x40000 -p 0x0 -o $(STAGING_DIR_IMAGE)/$(UBOOT_DEVICE_NAME)-env.img ./rv1106-uboot.env.spi-nand.txt
endef

define Build/env-rv1106-emmc-img
	mkenvimage -s 0x8000 -p 0x0 -o $(STAGING_DIR_IMAGE)/$(UBOOT_DEVICE_NAME)-env.img ./rv1106-uboot.env.emmc.txt
endef

define Build/rockchip-env-img
  cp $(STAGING_DIR_IMAGE)/$(UBOOT_DEVICE_NAME)-env.img $@
endef

define Build/rockchip-idblock-img
	cp $(STAGING_DIR_IMAGE)/$(UBOOT_DEVICE_NAME)-idblock.img $@
endef

define Build/rockchip-uboot-img
	cp $(STAGING_DIR_IMAGE)/$(UBOOT_DEVICE_NAME)-uboot.img $@
endef

define Device/Default-emmc
  $(Device/Default-arm32)
  FILESYSTEMS := squashfs
  IMAGES := boot.img rootfs.img env.img
  IMAGE/rootfs.img := append-rootfs | pad-extra 128k
  IMAGE/boot.img := resource-img | boot-arm-bin
  IMAGE/env.img := env-rv1106-emmc-img | rockchip-env-img
endef

define Device/Default-sdcard
  $(Device/Default-arm32)
  FILESYSTEMS := squashfs
  IMAGES := boot.img rootfs.img
  IMAGE/rootfs.img := append-rootfs | pad-extra 128k
  IMAGE/boot.img := resource-img | boot-arm-bin
endef

define Device/Default-spiflash
  $(Device/Default-arm32)
  FILESYSTEMS := squashfs
  IMAGES := boot.img rootfs.img
  IMAGE/rootfs.img := append-rootfs | pad-extra 128k
  IMAGE/boot.img := resource-img | boot-arm-bin
endef

define Device/Default-nandflash
  $(Device/Default-arm32)
  $(Device/Default-sfc-128k)
  FILESYSTEMS := squashfs
  IMAGES := boot.img rootfs.img env.img idblock.img uboot.img
  IMAGE/rootfs.img := append-ubi | pad-to $$$$(PAGESIZE) | check-size $$$$(IMAGE_SIZE)
  IMAGE/boot.img := resource-img | boot-arm-bin
  IMAGE/env.img := env-rv1106-nand-img | rockchip-env-img
  IMAGE/idblock.img := rockchip-idblock-img
  IMAGE/uboot.img := rockchip-uboot-img
endef

define Device/luckfox_pico-max
  $(Device/Default-nandflash)
  DEVICE_TITLE := Luckfox Pico Max
  SUPPORTED_DEVICES := luckfox,pico-max
  SOC := rv1106
  MKUBIFS_OPTS := -m 2048 -e 124KiB -c 2114
  UBINIZE_OPTS := -m 2048 -p 128KiB -s 2048
  DEVICE_DTS := rv1106g-luckfox-pico-pro-max
  UBOOT_DEVICE_NAME := rv1106-sfc
  DEFAULT_PACKAGES += kmod-rknpu-rockchip
  IMAGES += sysupgrade.img.gz
  IMAGE/sysupgrade.img.gz := sysupgrade-tar | gzip | append-metadata
endef
TARGET_DEVICES += luckfox_pico-max

define Device/luckfox_pico-86panel-w
  $(Device/Default-emmc)
  DEVICE_TITLE := Luckfox Pico 86panel-w
  SUPPORTED_DEVICES := rockchip,rv1106g-luckfox-pico-86panel-w
  SOC := rv1106g
  DEVICE_DTS := rv1106g-luckfox-pico-86panel-w
  UBOOT_DEVICE_NAME := rv1106-emmc
  DEFAULT_PACKAGES += kmod-rknpu-rockchip
  KERNEL := kernel-bin | resource-img | boot-arm-bin # that's what we need in the sysupgrade-tar
  IMAGE/boot.img := append-kernel # override Default-emmc boot.img, otherwise kernel-bin will be wrapped twice
  IMAGES += sysupgrade.tar
  IMAGE/sysupgrade.tar := sysupgrade-tar | append-metadata
endef
TARGET_DEVICES += luckfox_pico-86panel-w

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
