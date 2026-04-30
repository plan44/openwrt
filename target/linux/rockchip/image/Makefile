# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk

DEVICE_VARS += UBOOT_DEVICE_NAME

define Build/Compile
	$(CP) $(LINUX_DIR)/COPYING $(KDIR)/COPYING.linux
endef

### Image scripts ###
define Build/boot-common
	# This creates a new folder copies the dtb (as rockchip.dtb)
	# and the kernel image (as kernel.img)
	rm -fR $@.boot
	mkdir -p $@.boot

	$(CP) $(KERNEL_BUILD_DIR)/image-$(DEVICE_DTS).dtb $@.boot/rockchip.dtb
	$(CP) $(IMAGE_KERNEL) $@.boot/kernel.img
endef

define Build/boot-common-legacy
	# This creates a new folder copies the dtb (as rockchip.dtb)
	# and the kernel image (as kernel.img)
	rm -fR $@.boot
	mkdir -p $@.boot

	$(CP) $(KERNEL_BUILD_DIR)/image-$(DEVICE_DTS).dtb $@.boot/rockchip.dtb
	$(CP) $(IMAGE_KERNEL) $@.boot/kernel.img
endef

define Build/boot-script
	# Make an U-boot image and copy it to the boot partition
	mkimage -A arm -O linux -T script -C none -a 0 -e 0 -d $(if $(1),$(1),mmc).bootscript $@.boot/boot.scr
endef

define Build/pine64-img
	# Creates the final SD/eMMC images,
	# combining boot partition, root partition as well as the u-boot bootloader

	# Generate a new partition table in $@ with 32 MiB of
	# alignment padding for the u-boot-rockchip.bin (idbloader + u-boot) to fit:
	# http://opensource.rock-chips.com/wiki_Boot_option#Boot_flow
	#
	# U-Boot SPL expects the U-Boot ITB to be located at sector 0x4000 (8 MiB) on the MMC storage
	PADDING=1 $(SCRIPT_DIR)/gen_image_generic.sh \
		$@ \
		$(CONFIG_TARGET_KERNEL_PARTSIZE) $@.boot \
		$(CONFIG_TARGET_ROOTFS_PARTSIZE) $(IMAGE_ROOTFS) \
		32768

	# Copy the idbloader and the u-boot image to the image at sector 0x40 and 0x4000
	dd if="$(STAGING_DIR_IMAGE)"/$(UBOOT_DEVICE_NAME)-idbloader.img of="$@" seek=64 conv=notrunc
	dd if="$(STAGING_DIR_IMAGE)"/$(UBOOT_DEVICE_NAME)-u-boot.itb of="$@" seek=16384 conv=notrunc
endef

define Build/pine64-bin
	# Typical Rockchip boot flow with Rockchip miniloader
	# Rockchp idbLoader which is combinded by Rockchip ddr init bin
	# and miniloader bin from Rockchip rkbin project

	# Generate a new partition table in $@ with 32 MiB of alignment
	# padding for the idbloader, uboot and trust image to fit:
	# http://opensource.rock-chips.com/wiki_Boot_option#Boot_flow
	PADDING=1 $(SCRIPT_DIR)/gen_image_generic.sh \
		$@ \
		$(CONFIG_TARGET_KERNEL_PARTSIZE) $@.boot \
		$(CONFIG_TARGET_ROOTFS_PARTSIZE) $(IMAGE_ROOTFS) \
		32768

	# Copy the idbloader, uboot and trust image to the image at sector 0x40, 0x4000 and 0x6000
	dd if="$(STAGING_DIR_IMAGE)"/$(SOC)-idbloader.bin of="$@" seek=64 conv=notrunc
	dd if="$(STAGING_DIR_IMAGE)"/$(UBOOT_DEVICE_NAME)-uboot.img of="$@" seek=16384 conv=notrunc
	dd if="$(STAGING_DIR_IMAGE)"/$(SOC)-trust.bin of="$@" seek=24576 conv=notrunc
endef

define Build/rockchip32-legacy-bin
	# Typical Rockchip boot flow with Rockchip miniloader
	# Rockchp idbLoader which is combinded by Rockchip ddr init bin
	# and miniloader bin from Rockchip rkbin project

	# Generate a new partition table in $@ with 32 MiB of alignment
	# padding for the idbloader, uboot and trust image to fit:
	# http://opensource.rock-chips.com/wiki_Boot_option#Boot_flow

	# This creates a new folder copies the dtb (as rockchip.dtb)
	# and the kernel image (as kernel.img)
	rm -fR $@.boot
	mkdir -p $@.boot

	# copy its
	$(CP) ./boot-arm.its $@.boot/boot.its

	# copy resource.img dtb kernel
	$(CP) $(LINUX_DIR)/resource.img $@.boot/resource
	$(CP) $(KERNEL_BUILD_DIR)/image-$(DEVICE_DTS).dtb $@.boot/fdt
	$(CP) $(IMAGE_KERNEL) $@.boot/kernel

	# generate boot.img with boot.its
	PATH=$(LINUX_DIR)/scripts/dtc:$(PATH) mkimage -E -p 0x800 -f $@.boot/boot.its $@.boot/boot.img

	# generate basic image
	dd if=/dev/zero of="$@" bs=512 count=67136 conv=notrunc

	# Copy the idbloader and the u-boot image to the image at sector 0x40 and 0x440
	# Copy the boot.img to sector 0x640
	dd if="$(STAGING_DIR_IMAGE)"/$(UBOOT_DEVICE_NAME)-env.img of="$@" seek=0 conv=notrunc
	dd if="$(STAGING_DIR_IMAGE)"/$(UBOOT_DEVICE_NAME)-idblock.img of="$@" seek=64 conv=notrunc
	dd if="$(STAGING_DIR_IMAGE)"/$(UBOOT_DEVICE_NAME)-uboot.img of="$@" seek=1088 conv=notrunc
	dd if="$@.boot"/boot.img of="$@" seek=1600 conv=notrunc
