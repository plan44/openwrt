# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2020 Tobias Maedel

### env.img generate scripts ###
define Build/env-rv1103b-nand-img
	if [ ! -d $(STAGING_DIR_IMAGE) ]; then mkdir -p $(STAGING_DIR_IMAGE) ; fi
	mkenvimage -s 0x40000 -p 0x0 -o $(STAGING_DIR_IMAGE)/$(UBOOT_DEVICE_NAME)-env.img ./rv1103b-uboot.env.spi-nand.txt
endef

define Build/env-rv1106-sd-img
	if [ ! -d $(STAGING_DIR_IMAGE) ]; then mkdir -p $(STAGING_DIR_IMAGE) ; fi
	mkenvimage -s 0x8000 -p 0x0 -o $(STAGING_DIR_IMAGE)/$(UBOOT_DEVICE_NAME)-env.img ./rv1106-uboot.env.sd.txt
endef

define Build/env-rv1106-nand-img
	if [ ! -d $(STAGING_DIR_IMAGE) ]; then mkdir -p $(STAGING_DIR_IMAGE) ; fi
	mkenvimage -s 0x40000 -p 0x0 -o $(STAGING_DIR_IMAGE)/$(UBOOT_DEVICE_NAME)-env.img ./rv1106-uboot.env.spi-nand.txt
endef

define Build/env-rv1106-emmc-img
	if [ ! -d $(STAGING_DIR_IMAGE) ]; then mkdir -p $(STAGING_DIR_IMAGE) ; fi
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
  IMAGES := boot.img rootfs.img env.img idblock.img uboot.img
  IMAGE/rootfs.img := append-rootfs | pad-extra 128k
  IMAGE/boot.img := resource-img | boot-arm-bin
  IMAGE/env.img := env-rv1106-sd-img | rockchip-env-img
  IMAGE/idblock.img := rockchip-idblock-img
  IMAGE/uboot.img := rockchip-uboot-img
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
  IMAGES := boot.img rootfs.img env.img
#  IMAGES := boot.img rootfs.img env.img idblock.img uboot.img
  IMAGE/rootfs.img := append-ubi | pad-to $$$$(PAGESIZE) | check-size $$$$(IMAGE_SIZE)
  IMAGE/boot.img := resource-img | boot-arm-bin
# env is target specific, do not build one here
#   IMAGE/env.img := env-rv1106-nand-img | rockchip-env-img
# we do not create those for now
#   IMAGE/idblock.img := rockchip-idblock-img
#   IMAGE/uboot.img := rockchip-uboot-img
endef


define Device/onion_omega4-evb
  $(Device/Default-nandflash)
  DEVICE_TITLE := Onion Omega4 EVB
  # note: SUPPORTED_DEVICES is not honoured by nand.sh's nand_do_platform_check(), so only BOARD_NAME is relevant
  SUPPORTED_DEVICES := onion,rv1103b-omega4-evb onion,onion_omega4
  BOARD_NAME := onion,rv1103b-omega4-evb # must match compatible in dts (which defines the runtime board name)
  SOC := rv1103b
  MKUBIFS_OPTS := -m 2048 -e 124KiB -c 2114
  DEVICE_DTS := rv1103b-omega4-evb
  UBOOT_DEVICE_NAME := rv1103b-nand
  DEFAULT_PACKAGES += kmod-rknpu-rockchip
  KERNEL := kernel-bin | resource-img | boot-arm-bin # that's what we need in the sysupgrade-tar
  IMAGE/boot.img := append-kernel # override Default-nandflash boot.img, otherwise kernel-bin will be wrapped twice
  IMAGE/env.img := env-rv1103b-nand-img | rockchip-env-img # override Default-nandflash env.img because we need rv1103 specific env layout-
  IMAGES += sysupgrade.tar
  IMAGE/sysupgrade.tar := sysupgrade-tar | append-metadata
endef
TARGET_DEVICES += onion_omega4-evb



define Device/plan44_p44-xx-pico-max
  $(Device/Default-nandflash)
  DEVICE_TITLE := P44-xx based on Pico Max
  SUPPORTED_DEVICES := plan44,p44-xx-pico-max
  SOC := rv1106
  MKUBIFS_OPTS := -m 2048 -e 124KiB -c 2114
  DEVICE_DTS := rv1106g-p44-xx-pico-max
  UBOOT_DEVICE_NAME := rv1106-nand
  DEFAULT_PACKAGES += kmod-rknpu-rockchip
  KERNEL := kernel-bin | resource-img | boot-arm-bin # that's what we need in the sysupgrade-tar
  IMAGE/boot.img := append-kernel # override Default-emmc boot.img, otherwise kernel-bin will be wrapped twice
  IMAGES += sysupgrade.tar
  IMAGE/sysupgrade.tar := sysupgrade-tar | append-metadata
endef
TARGET_DEVICES += plan44_p44-xx-pico-max

define Device/luckfox_pico-max
  $(Device/Default-nandflash)
  DEVICE_TITLE := Luckfox Pico Max
  SUPPORTED_DEVICES := luckfox,rv1106-luckfox-pico-max
  SOC := rv1106
  MKUBIFS_OPTS := -m 2048 -e 124KiB -c 2114
  DEVICE_DTS := rv1106g-luckfox-pico-pro-max
  UBOOT_DEVICE_NAME := rv1106-nand
  DEFAULT_PACKAGES += kmod-rknpu-rockchip
  KERNEL := kernel-bin | resource-img | boot-arm-bin # that's what we need in the sysupgrade-tar
  IMAGE/boot.img := append-kernel # override Default-emmc boot.img, otherwise kernel-bin will be wrapped twice
  IMAGES += sysupgrade.tar
  IMAGE/sysupgrade.tar := sysupgrade-tar | append-metadata
endef
TARGET_DEVICES += luckfox_pico-max

define Device/luckfox_pico-mini
  $(Device/Default-sdcard)
  DEVICE_TITLE := Luckfox Pico Mini
  SUPPORTED_DEVICES := luckfox,rv1103-luckfox-pico-mini
  SOC := rv1103
  DEVICE_DTS := rv1103g-luckfox-pico-mini
  UBOOT_DEVICE_NAME := rv1106-sd
  DEFAULT_PACKAGES += kmod-rknpu-rockchip
  IMAGES += sysupgrade.img.gz
  IMAGE/sysupgrade.img.gz := env-rv1106-sd-img | rockchip32-legacy-bin | append-rootfs | pad-extra 128k | gzip | append-metadata
endef
TARGET_DEVICES += luckfox_pico-mini

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