endef

### resource.img generate scripts ###
define Build/resource-img
	$(LINUX_DIR)/scripts/resource_tool $(KERNEL_BUILD_DIR)/image-$(DEVICE_DTS).dtb $(LINUX_DIR)/logo.bmp $(LINUX_DIR)/logo_kernel.bmp
	mv ./resource.img $(LINUX_DIR)/resource.img
endef

### env.img generate scripts ###
define Build/env-sd-img
	mkenvimage -s 0x8000 -p 0x0 -o $(STAGING_DIR_IMAGE)/$(UBOOT_DEVICE_NAME)-env.img ./uboot.env.sd.txt
endef

### Image scripts ###
define Build/boot-arm-bin
	# This creates a new folder copies the dtb (as rockchip.dtb)
	# and the kernel image (as kernel.img)
	rm -fR $@.boot
	mkdir -p $@.boot

	# copy its
	$(CP) ./boot-arm.its $@.boot/boot.its

	# copy resource.img dtb kernel
	$(CP) $(LINUX_DIR)/resource.img $@.boot/resource
	$(CP) $(KERNEL_BUILD_DIR)/image-$(DEVICE_DTS).dtb $@.boot/fdt
	$(CP) $(IMAGE_KERNEL) $@.boot/kernel

	PATH=$(LINUX_DIR)/scripts/dtc:$(PATH) mkimage -B 0x200 -E -p 0x800 -f $@.boot/boot.its $@
endef

define Build/boot-arm-nand-tb-bin
	# Like boot-arm-bin but uses real kernel load/entry address (0x208000) instead
	# of placeholder 0xffffff01. Required for Thunderboot NAND: the rkbin NAND SPL
	# loads the kernel directly and does not resolve KERNEL_ADDR_PLACEHOLDER.
	# 0x208000 = above SPL SDRAM region (0x0-0x1fffff), TEXT_OFFSET=0x8000 from 0x200000.
	rm -fR $@.boot
	mkdir -p $@.boot

	$(CP) ./boot-arm-nand-tb.its $@.boot/boot.its

	$(CP) $(LINUX_DIR)/resource.img $@.boot/resource
	$(CP) $(KERNEL_BUILD_DIR)/image-$(DEVICE_DTS).dtb $@.boot/fdt
	$(CP) $(IMAGE_KERNEL) $@.boot/kernel

	PATH=$(LINUX_DIR)/scripts/dtc:$(PATH) mkimage -B 0x200 -E -p 0x800 -f $@.boot/boot.its $@
endef

define Build/boot-arm64-bin
	# This creates a new folder copies the dtb (as rockchip.dtb)
	# and the kernel image (as kernel.img)
	rm -fR $@.boot
	mkdir -p $@.boot

	# copy its
	$(CP) ./boot-arm64.its $@.boot/boot.its

	# copy resource.img dtb kernel
	$(CP) $(LINUX_DIR)/resource.img $@.boot/resource
	$(CP) $(KERNEL_BUILD_DIR)/image-$(DEVICE_DTS).dtb $@.boot/fdt
	$(CP) $(IMAGE_KERNEL) $@.boot/kernel

	PATH=$(LINUX_DIR)/scripts/dtc:$(PATH) mkimage -B 0x200 -E -p 0x800 -f $@.boot/boot.its $@
endef

### Devices ###
# Version from OpenWrt 24.10.2
define Device/Default
  PROFILES := Default
  KERNEL = kernel-bin | lzma | fit lzma $$(DTS_DIR)/$$(DEVICE_DTS).dtb
  BOOT_SCRIPT :=
  IMAGES := sysupgrade.img.gz
  IMAGE/sysupgrade.img.gz = boot-common | boot-script $$(BOOT_SCRIPT) | pine64-img | gzip | append-metadata
  DEVICE_DTS = rockchip/$$(SOC)-$(lastword $(subst _, ,$(1)))
  UBOOT_DEVICE_NAME = $(lastword $(subst _, ,$(1)))-$$(SOC)
endef
# Version from p44-rockchip 22.03
#define Device/Default
#  PROFILES := Default
#  KERNEL_NAME := Image
#  KERNEL := kernel-bin
#  IMAGES := sysupgrade.img.gz
#  DEVICE_DTS = rockchip/$$(SOC)-$(lastword $(subst _, ,$(1)))
#endef

# TBD - just copied from p44-rockchip 22.03
define Device/Default-arm32
  PROFILES := Default
  KERNEL_NAME := zImage
  KERNEL := kernel-bin
  IMAGES := sysupgrade.img.gz
  DEVICE_DTS_DIR := ../dts
  DEVICE_DTS = $$(SOC)_$(1)
endef

# TBD - just copied from p44-rockchip 22.03
define Device/Default-sfc-128k
  IMAGE_SIZE := 97280k #95M for rootfs
  UBINIZE_OPTS :=
  BLOCKSIZE := 128k
  PAGESIZE := 2048
  UBIFS_OPTS := -m $$(PAGESIZE) -e 124KiB -c 4096
endef

include $(SUBTARGET).mk

$(eval $(call BuildImage))
